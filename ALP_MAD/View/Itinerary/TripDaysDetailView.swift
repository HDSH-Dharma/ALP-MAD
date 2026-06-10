//
//  TripDaysDetailView.swift
//  ALP_MAD
//
//  Created by student on 03/06/26.
//

import SwiftUI
import SwiftData

struct TripDaysDetailView: View {
    @Environment(\.modelContext) private var modelContext
    var trip: Trip

    @State private var selectedDay: Int = 1

    // MARK: - Derived
    private var totalDays: Int { max(1, trip.totalDays) }

    private var progress: Double {
        guard totalDays > 1 else { return 1 }
        return Double(selectedDay) / Double(totalDays)
    }

    private var currentDate: String {
        let date = Calendar.current.date(
            byAdding: .day,
            value: selectedDay - 1,
            to: trip.startDate
        ) ?? trip.startDate
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Trip Header
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(.title2.bold())
                    .foregroundColor(.themeBlue)
                Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) – \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)

            // MARK: - Day Navigator
            HStack(spacing: 0) {
                // Prev button
                Button {
                    guard selectedDay > 1 else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedDay -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedDay > 1 ? .themeBlue : .secondary.opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                .disabled(selectedDay <= 1)

                Spacer()

                // Day Label
                VStack(spacing: 2) {
                    Text("Hari Ke-\(selectedDay)")
                        .font(.headline)
                        .foregroundColor(.themeDarkText)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: selectedDay)
                    Text("\(currentDate)  ·  \(selectedDay) / \(totalDays)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: selectedDay)
                }

                Spacer()

                // Next button
                Button {
                    guard selectedDay < totalDays else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedDay += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedDay < totalDays ? .themeBlue : .secondary.opacity(0.3))
                        .frame(width: 44, height: 44)
                }
                .disabled(selectedDay >= totalDays)
            }
            .padding(.horizontal, 12)

            // MARK: - Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.themeBlue.opacity(0.12))
                        .frame(height: 3)
                    Capsule()
                        .fill(Color.themeBlue)
                        .frame(width: geo.size.width * progress, height: 3)
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedDay)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 20)

            // MARK: - Swipeable Day Cards
            if trip.totalDays > 0 {
                TabView(selection: $selectedDay) {
                    ForEach(1...totalDays, id: \.self) { day in
                        DayPageCard(
                            trip: trip,
                            day: day,
                            modelContext: modelContext
                        )
                        .tag(day)
                        .padding(.horizontal, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            } else {
                ContentUnavailableView(
                    "Trip Tidak Valid",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Tanggal trip tidak valid.")
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Itinerary")
    }
}

// MARK: - Day Page Card
struct DayPageCard: View {
    let trip: Trip
    let day: Int
    let modelContext: ModelContext

    private var destinations: [Destination] {
        trip.destinations
            .filter { $0.dayNumber == day }
            .sorted { $0.visitOrder < $1.visitOrder }
    }

    private var dayDate: String {
        let date = Calendar.current.date(
            byAdding: .day,
            value: day - 1,
            to: trip.startDate
        ) ?? trip.startDate
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(spacing: 0) {

            // Card Header
            HStack(alignment: .center) {
                ZStack {
                    Circle()
                        .fill(Color.themeTurquoiseLight)
                        .frame(width: 48, height: 48)
                    Text("\(day)")
                        .font(.title3.bold())
                        .foregroundColor(.themeTeal)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Hari Ke-\(day)")
                        .font(.headline)
                        .foregroundColor(.themeDarkText)
                    Text(dayDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if destinations.isEmpty {
                    Text("Kosong")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                } else {
                    Text("\(destinations.count) Tempat")
                        .font(.caption.bold())
                        .foregroundColor(.themeDarkText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.themeGold.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()
                .padding(.horizontal, 16)

            // Destination List or Empty State
            if destinations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "map")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("Belum ada tempat di hari ini.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Ketuk tombol di bawah untuk mulai menjadwalkan.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(destinations) { dest in
                            DestinationRowSimple(
                                destination: dest,
                                isLast: dest.id == destinations.last?.id
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            Divider()
                .padding(.horizontal, 16)

            // Open Canvas Button
            NavigationLink(destination: InteractiveCanvasView(trip: trip, dayNumber: day, context: modelContext)) {
                Label("Buka Peta & Jadwalkan", systemImage: "map.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.themeBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Destination Row
struct DestinationRowSimple: View {
    let destination: Destination
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.themeGold)
                        .frame(width: 30, height: 30)
                    Text("\(destination.visitOrder + 1)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.themeDarkText)
                    if !destination.timeString.isEmpty {
                        Text(destination.timeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if destination.isLocalUMKM {
                    Image(systemName: "storefront.fill")
                        .font(.caption)
                        .foregroundColor(.themeTeal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            if !isLast {
                Divider().padding(.leading, 62)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    let dummyTrip = Trip(title: "Explore Bali", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 6))
    let dest1 = Destination(name: "Pantai Kuta", latitude: -8.7179, longitude: 115.1695, isLocalUMKM: false, visitOrder: 0, dayNumber: 1, timeString: "09:00")
    let dest2 = Destination(name: "Tanah Lot", latitude: -8.6215, longitude: 115.0865, isLocalUMKM: false, visitOrder: 1, dayNumber: 1, timeString: "14:00")
    dummyTrip.destinations.append(contentsOf: [dest1, dest2])
    container.mainContext.insert(dummyTrip)
    return NavigationStack {
        TripDaysDetailView(trip: dummyTrip)
    }
    .modelContainer(container)
}
