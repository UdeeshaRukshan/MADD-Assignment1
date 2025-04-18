//
//  AddCrimeFormView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddCrimeFormView: View {
    @EnvironmentObject var viewModel: CrimeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: CrimeCategory = .other
    @State private var severity: Int = 1
    
    // Location selection
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingMap = false
    @State private var locationName: String = "No location selected"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Light gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F8F9FA"),
                        Color(hex: "E9ECEF")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Main content
                Form {
                    Section(header: 
                        Text("Crime Details")
                            .foregroundColor(Color(hex: "495057"))
                            .fontWeight(.medium)
                    ) {
                        TextField("Title", text: $title)
                            .foregroundColor(Color(hex: "212529"))
                        
                        TextField("Description", text: $description)
                            .foregroundColor(Color(hex: "212529"))
                        
                        Picker("Category", selection: $category) {
                            ForEach(CrimeCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .foregroundColor(Color(hex: "212529"))
                        
                        Stepper("Severity: \(severity)", value: $severity, in: 1...5)
                            .foregroundColor(Color(hex: "212529"))
                    }
                    .listRowBackground(Color(hex: "F8F9FA"))
                    
                    Section(header: 
                        Text("Location")
                            .foregroundColor(Color(hex: "495057"))
                            .fontWeight(.medium)
                    ) {
                        VStack {
                            Button(action: {
                                showingMap = true
                            }) {
                                HStack {
                                    Image(systemName: "map.fill")
                                        .foregroundColor(Color(hex: "3D8BFD"))
                                    
                                    Text(selectedLocation == nil ? "Select Location on Map" : locationName)
                                        .foregroundColor(selectedLocation == nil ? Color(hex: "6C757D") : Color(hex: "212529"))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "6C757D"))
                                }
                            }
                            
                            if let location = selectedLocation {
                                Divider().background(Color(hex: "DEE2E6"))
                                
                                HStack {
                                    Text("Latitude:")
                                        .foregroundColor(Color(hex: "6C757D"))
                                    
                                    Text(String(format: "%.6f", location.latitude))
                                        .foregroundColor(Color(hex: "212529"))
                                }
                                
                                HStack {
                                    Text("Longitude:")
                                        .foregroundColor(Color(hex: "6C757D"))
                                    
                                    Text(String(format: "%.6f", location.longitude))
                                        .foregroundColor(Color(hex: "212529"))
                                }
                                
                                // Preview map showing the selected location
                                Map(coordinateRegion: .constant(MKCoordinateRegion(
                                    center: location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )), annotationItems: [MapPin(coordinate: location)]) { pin in
                                    MapMarker(coordinate: pin.coordinate, tint: Color(hex: "DC3545"))
                                }
                                .frame(height: 150)
                                .cornerRadius(12)
                                .shadow(color: Color(hex: "ADB5BD").opacity(0.5), radius: 4, x: 0, y: 2)
                                .padding(.top, 8)
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "F8F9FA"))
                    
                    Section {
                        Button(action: addCrime) {
                            Text("Submit Report")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "DC3545"),
                                            Color(hex: "EB6A5C")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .shadow(color: Color(hex: "DC3545").opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .disabled(title.isEmpty || description.isEmpty || selectedLocation == nil)
                        .opacity(title.isEmpty || description.isEmpty || selectedLocation == nil ? 0.5 : 1)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Report a Crime")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(Color(hex: "F8F9FA"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingMap) {
                LocationPickerView(
                    region: $region,
                    selectedLocation: $selectedLocation,
                    locationName: $locationName,
                    isPresented: $showingMap
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "3D8BFD"))
                }
            }
        }
    }
    
    private func addCrime() {
        guard let location = selectedLocation else { return }
        
        let newCrime = CriminalActivity(
            title: title,
            description: description,
            category: category,
            date: Date(),
            locations: [
                CrimeLocation(
                    title: title,
                    description: description,
                    coordinate: location,
                    address: locationName,
                    timestamp: Date(),
                    evidencePhotos: [],
                    witnesses: 0,
                    isSolved: false
                )
            ],
            severity: severity,
            isPriority: severity >= 4
        )
        
        viewModel.addCrime(newCrime)
        dismiss()
    }
}

