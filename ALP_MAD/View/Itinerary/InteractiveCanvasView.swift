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
    
    @State private var showSearchBar: Bool = false
    
    init(trip: Trip, dayNumber: Int, context: ModelContext) {
        _viewModel = State(initialValue: ItineraryViewModel(modelContext: context, trip: trip))
        viewModel.selectedDay = dayNumber
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - MAP FULL SCREEN
            Map(position: $cameraPos) {
                // Discoverable places
                ForEach(viewModel.discoverablePlaces) { place in
                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
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
                
                // Search results
                ForEach(viewModel.searchResults) { place in
                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title)
                            .foregroundColor(.themeGold)
                            .background(Circle().fill(Color.white).shadow(radius: 2))
                            .scaleEffect(selectedPlace == place ? 1.3 : 1.0)
                            .onTapGesture {
                                withAnimation(.spring()) { selectedPlace = place }
                            }
                    }
                }
            }
            .ignoresSafeArea()
            .onMapCameraChange { context in
                viewModel.currentZoomLevel = context.region.span.latitudeDelta
            }
            
            // MARK: - CONTENT OVERLAY (Glass Effect)
            VStack(spacing: 0) {
                Spacer()
                
                // Bottom Sheet: Jadwal Aktivitas
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Jadwal Aktivitas").font(.headline).foregroundColor(.themeDarkText)
                        Spacer()
                        EditButton()
                            .foregroundColor(.themeGold)
                    }
                    .padding()
                    .background(
                        Color(.systemBackground)
                            .opacity(0.85)
                            .background(.ultraThinMaterial)
                    )
                    
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
                    .frame(maxHeight: 300)
                    .scrollContentBackground(.hidden)
                    .background(
                        Color(.systemBackground)
                            .opacity(0.85)
                            .background(.ultraThinMaterial)
                    )
                }
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10, y: -2)
            }
            .ignoresSafeArea(edges: .bottom)
            .padding(.bottom, 0)
            
            // MARK: - OVERLAY UI ELEMENTS
            ZStack {
                
                // Search Bar (Top Left)
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button(action: {
                            withAnimation(.spring()) {
                                showSearchBar.toggle()
                                if !showSearchBar {
                                    viewModel.clearSearch()
                                }
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3.bold())
                                .foregroundColor(.themeBlue)
                                .frame(width: 44, height: 44)
                                .background(
                                    Color.white
                                        .opacity(0.9)
                                        .background(.ultraThinMaterial)
                                )
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 16)
                
                // Zoom Buttons (Bottom Right, di atas bottom sheet)
                VStack(spacing: 8) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button(action: zoomIn) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.themeTeal)
                                .frame(width: 40, height: 40)
                                .background(
                                    Color.white
                                        .opacity(0.9)
                                        .background(.ultraThinMaterial)
                                )
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        
                        Button(action: zoomOut) {
                            Image(systemName: "minus")
                                .font(.title2.bold())
                                .foregroundColor(.themeTeal)
                                .frame(width: 40, height: 40)
                                .background(
                                    Color.white
                                        .opacity(0.9)
                                        .background(.ultraThinMaterial)
                                )
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.bottom, 330) // Disesuaikan agar di atas bottom sheet
                }
                .padding(.trailing, 16)
                
                // Search Results Panel
                if showSearchBar {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                
                                TextField("Cari tempat...", text: $viewModel.searchText)
                                    .textFieldStyle(.plain)
                                    .foregroundColor(.themeDarkText)
                                    .onSubmit {
                                        viewModel.performSearch()
                                    }
                                
                                if !viewModel.searchText.isEmpty {
                                    Button(action: {
                                        viewModel.clearSearch()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Button(action: viewModel.performSearch) {
                                    Text("Cari")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.themeTeal)
                                        .cornerRadius(6)
                                }
                            }
                            .padding(10)
                            .background(
                                Color(.systemBackground)
                                    .opacity(0.95)
                                    .background(.ultraThinMaterial)
                            )
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
                            
                            if !viewModel.searchResults.isEmpty {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(viewModel.searchResults) { place in
                                            Button(action: {
                                                selectedPlace = place
                                                cameraPos = .region(MKCoordinateRegion(
                                                    center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
                                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                                ))
                                            }) {
                                                HStack {
                                                    Image(systemName: "mappin.circle.fill")
                                                        .foregroundColor(.themeGold)
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(place.name)
                                                            .font(.subheadline.bold())
                                                            .foregroundColor(.themeDarkText)
                                                        Text(place.shortDesc)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                            .lineLimit(1)
                                                    }
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                        .foregroundColor(.secondary)
                                                        .font(.caption)
                                                }
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                            }
                                            
                                            if place.id != viewModel.searchResults.last?.id {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 150)
                                .background(
                                    Color(.systemBackground)
                                        .opacity(0.95)
                                        .background(.ultraThinMaterial)
                                )
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.15), radius: 5, y: 2)
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Popup Info Tempat
                if let place = selectedPlace {
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.themeTurquoiseLight)
                                    .frame(width: 60, height: 60)
                                    .overlay(Image(systemName: "photo").foregroundColor(.themeTeal))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(place.name).font(.headline).foregroundColor(.themeDarkText)
                                    if place.isUMKM {
                                        Text("SDG 8: UMKM Lokal")
                                            .font(.caption2).bold()
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Color.themeGold.opacity(0.2))
                                            .foregroundColor(.themeGold)
                                            .cornerRadius(4)
                                    }
                                    Text(place.shortDesc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedPlace = nil
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
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
                        .background(
                            Color(.systemBackground)
                                .opacity(0.95)
                                .background(.ultraThinMaterial)
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        .padding()
                        .padding(.bottom, 250) // Di atas bottom sheet
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .ignoresSafeArea()
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
    
    // MARK: - Zoom Functions
    private func zoomIn() {
        if let currentRegion = cameraPos.region {
            let newDelta = viewModel.calculateZoomIn(currentDelta: currentRegion.span.latitudeDelta)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                cameraPos = .region(MKCoordinateRegion(
                    center: currentRegion.center,
                    span: MKCoordinateSpan(latitudeDelta: newDelta, longitudeDelta: newDelta)
                ))
            }
        }
    }
    
    private func zoomOut() {
        if let currentRegion = cameraPos.region {
            let newDelta = viewModel.calculateZoomOut(currentDelta: currentRegion.span.latitudeDelta)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                cameraPos = .region(MKCoordinateRegion(
                    center: currentRegion.center,
                    span: MKCoordinateSpan(latitudeDelta: newDelta, longitudeDelta: newDelta)
                ))
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
