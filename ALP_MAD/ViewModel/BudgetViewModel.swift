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
        guard !itemTitle.trimmingCharacters(in: .whitespaces).isEmpty,
              let amount = Self.parseAmount(itemAmount)
        else { return false }
        return amount > 0
    }

    var isTripFormValid: Bool {
        !tripName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !tripDestination.trimmingCharacters(in: .whitespaces).isEmpty &&
        tripEndDate > tripStartDate
    }

    // MARK: - CRUD: BudgetItem

    func addItem(to trip: Trip, context: ModelContext) {
        guard isItemFormValid, let amount = Self.parseAmount(itemAmount) else { return }
        let item = BudgetItem(
            title:    itemTitle.trimmingCharacters(in: .whitespaces),
            amount:   amount,
            category: itemCategory,
            note:     itemNote.trimmingCharacters(in: .whitespaces)
        )
        item.trip = trip
        trip.budgetItems.append(item)
        context.insert(item)
        try? context.save()
        clearItemForm()
    }

    func updateItem(_ item: BudgetItem, context: ModelContext) {
        guard isItemFormValid, let amount = Self.parseAmount(itemAmount) else { return }
        item.title    = itemTitle.trimmingCharacters(in: .whitespaces)
        item.amount   = amount
        item.category = itemCategory
        item.note     = itemNote.trimmingCharacters(in: .whitespaces)
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
            name:        tripName.trimmingCharacters(in: .whitespaces),
            destination: tripDestination.trimmingCharacters(in: .whitespaces),
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

    func categoryBreakdown(for trip: Trip) -> [CategoryBreakdownItem] {
        BudgetCategory.allCases.compactMap { cat in
            let t = total(for: cat, in: trip)
            guard t > 0 else { return nil }
            return CategoryBreakdownItem(category: cat, total: t, percentage: percentage(for: cat, in: trip))
        }
        .sorted { $0.total > $1.total }
    }

    /// Items of a trip sorted newest-first, optionally filtered by category.
    func items(in trip: Trip, filteredBy category: BudgetCategory? = nil) -> [BudgetItem] {
        let sorted = trip.budgetItems.sorted { $0.createdAt > $1.createdAt }
        guard let category else { return sorted }
        return sorted.filter { $0.category == category }
    }

    // MARK: - Watch Payload Helpers

    func totalBudget(for payload: WatchTripPayload) -> Double {
        payload.items.reduce(0) { $0 + $1.amount }
    }

    func categoryBreakdown(for payload: WatchTripPayload) -> [CategoryBreakdownItem] {
        var grouped: [BudgetCategory: Double] = [:]
        for item in payload.items {
            let cat = BudgetCategory(rawValue: item.category) ?? .other
            grouped[cat, default: 0] += item.amount
        }
        let total = grouped.values.reduce(0, +)
        return grouped
            .map { cat, amount in
                CategoryBreakdownItem(
                    category:   cat,
                    total:      amount,
                    percentage: total > 0 ? amount / total : 0
                )
            }
            .sorted { $0.total > $1.total }
    }

    // MARK: - Amount Parsing

    /// Parses a user-typed amount, accepting "." or "," as grouping or decimal
    /// separator ("1,500,000", "1.500.000", "99.99", "0,5"). A single separator
    /// followed by exactly 3 digits is treated as a thousands separator.
    static func parseAmount(_ raw: String) -> Double? {
        var s = raw.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "")
        guard !s.isEmpty else { return nil }

        let dots   = s.filter { $0 == "." }.count
        let commas = s.filter { $0 == "," }.count

        if dots > 0 && commas > 0 {
            // Rightmost symbol is the decimal separator, the other is grouping.
            if let lastDot = s.lastIndex(of: "."), let lastComma = s.lastIndex(of: ","), lastDot > lastComma {
                s = s.replacingOccurrences(of: ",", with: "")
            } else {
                s = s.replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: ",", with: ".")
            }
        } else if commas > 0 {
            s = (commas == 1 && !s.hasSuffix(threeDigitsAfter: ","))
                ? s.replacingOccurrences(of: ",", with: ".")
                : s.replacingOccurrences(of: ",", with: "")
        } else if dots > 1 || (dots == 1 && s.hasSuffix(threeDigitsAfter: ".")) {
            s = s.replacingOccurrences(of: ".", with: "")
        }
        return Double(s)
    }

    // MARK: - Formatting

    func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle         = .currency
        formatter.currencyCode        = currency
        formatter.maximumFractionDigits = currency == "IDR" ? 0 : 2
        return formatter.string(from: NSNumber(value: amount)) ?? "-"
    }

    /// Locale-independent plain representation used to refill the amount text
    /// field, guaranteed to round-trip through `parseAmount`.
    func formatRaw(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale                = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle           = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? ""
    }

    /// Whole days between two dates, ignoring the time-of-day component.
    func durationDays(from start: Date, to end: Date) -> Int {
        let cal = Calendar.current
        return cal.dateComponents([.day],
                                  from: cal.startOfDay(for: start),
                                  to:   cal.startOfDay(for: end)).day ?? 0
    }

    func durationText(trip: Trip) -> String {
        let days = durationDays(from: trip.startDate, to: trip.endDate)
        return "\(days) day\(days == 1 ? "" : "s")"
    }
}

private extension String {
    /// True when the string ends with `separator` followed by exactly 3 digits,
    /// e.g. "1.500" / "12,345" — the thousands-separator pattern.
    func hasSuffix(threeDigitsAfter separator: Character) -> Bool {
        guard let idx = lastIndex(of: separator) else { return false }
        let tail = self[index(after: idx)...]
        return tail.count == 3 && tail.allSatisfy(\.isNumber)
    }
}
