//
//  TripJournalView.swift
//  ALP_MAD
//
//  Created by student on 04/06/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct TripJournalView: View {
    @Environment(\.modelContext) private var context
    let trip: Trip

    @State private var vm = TripJournalViewModel()

    var body: some View {
        @Bindable var vm = vm
        List {
            Section {
                Button {
                    vm.showAddEntry = true
                } label: {
                    Label("Write New Entry", systemImage: "square.and.pencil")
                }
            }

            let entries = vm.entries(in: trip)
            if entries.isEmpty {
                ContentUnavailableView(
                    "No Journal Entries Yet",
                    systemImage: "book.closed",
                    description: Text("Capture a memory from this trip — write a note and attach a photo.")
                )
            } else {
                Section("Entries") {
                    ForEach(entries) { entry in
                        JournalEntryRow(entry: entry, vm: vm)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            vm.deleteEntry(entries[index], from: trip, context: context)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $vm.showAddEntry) {
            AddJournalEntrySheet(vm: vm) {
                vm.addEntry(to: trip, context: context)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Add Entry Sheet

struct AddJournalEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: TripJournalViewModel
    let onSave: () -> Void

    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section("Entry") {
                    TextField("Title (e.g. Day 1 — Arrival)", text: $vm.entryTitle)
                        .textInputAutocapitalization(.sentences)
                    TextField("Write your note...", text: $vm.entryNote, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }

                Section("Photo (optional)") {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Choose from Gallery", systemImage: "photo.on.rectangle")
                    }
                    if let data = vm.entryPhotoData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Button(role: .destructive) {
                            vm.entryPhotoData = nil
                            pickerItem = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.clearForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!vm.isEntryValid)
                }
            }
            .onChange(of: pickerItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        vm.entryPhotoData = data
                    }
                }
            }
        }
    }
}
