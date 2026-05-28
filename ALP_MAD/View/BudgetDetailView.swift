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
    @Environment(\.modelContext) private var context

    let trip: Trip
    @Bindable var vm: BudgetViewModel

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

    var body: some View {
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
                            .pickerStyle(.segmented)
                            .frame(width: 140)
                        }

                        if chartMode == .donut {
                            BudgetDonutChart(
                                trip: trip,
                                vm:   vm
                            )
                        } else {
                            BudgetBarChart(
                                trip: trip,
                                vm:   vm
                            )
                        }

                        // Legend
                        VStack(spacing: 0) {
                            ForEach(vm.categoryBreakdown(for: trip), id: \.category) { item in
                                CategoryLegendRow(item: item, currency: trip.currency, vm: vm)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            filterCategory = (filterCategory == item.category) ? nil : item.category
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                    .background(
                                        filterCategory == item.category
                                            ? item.category.swiftUIColor.opacity(0.1)
                                            : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 8)
                                    )
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }

                // MARK: Items list
                VStack(alignment: .leading, spacing: 8) {
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
                        Text("\(filteredItems.count) item\(filteredItems.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if filteredItems.isEmpty {
                        EmptyBudgetView {
                            vm.showAddItem = true
                        }
                    } else {
                        ForEach(filteredItems) { item in
                            BudgetItemRow(item: item, currency: trip.currency, vm: vm)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        vm.deleteItem(item, from: trip, context: context)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        vm.populateItemForm(from: item)
                                        vm.editingItem  = item
                                        vm.showEditItem = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .padding(.vertical, 2)

                            if item.id != filteredItems.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.bottom, 80) // fab clearance
            }
            .padding(.top)
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.showAddItem = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        // MARK: Add item sheet
        .sheet(isPresented: $vm.showAddItem) {
            BudgetItemFormView(vm: vm, trip: trip, editingItem: nil)
                .presentationDetents([.large])
        }
        // MARK: Edit item sheet
        .sheet(isPresented: $vm.showEditItem) {
            if let item = vm.editingItem {
                BudgetItemFormView(vm: vm, trip: trip, editingItem: item)
                    .presentationDetents([.large])
            }
        }
    }
}
