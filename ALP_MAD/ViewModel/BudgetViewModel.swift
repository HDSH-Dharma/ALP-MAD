//
//  BudgetViewModel.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//



import Foundation
import SwiftData
import SwiftUI

@Observable
final class BudgetViewModel {

    // MARK: - Sheet / navigation state
    var showAddItem    = false
    var showEditItem   = false
    var showAddTrip    = false
    var editingItem: BudgetItem?
    var selectedTrip: Trip?

    // MARK: - Form state for BudgetItem
    var itemTitle    = ""
    var itemAmount   = ""
    var itemCategory = BudgetCategory.transportation
    var itemNote     = ""

    // MARK: - Form state for Trip
    var tripName        = ""
    var tripDestination = ""
    var tripStartDate   = Date()
    var tripEndDate     = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    var tripCurrency    = "IDR"

    // MARK: - Validation

    var isItemFormValid: Bool {
        !itemTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(itemAmount.replacingOccurrences(of: ",", with: "")) != nil &&
        (Double(itemAmount.replacingOccurrences(of: ",", with: "")) ?? 0) > 0
    }

    var isTripFormValid: Bool {
        !tripName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !tripDestination.trimmingCharacters(in: .whitespaces).isEmpty &&
        tripEndDate > tripStartDate
    }

    // MARK: - CRUD: BudgetItem

    func addItem(to trip: Trip, context: ModelContext) {
        guard isItemFormValid else { return }
        let amount = Double(itemAmount.replacingOccurrences(of: ",", with: "")) ?? 0
        let item = BudgetItem(
            title:    itemTitle,
            amount:   amount,
            category: itemCategory,
            note:     itemNote
        )
        item.trip = trip
        trip.budgetItems.append(item)
        context.insert(item)
        try? context.save()
        clearItemForm()
    }

    func updateItem(_ item: BudgetItem, context: ModelContext) {
        guard isItemFormValid else { return }
        let amount = Double(itemAmount.replacingOccurrences(of: ",", with: "")) ?? 0
        item.title    = itemTitle
        item.amount   = amount
        item.category = itemCategory
        item.note     = itemNote
        try? context.save()
        clearItemForm()
    }

    func deleteItem(_ item: BudgetItem, from trip: Trip, context: ModelContext) {
        trip.budgetItems.removeAll { $0.id == item.id }
        context.delete(item)
        try? context.save()
    }

    // MARK: - CRUD: Trip

    func addTrip(context: ModelContext) {
        guard isTripFormValid else { return }
        let trip = Trip(
            name:        tripName,
            destination: tripDestination,
            startDate:   tripStartDate,
            endDate:     tripEndDate,
            currency:    tripCurrency
        )
        context.insert(trip)
        try? context.save()
        selectedTrip = trip
        clearTripForm()
    }

    func deleteTrip(_ trip: Trip, context: ModelContext) {
        if selectedTrip?.id == trip.id { selectedTrip = nil }
        context.delete(trip)
        try? context.save()
    }

    // MARK: - Form Helpers

    func populateItemForm(from item: BudgetItem) {
        itemTitle    = item.title
        itemAmount   = formatRaw(item.amount)
        itemCategory = item.category
        itemNote     = item.note
    }

    func clearItemForm() {
        itemTitle    = ""
        itemAmount   = ""
        itemCategory = .transportation
        itemNote     = ""
        showAddItem  = false
        showEditItem = false
        editingItem  = nil
    }

    func clearTripForm() {
        tripName        = ""
        tripDestination = ""
        tripStartDate   = Date()
        tripEndDate     = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        tripCurrency    = "IDR"
        showAddTrip     = false
    }

    // MARK: - Trip Budget Helpers
   

    func totalBudget(for trip: Trip) -> Double {
        trip.budgetItems.reduce(0) { $0 + $1.amount }
    }

    func total(for category: BudgetCategory, in trip: Trip) -> Double {
        trip.budgetItems
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    func percentage(for category: BudgetCategory, in trip: Trip) -> Double {
        let t = totalBudget(for: trip)
        guard t > 0 else { return 0 }
        return total(for: category, in: trip) / t
    }

    func categoryBreakdown(for trip: Trip) -> [(category: BudgetCategory, total: Double, percentage: Double)] {
        BudgetCategory.allCases.compactMap { cat in
            let t = total(for: cat, in: trip)
            guard t > 0 else { return nil }
            return (cat, t, percentage(for: cat, in: trip))
        }
        .sorted { $0.total > $1.total }
    }

    // MARK: - Formatting

    func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle         = .currency
        formatter.currencyCode        = currency
        formatter.maximumFractionDigits = currency == "IDR" ? 0 : 2
        return formatter.string(from: NSNumber(value: amount)) ?? "-"
    }

    private func formatRaw(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle           = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }

    func durationText(trip: Trip) -> String {
        let days = Calendar.current.dateComponents([.day], from: trip.startDate, to: trip.endDate).day ?? 0
        return "\(days) day\(days == 1 ? "" : "s")"
    }
}
