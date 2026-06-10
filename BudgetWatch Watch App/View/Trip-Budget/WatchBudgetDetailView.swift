//
//  WatchBudgetDetailView.swift
//  ALP_MAD
//
//  Created by Dharma on 03/06/26.
//

import SwiftUI
import Charts

struct WatchBudgetDetailView: View {
    @Environment(BudgetViewModel.self) private var vm

    let trip: WatchTripPayload

    private var totalBudget: Double {
        vm.totalBudget(for: trip)
    }

    private var breakdown: [CategoryBreakdownItem] {
        vm.categoryBreakdown(for: trip)
    }

    private var duration: Int {
        vm.durationDays(from: trip.startDate, to: trip.endDate)
    }

    var body: some View {
        List {
            // MARK: Summary Section
            Section {
                VStack(alignment: .center, spacing: 2) {
                    Text(trip.destination)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(vm.formatCurrency(totalBudget, currency: trip.currency))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text("Total Estimasi")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)

            // MARK: Visual Chart Section
            if !breakdown.isEmpty {
                Section(header: Text("Alokasi Dana")) {
                    Chart(breakdown, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.65),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.category.watchColor)
                    }
                    .frame(height: 100)
                    .padding(.vertical, 6)
                }
            }

            // MARK: Breakdown List Section
            Section(header: Text("Kategori")) {
                ForEach(breakdown, id: \.category) { item in
                    HStack(spacing: 8) {
                        Image(systemName: item.category.icon)
                            .font(.system(size: 11))
                            .foregroundStyle(item.category.watchColor)
                            .frame(width: 16)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.category.shortName)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                            Text("\(Int(item.percentage * 100))%")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(vm.formatCurrency(item.total, currency: trip.currency))
                            .font(.system(size: 12, weight: .medium))
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 2)
                }
            }

            // MARK: Footer Info
            Section {
                HStack {
                    Label("\(duration) hari", systemImage: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(trip.name)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
