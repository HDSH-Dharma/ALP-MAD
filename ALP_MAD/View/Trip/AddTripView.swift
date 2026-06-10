//
//  AddTripView.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//


import SwiftUI
import SwiftData
 
struct AddTripView: View {
    @Environment(\.modelContext)       private var context
    @Environment(\.dismiss)            private var dismiss
    @Environment(BudgetViewModel.self) private var vm
 
    let currencies = ["IDR", "USD", "EUR", "SGD", "JPY", "AUD", "MYR"]
 
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Info") {
                    TextField("Trip Name (e.g. Bali Summer 2026)", text: Bindable(vm).tripName)
                        .textInputAutocapitalization(.words)
                    TextField("Destination", text: Bindable(vm).tripDestination)
                        .textInputAutocapitalization(.words)
                }
 
                Section("Dates") {
                    DatePicker("Departure", selection: Bindable(vm).tripStartDate, displayedComponents: .date)
                    DatePicker("Return",    selection: Bindable(vm).tripEndDate,
                               in: vm.tripStartDate..., displayedComponents: .date)
                }
 
                Section("Currency") {
                    Picker("Currency", selection: Bindable(vm).tripCurrency) {
                        ForEach(currencies, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    #if os(watchOS)
                        .pickerStyle(.wheel)
                    #else
                        .pickerStyle(.segmented)
                    #endif
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.clearTripForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        vm.addTrip(context: context)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!vm.isTripFormValid)
                }
            }
        }
    }
}
