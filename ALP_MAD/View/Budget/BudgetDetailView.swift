//
//  BudgetDetailView.swift
//  ALP_MAD
//
//  Created by Dharma on 28/05/26.
//


import SwiftUI
import SwiftData
import Charts

struct BudgetDetailView: View {
    @Environment(\.modelContext)       private var context
    @Environment(BudgetViewModel.self) private var vm

    let trip: Trip

    @State private var chartMode: ChartMode = .donut
    @State private var filterCategory: BudgetCategory? = nil

    enum ChartMode: String, CaseIterable {
        case donut = "Donut"
        case bar   = "Bar"
    }

    private var filteredItems: [BudgetItem] {
        let sorted = trip.budgetItems.sorted { $0.createdAt > $1.createdAt }
        if let cat = filterCategory {
            return sorted.filter { $0.category == cat }
        }
        return sorted
    }

    private var breakdown: [CategoryBreakdownItem] {
        vm.categoryBreakdown(for: trip)
            .sorted { $0.total > $1.total }
            .map { CategoryBreakdownItem(category: $0.category, total: $0.total, percentage: $0.percentage) }
    }
    
    private var legendView: some View {
        VStack(spacing: 0) {
            ForEach(breakdown, id: \.category) { item in
                legendRow(for: item)
            }
        }
    }
    
    private func legendRow(for item: CategoryBreakdownItem) -> some View {
        let isSelected = filterCategory == item.category
        let color = item.category.swiftUIColor

        return CategoryLegendRow(item: item, currency: trip.currency, vm: vm)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3)) {
                    filterCategory = isSelected ? nil : item.category
                }
            }
            .padding(.horizontal, 4)
            .background(
                isSelected ? color.opacity(0.1) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
    }
    private var itemsHeaderView: some View {
        HStack {
            Text(filterCategory == nil ? "All Items" : filterCategory!.rawValue)
                .font(.headline)
            if filterCategory != nil {
                Button {
                    withAnimation { filterCategory = nil }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if filteredItems.count == 1 {
                Text("1 item")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(filteredItems.count) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var addItemSheet: some View {
        BudgetItemFormView(vm: vm, trip: trip, editingItem: nil)
            .presentationDetents([.large])
    }

    private var editItemSheet: some View {
        Group {
            if let item = vm.editingItem {
                BudgetItemFormView(vm: vm, trip: trip, editingItem: item)
                    .presentationDetents([.large])
            }
        }
    }
    
    var body: some View {
        @Bindable var vm = vm
        ScrollView {
            VStack(spacing: 20) {
                // MARK: Header card
                TripHeaderCard(trip: trip, vm: vm)
                    .padding(.horizontal)

                // MARK: Chart section
                if !trip.budgetItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Breakdown")
                                .font(.headline)
                            Spacer()
                            Picker("Chart", selection: $chartMode) {
                                ForEach(ChartMode.allCases, id: \.self) {
                                    Text($0.rawValue).tag($0)
                                }
                            }
                            #if os(watchOS)
                            .pickerStyle(.wheel)
                            #else
                            .pickerStyle(.segmented)
                            #endif
                            .frame(width: 140)
                        }
                        
                        if chartMode == .donut {
                            BudgetDonutChart(
                                breakdown:   breakdown,
                                totalBudget: vm.totalBudget(for: trip),
                                currency:    trip.currency,
                                vm:          vm
                            )
                        } else {
                            BudgetBarChart(
                                breakdown: breakdown,
                                currency:  trip.currency,
                                vm:        vm
                            )
                        }
                        
                        // Legend
                        legendView
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                // MARK: Items list
                VStack(alignment: .leading, spacing: 8) {
                    itemsHeaderView

                    if filteredItems.isEmpty {
                        EmptyBudgetView {
                            vm.showAddItem = true
                        }
                    } else {
                        ForEach(filteredItems) { item in
                            BudgetItemRow(item: item, currency: trip.currency, vm: vm)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button {
                                        vm.populateItemForm(from: item)
                                        vm.editingItem  = item
                                        vm.showEditItem = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        vm.deleteItem(item, from: trip, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .padding(.vertical, 2)

                            if filteredItems.last?.id != item.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .padding(.top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.showAddItem = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: Bindable(vm).showAddItem) {
            addItemSheet
        }
        .sheet(isPresented: Bindable(vm).showEditItem) {
            editItemSheet
        }
    }
}