// Helper struct for map pins
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Location Picker View with matching light theme
struct LocationPickerView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var locationName: String
    @Binding var isPresented: Bool
    
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isDragging: Bool = false
    
    private let geocoder = CLGeocoder()
    
    var body: some View {
        ZStack {
            // Light background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F8F9FA"),
                    Color(hex: "E9ECEF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Color(hex: "3D8BFD"))
                    
                    Spacer()
                    
                    Text("Select Location")
                        .font(.headline)
                        .foregroundColor(Color(hex: "212529"))
                    
                    Spacer()
                    
                    Button("Done") {
                        if selectedLocation == nil {
                            selectedLocation = region.center
                            
                            let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
                            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                                if let placemark = placemarks?.first {
                                    var name = ""
                                    
                                    if let thoroughfare = placemark.thoroughfare {
                                        name += thoroughfare
                                    }
                                    
                                    if let locality = placemark.locality {
                                        if !name.isEmpty {
                                            name += ", "
                                        }
                                        name += locality
                                    }
                                    
                                    if name.isEmpty {
                                        name = "Selected Location"
                                    }
                                    
                                    locationName = name
                                } else {
                                    locationName = "Selected Location"
                                }
                                
                                isPresented = false
                            }
                        } else {
                            isPresented = false
                        }
                    }
                    .foregroundColor(Color(hex: "3D8BFD"))
                }
                .padding()
                .background(Color(hex: "F8F9FA"))
                .shadow(color: Color(hex: "ADB5BD").opacity(0.3), radius: 2, x: 0, y: 1)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "3D8BFD"))
                    
                    TextField("Search for a location", text: $searchText)
                        .foregroundColor(Color(hex: "212529"))
                        .onSubmit {
                            searchForLocation()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "6C757D"))
                        }
                    }
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color(hex: "ADB5BD").opacity(0.2), radius: 3, x: 0, y: 1)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Search results
                if !searchResults.isEmpty {
                    List {
                        ForEach(searchResults, id: \.self) { mapItem in
                            Button(action: {
                                let coordinate = mapItem.placemark.coordinate
                                region = MKCoordinateRegion(
                                    center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                                selectedLocation = coordinate
                                
                                if let name = mapItem.name {
                                    locationName = name
                                }
                                
                                searchResults = []
                                searchText = ""
                            }) {
                                VStack(alignment: .leading) {
                                    Text(mapItem.name ?? "Unknown Location")
                                        .foregroundColor(Color(hex: "212529"))
                                    
                                    if let address = mapItem.placemark.thoroughfare {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(Color(hex: "6C757D"))
                                    }
                                }
                            }
                            .listRowBackground(Color.white)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                
                // Map view
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: selectedLocation.map { [MapPin(coordinate: $0)] } ?? []) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(Color(hex: "DC3545"))
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "DC3545"))
                                .offset(y: -5)
                        }
                    }
                }
                .overlay(
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(selectedLocation == nil ? Color(hex: "DC3545") : .clear)
                        
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.caption)
                            .foregroundColor(selectedLocation == nil ? Color(hex: "DC3545") : .clear)
                            .offset(y: -5)
                    }
                    .opacity(isDragging ? 1 : 0.8)
                )
                .gesture(
                    DragGesture()
                        .onChanged { _ in
                            isDragging = true
                            selectedLocation = nil
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
                .onTapGesture { location in
                    let coordinate = region.center
                    selectedLocation = coordinate
                    
                    let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    geocoder.reverseGeocodeLocation(location) { placemarks, error in
                        if let placemark = placemarks?.first {
                            var name = ""
                            
                            if let thoroughfare = placemark.thoroughfare {
                                name += thoroughfare
                            }
                            
                            if let locality = placemark.locality {
                                if !name.isEmpty {
                                    name += ", "
                                }
                                name += locality
                            }
                            
                            if name.isEmpty {
                                name = "Selected Location"
                            }
                            
                            locationName = name
                        } else {
                            locationName = "Selected Location"
                        }
                    }
                }
                
                // Helper text
                Text(selectedLocation == nil ? "Tap on the map to select a location" : "Location selected")
                    .font(.caption)
                    .foregroundColor(Color(hex: "495057"))
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(color: Color(hex: "ADB5BD").opacity(0.3), radius: 3, x: 0, y: 2)
                    .padding(.bottom, 8)
            }
        }
    }
    
    private func searchForLocation() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                return
            }
            
            searchResults = response.mapItems
        }
    }
}

#Preview {
    AddCrimeFormView()
        .environmentObject(CrimeViewModel())
}
