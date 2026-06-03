//
//  ItineraryCanvasView.swift
//  ALP_MAD
//
//  Created by student on 28/05/26.
//

import SwiftUI
import MapKit
import SwiftData

struct InteractiveCanvasView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ItineraryViewModel
    @State private var selectedPlace: LandmarkPlace? = nil
    
    @State private var cameraPos: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -7.2504, longitude: 112.7424),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    private let discoverablePlaces = [
        LandmarkPlace(name: "Tugu Pahlawan", latitude: -7.2458, longitude: 112.7378, shortDesc: "Monumen bersejarah perjuangan pahlawan.", isUMKM: false),
        LandmarkPlace(name: "Sentra Kuliner GWalk", latitude: -7.2891, longitude: 112.6415, shortDesc: "Pusat UMKM Kuliner warga lokal dengan cita rasa autentik.", isUMKM: true),
        LandmarkPlace(name: "Pasar Seni Lokal", latitude: -7.2531, longitude: 112.7401, shortDesc: "Oleh-oleh kerajinan tangan asli Suroboyo.", isUMKM: true)
    ]
    
    init(trip: Trip, dayNumber: Int, context: ModelContext) {
        _viewModel = State(initialValue: ItineraryViewModel(modelContext: context, trip: trip))
        viewModel.selectedDay = dayNumber
    }

    var body: some View {
        VStack(spacing: 0) {
            // BAGIAN 1: PETA
            ZStack(alignment: .bottom) {
                Map(position: $cameraPos) {
                    ForEach(discoverablePlaces) { place in
                        Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                            // Menggunakan Teal untuk UMKM, Blue untuk Wisata Umum
                            Image(systemName: place.isUMKM ? "storefront.circle.fill" : "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(place.isUMKM ? .themeTeal : .themeBlue)
                                .background(Circle().fill(Color.white).shadow(radius: 2))
                                .scaleEffect(selectedPlace == place ? 1.3 : 1.0)
                                .onTapGesture {
                                    withAnimation(.spring()) { selectedPlace = place }
                                }
                        }
                    }
                }
                .frame(height: 320)
                
                // POPUP KETIKA PIN DI PETA DIKLIK
                if let place = selectedPlace {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.themeTurquoiseLight)
                                .frame(width: 60, height: 60)
                                .overlay(Image(systemName: "photo").foregroundColor(.themeTeal))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name).font(.headline).foregroundColor(.themeDarkText)
                                if place.isUMKM {
                                    Text("SDG 8: UMKM Lokal").font(.caption2).bold()
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color.themeGold.opacity(0.2)).foregroundColor(.themeGold).cornerRadius(4)
                                }
                                Text(place.shortDesc).font(.caption).foregroundColor(.secondary).lineLimit(2)
                            }
                            Spacer()
                        }
                        
                        Button(action: {
                            viewModel.addDestination(place: place)
                            withAnimation { selectedPlace = nil }
                        }) {
                            Text("Tambahkan ke Itinerary")
                                .font(.subheadline).bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.themeTeal)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // BAGIAN 2: LIST DRAG & DROP
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Jadwal Aktivitas").font(.headline).foregroundColor(.themeDarkText)
                    Spacer()
                    EditButton()
                        .foregroundColor(.themeGold)
                }
                .padding()
                .background(Color(.systemGray6))
                
                List {
                    if viewModel.filteredDestinations.isEmpty {
                        Text("Jadwal hari ini masih kosong.\nKlik ikon di peta untuk mulai menambahkan tempat.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.filteredDestinations) { dest in
                            HStack(spacing: 12) {
                                Text(dest.timeString)
                                    .font(.subheadline).bold()
                                    .foregroundColor(.themeTeal)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(dest.name).font(.body).fontWeight(.semibold).foregroundColor(.themeDarkText)
                                    if !dest.activityDesc.isEmpty {
                                        Text(dest.activityDesc).font(.caption).foregroundColor(.secondary).lineLimit(1)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: viewModel.deleteDestination)
                        .onMove(perform: viewModel.moveDestination)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Hari Ke-\(viewModel.selectedDay)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveContext()
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(.themeBlue)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Destination.self, configurations: config)
    let dummyTrip = Trip(title: "Explore Surabaya", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 2))
    
    let dummyDest = Destination(
        name: "Tugu Pahlawan",
        latitude: -7.2458,
        longitude: 112.7378,
        isLocalUMKM: false,
        visitOrder: 0,
        dayNumber: 1,
        timeString: "09:00",
        activityDesc: "Monumen bersejarah perjuangan pahlawan."
    )
    dummyTrip.destinations.append(dummyDest)
    container.mainContext.insert(dummyTrip)
    
    return NavigationStack {
        InteractiveCanvasView(trip: dummyTrip, dayNumber: 1, context: container.mainContext)
    }
    .modelContainer(container)
}
