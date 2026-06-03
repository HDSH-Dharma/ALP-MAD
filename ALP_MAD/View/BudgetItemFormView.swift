//
//  BudgetItemFormView.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//


import SwiftUI
import SwiftData
 
struct BudgetItemFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
 
    @Bindable var vm: BudgetViewModel
    let trip: Trip
    let editingItem: BudgetItem?
 
    private var isEditing: Bool { editingItem != nil }
 
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Basic Info
                Section("Item Details") {
                    TextField("Title (e.g. Flight to Bali)", text: $vm.itemTitle)
                        .textInputAutocapitalization(.words)
 
                    HStack {
                        Text(trip.currency)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        TextField("0", text: $vm.itemAmount)
                        #if os(iOS)
                            .keyboardType(.numberPad)
                        #endif
                    }
                }
 
                // MARK: Category Picker
                Section("Category") {
                    Picker("Category", selection: $vm.itemCategory) {
                        ForEach(BudgetCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
 
                // MARK: Note
                Section("Note (optional)") {
                    TextField("Add a note...", text: $vm.itemNote, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
 
                // MARK: Category preview chip
                Section {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(vm.itemCategory.swiftUIColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                            Image(systemName: vm.itemCategory.icon)
                                .foregroundStyle(vm.itemCategory.swiftUIColor)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(vm.itemTitle.isEmpty ? "Item title" : vm.itemTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(vm.itemTitle.isEmpty ? .secondary : .primary)
                            Text(vm.itemCategory.rawValue)
                                .font(.caption)
                                .foregroundStyle(vm.itemCategory.swiftUIColor)
                        }
                        Spacer()
                        let parsed = Double(vm.itemAmount.replacingOccurrences(of: ",", with: "")) ?? 0
                        Text(vm.formatCurrency(parsed, currency: trip.currency))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "Add Budget Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.clearItemForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        if let item = editingItem {
                            vm.updateItem(item, context: context)
                        } else {
                            vm.addItem(to: trip, context: context)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!vm.isItemFormValid)
                }
            }
        }
    }
}
