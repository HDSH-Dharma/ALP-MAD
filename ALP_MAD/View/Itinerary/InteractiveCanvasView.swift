//
// InteractiveCanvasView.swift
// ALP_MAD
//
// Created by student on 28/05/26.
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
    
    // MARK: - Modal States
    @State private var showSearchModal: Bool = false
    @State private var showAddPlaceSheet: Bool = false
    @State private var placeToAdd: LandmarkPlace? = nil
    
    // MARK: - Bottom Sheet States
    @State private var sheetHeight: CGFloat = 300
    @State private var dragOffset: CGFloat = 0
    @State private var isSheetExpanded: Bool = false
    private let minHeight: CGFloat = 100
    private let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    
    // MARK: - Edit Time States
    @State private var editingDestination: Destination? = nil
    @State private var showEditTimeSheet: Bool = false
    
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
                    Annotation(place.name, coordinate: place.coordinate) {
                        MapAnnotationView(
                            place: place,
                            isSelected: selectedPlace == place,
                            onTap: {
                                withAnimation(.spring()) {
                                    selectedPlace = place
                                    placeToAdd = place
                                }
                            }
                        )
                    }
                }
                
                // Search results
                ForEach(viewModel.searchResults) { place in
                    Annotation(place.name, coordinate: place.coordinate) {
                        SearchResultAnnotationView(
                            place: place,
                            isSelected: selectedPlace == place,
                            onTap: {
                                withAnimation(.spring()) {
                                    selectedPlace = place
                                    placeToAdd = place
                                }
                            }
                        )
                    }
                }
                
                // Added destinations markers
                ForEach(viewModel.filteredDestinations) { dest in
                    Annotation(dest.name, coordinate: CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)) {
                        DestinationMarkerView(
                            destination: dest,
                            onTap: {
                                editingDestination = dest
                                showEditTimeSheet = true
                            }
                        )
                    }
                }
            }
            .ignoresSafeArea()
            .onMapCameraChange { context in
                viewModel.currentZoomLevel = context.region.span.latitudeDelta
            }
            .onTapGesture {
                if selectedPlace != nil {
                    withAnimation(.spring()) {
                        selectedPlace = nil
                    }
                }
            }
            
            // MARK: - OVERLAY UI ELEMENTS
            VStack {
                Spacer()
                
                // MARK: - ZOOM BUTTONS (Bottom Right, follows sheet)
                ZoomControlsView(
                    onZoomIn: zoomIn,
                    onZoomOut: zoomOut,
                    bottomPadding: sheetHeight + dragOffset + 16,
                    isHidden: isSheetExpanded
                )
            }
            
            // MARK: - BOTTOM SHEET (Draggable Modal)
            BottomSheetView(
                viewModel: viewModel,
                sheetHeight: $sheetHeight,
                dragOffset: $dragOffset,
                isSheetExpanded: $isSheetExpanded,
                minHeight: minHeight,
                maxHeight: maxHeight,
                onDestinationTap: { dest in
                    editingDestination = dest
                    showEditTimeSheet = true
                }
            )
            .padding(.bottom, -50)
            
            // MARK: - FLOATING ACTION BUTTONS (Top)
            TopActionBarView(
                onSearchTap: {
                    showSearchModal = true
                },
                onSaveTap: {
                    viewModel.saveContext()
                    dismiss()
                }
            )
        }
        .navigationTitle("Hari Ke-\(viewModel.selectedDay)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Hari Ke-\(viewModel.selectedDay)")
                    .font(.headline)
                    .foregroundColor(.themeDarkText)
            }
        }
        // MARK: - SEARCH MODAL
        .sheet(isPresented: $showSearchModal) {
            SearchModalView(
                viewModel: viewModel,
                onSelectPlace: { place in
                    // Set place first
                    selectedPlace = place
                    placeToAdd = place
                    
                    // Center map on selected place
                    cameraPos = .region(MKCoordinateRegion(
                        center: place.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                    
                    // Close search modal
                    showSearchModal = false
                    
                    // Show add place sheet dengan delay kecil untuk smooth transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showAddPlaceSheet = true
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        // MARK: - ADD PLACE SHEET
        .sheet(isPresented: $showAddPlaceSheet) {
            if let place = placeToAdd {
                AddPlaceSheet(
                    place: place,
                    viewModel: viewModel,
                    onAdd: { timeString in
                        let result = viewModel.addDestinationWithTime(place: place, timeString: timeString)
                        if result.success {
                            showAddPlaceSheet = false
                            placeToAdd = nil
                            selectedPlace = nil
                        }
                    },
                    onCancel: {
                        showAddPlaceSheet = false
                        placeToAdd = nil
                        selectedPlace = nil
                    },
                    errorMessage: viewModel.timeConflictError
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        // MARK: - EDIT TIME SHEET
        .sheet(isPresented: $showEditTimeSheet) {
            if let dest = editingDestination {
                EditTimeSheet(
                    destination: dest,
                    viewModel: viewModel,
                    onSave: { newTimeString in
                        let result = viewModel.updateDestinationTime(destination: dest, newTimeString: newTimeString)
                        if result.success {
                            showEditTimeSheet = false
                            editingDestination = nil
                        }
                    },
                    onCancel: {
                        showEditTimeSheet = false
                        editingDestination = nil
                    },
                    onDelete: {
                        viewModel.deleteDestinationById(dest.id)
                        showEditTimeSheet = false
                        editingDestination = nil
                    },
                    errorMessage: viewModel.timeConflictError
                )
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

// MARK: - MAP ANNOTATION VIEWS
struct MapAnnotationView: View {
    let place: LandmarkPlace
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: place.isUMKM ? "storefront.circle.fill" : "mappin.circle.fill")
            .font(.title)
            .foregroundColor(place.isUMKM ? .themeTeal : .themeBlue)
            .background(Circle().fill(Color.white).shadow(radius: 2))
            .scaleEffect(isSelected ? 1.3 : 1.0)
            .onTapGesture(perform: onTap)
    }
}

struct SearchResultAnnotationView: View {
    let place: LandmarkPlace
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: "magnifyingglass.circle.fill")
            .font(.title)
            .foregroundColor(.themeGold)
            .background(Circle().fill(Color.white).shadow(radius: 2))
            .scaleEffect(isSelected ? 1.3 : 1.0)
            .onTapGesture(perform: onTap)
    }
}

struct DestinationMarkerView: View {
    let destination: Destination
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.themeGold)
                .frame(width: 32, height: 32)
                .shadow(radius: 2)
            Text("\(destination.visitOrder + 1)")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - ZOOM CONTROLS VIEW
struct ZoomControlsView: View {
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let bottomPadding: CGFloat
    let isHidden: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: onZoomIn) {
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
                
                Button(action: onZoomOut) {
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
            .padding(.trailing, 16)
            .padding(.bottom, bottomPadding)
            .opacity(isHidden ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: isHidden)
        }
    }
}

// MARK: - TOP ACTION BAR VIEW
struct TopActionBarView: View {
    let onSearchTap: () -> Void
    let onSaveTap: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                // Search Button
                Button(action: onSearchTap) {
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
                
                // Save Button
                Button(action: onSaveTap) {
                    Text("Save")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.themeBlue)
                        .cornerRadius(22)
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

// MARK: - BOTTOM SHEET VIEW
struct BottomSheetView: View {
    @ObservedObject var viewModel: ItineraryViewModel
    @Binding var sheetHeight: CGFloat
    @Binding var dragOffset: CGFloat
    @Binding var isSheetExpanded: Bool
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let onDestinationTap: (Destination) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            DragHandleView(
                onDragChanged: { value in
                    dragOffset = value.translation.height
                },
                onDragEnded: { value in
                    handleDragEnd(translation: value.translation.height)
                }
            )
            
            // Header
            BottomSheetHeader(destinationCount: viewModel.filteredDestinations.count)
            
            // Content
            BottomSheetContent(
                destinations: viewModel.filteredDestinations,
                onDestinationTap: onDestinationTap
            )
        }
        .frame(height: sheetHeight + dragOffset)
        .frame(maxWidth: .infinity)
        .background(
            Color(.systemBackground)
                .opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 10, y: -2)
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(), value: isSheetExpanded)
    }
    
    private func handleDragEnd(translation: CGFloat) {
        let newHeight = sheetHeight - translation
        
        if newHeight > maxHeight * 0.7 {
            withAnimation(.spring()) {
                sheetHeight = maxHeight
                isSheetExpanded = true
            }
        } else if newHeight < minHeight + 50 {
            withAnimation(.spring()) {
                sheetHeight = minHeight
                isSheetExpanded = false
            }
        } else {
            withAnimation(.spring()) {
                sheetHeight = max(minHeight, min(maxHeight, newHeight))
                isSheetExpanded = false
            }
        }
        dragOffset = 0
    }
}

// MARK: - DRAG HANDLE VIEW
struct DragHandleView: View {
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 40, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .gesture(
                DragGesture()
                    .onChanged(onDragChanged)
                    .onEnded(onDragEnded)
            )
    }
}

// MARK: - BOTTOM SHEET HEADER
struct BottomSheetHeader: View {
    let destinationCount: Int
    
    var body: some View {
        HStack {
            Text("Jadwal Aktivitas")
                .font(.headline)
                .foregroundColor(.themeDarkText)
            Spacer()
            if destinationCount > 0 {
                Button("Edit") {
                    // Toggle edit mode if needed
                }
                .foregroundColor(.themeGold)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - BOTTOM SHEET CONTENT
struct BottomSheetContent: View {
    let destinations: [Destination]
    let onDestinationTap: (Destination) -> Void
    
    var body: some View {
        ScrollView {
            if destinations.isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(destinations) { dest in
                        DestinationRow(
                            destination: dest,
                            onTap: {
                                onDestinationTap(dest)
                            }
                        )
                        
                        if dest.id != destinations.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - EMPTY STATE VIEW
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Jadwal hari ini masih kosong.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Klik ikon di peta atau gunakan tombol search untuk menambahkan tempat.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
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
