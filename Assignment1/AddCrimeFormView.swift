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
    @State private var showingCategoryInfo = false
    
    // Location selection
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingMap = false
    @State private var locationName: String = "No location selected"
    
    // Sketch feature
    @State private var crimeSketch: UIImage?
    @State private var showingSketchView = false
    
    // Category descriptions for help tooltip
    private let categoryDescriptions: [CrimeCategory: String] = [
        .theft: "Includes pickpocketing, shoplifting, vehicle theft, etc.",
        .assault: "Physical attacks or threats against individuals",
        .vandalism: "Destruction or defacement of property",
        .other: "Any crime that doesn't fit the above categories"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark gradient background to match other components
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "141E30"),
                        Color(hex: "243B55")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Main content
                Form {
                    Section(header: 
                        Text("Crime Details")
                            .foregroundColor(Color(hex: "64B5F6"))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .center)

                    ) {
                        Text("Title")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        TextField("E.g., Car Break-in, Store Robbery", text: $title)
                            .foregroundColor(.white) // This sets the text color
                            .accentColor(.white) // This sets the cursor color
                            .placeholderStyle(color: .white.opacity(0.7)) // Custom modifier for placeholder
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    .opacity(title.isEmpty ? 0.6 : 1)
                            )
                        
                        Text("Be specific with the incident title")
                            .font(.caption)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 4)
                        
                        Text("Description")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        TextField("Provide details about what happened, who was involved, etc.", text: $description, axis: .vertical)
                            .lineLimit(5...10)
                            .foregroundColor(.white) // This sets the text color
                            .accentColor(.white) // This sets the cursor color
                            .placeholderStyle(color: .white.opacity(0.7)) // Custom modifier for placeholder
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                    .opacity(description.isEmpty ? 0.6 : 1)
                            )
                        
                        Text("Include relevant details like time of day, number of suspects, etc.")
                            .font(.caption)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 8)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Category")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Select the most appropriate category")
                                    .font(.caption)
                                    .foregroundColor(Color.white)
                            }
                            
                            Spacer()
                            
                            Button(action: { showingCategoryInfo.toggle() }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Color(hex: "64B5F6"))
                            }
                        }
                        
                        Picker("", selection: $category) {
                            ForEach(CrimeCategory.allCases, id: \.self) { category in
                                HStack {
                                    Text(category.rawValue)
                                        .foregroundColor(.white)
                                    Image(systemName: categoryIcon(for: category))
                                        .foregroundColor(categoryColor(for: category))
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        
                        if showingCategoryInfo {
                            Text(categoryDescriptions[category] ?? "")
                                .font(.callout)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: "1A2133"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(categoryColor(for: category).opacity(0.5), lineWidth: 1)
                                )
                                .padding(.vertical, 4)
                                .transition(.opacity)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Severity Level: \(severity)")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Text(severityDescription(for: severity))
                                .font(.caption)
                                .foregroundColor(Color.gray)
                            
                            HStack {
                                Text("Low")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "28A745"))
                                
                                Spacer()
                                
                                Text("High")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "DC3545"))
                            }
                            
                            Slider(value: .init(
                                get: { Double(severity) },
                                set: { severity = Int($0) }
                            ), in: 1...5, step: 1)
                            .accentColor(severityColor(for: severity))
                        }
                    }
                    .listRowBackground(Color(hex: "1A2133"))
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 4)
                    
                    Section(header: 
                        Text("Location")
                            .foregroundColor(Color(hex: "64B5F6"))
                            .fontWeight(.semibold)
                    ) {
                        VStack {
                            Button(action: {
                                showingMap = true
                            }) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color(hex: "64B5F6"))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedLocation == nil ? "Select Location on Map" : locationName)
                                            .foregroundColor(selectedLocation == nil ? Color.gray : .white)
                                            .fontWeight(selectedLocation == nil ? .regular : .medium)
                                        
                                        if selectedLocation == nil {
                                            Text("Tap to choose incident location")
                                                .font(.caption)
                                                .foregroundColor(Color.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "1A2133"))
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                )
                            }
                            
                            if let location = selectedLocation {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Coordinates:")
                                            .font(.subheadline)
                                            .foregroundColor(Color.gray)
                                        
                                        Text("\(String(format: "%.6f", location.latitude)), \(String(format: "%.6f", location.longitude))")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
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
                                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "1A2133"))
                                )
                                .padding(.top, 8)
                            }
                        }
                    }
                    .listRowBackground(Color(hex: "1A2133"))
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 4)
                    
                    // Sketch section
                    Section(header: 
                        Text("Crime Scene Sketch")
                            .foregroundColor(Color(hex: "64B5F6"))
                            .fontWeight(.semibold)
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Button(action: {
                                showingSketchView = true
                            }) {
                                if let sketch = crimeSketch {
                                    Image(uiImage: sketch)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        )
                                } else {
                                    HStack {
                                        Image(systemName: "pencil.and.outline")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "64B5F6"))
                                        
                                        Text("Create Sketch")
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hex: "1A2133"))
                                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    )
                                }
                            }
                            
                            if crimeSketch != nil {
                                Text("Tap the sketch to edit")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.7))
                            } else {
                                Text("Use Apple Pencil to sketch the crime scene (iPad only)")
                                    .font(.caption)
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section {
                        Button(action: addCrime) {
                            HStack {
                                Spacer()
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 18, weight: .bold))
                                Text("SUBMIT CRIME REPORT")
                                    .font(.headline)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "DC3545"),
                                        Color(hex: "C82333")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: Color(hex: "DC3545").opacity(0.4), radius: 5, x: 0, y: 3)
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(hex: "1A2133"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingMap) {
                DarkLocationPickerView(
                    region: $region,
                    selectedLocation: $selectedLocation,
                    locationName: $locationName,
                    isPresented: $showingMap
                )
            }
            .sheet(isPresented: $showingSketchView) {
                CrimeSketchView(savedSketch: $crimeSketch)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "64B5F6"))
                }
            }
        }
    }
    
    private func addCrime() {
        guard let location = selectedLocation else { return }
        
        // Store sketch if available
        var evidencePhotos: [String] = []
        if let sketch = crimeSketch {
            // Convert sketch to base64 string for storage
            if let imageData = sketch.jpegData(compressionQuality: 0.7) {
                let base64String = imageData.base64EncodedString()
                evidencePhotos.append(base64String)
            }
        }
        
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
                    evidencePhotos: evidencePhotos,
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
    
    // Helper functions for category visuals
    private func categoryIcon(for category: CrimeCategory) -> String {
        switch category {
        case .theft: return "bag.fill.badge.minus"
        case .assault: return "person.fill.questionmark"
        case .vandalism: return "hammer.fill"
        case .other: return "questionmark.circle.fill"
        default: return "questionmark.circle.fill" // Add this default case
        }
    }
    
    private func categoryColor(for category: CrimeCategory) -> Color {
        switch category {
        case .theft: return Color(hex: "FFC107")
        case .assault: return Color(hex: "DC3545")
        case .vandalism: return Color(hex: "6C757D")
        case .other: return Color(hex: "6C757D")
        default: return Color(hex: "6C757D") // Add this default case
        }
    }
    
    // Helper function for severity descriptions
    private func severityDescription(for level: Int) -> String {
        switch level {
        case 1: return "Minor incident with little to no threat"
        case 2: return "Low-level incident with minimal threat"
        case 3: return "Moderate incident with some potential risk"
        case 4: return "Serious incident with significant risk"
        case 5: return "Critical incident requiring immediate action"
        default: return ""
        }
    }
    
    // Helper function for severity colors
    private func severityColor(for level: Int) -> Color {
        switch level {
        case 1: return Color(hex: "28A745")
        case 2: return Color(hex: "5CB85C")
        case 3: return Color(hex: "FFC107")
        case 4: return Color(hex: "F0AD4E")
        case 5: return Color(hex: "DC3545")
        default: return Color(hex: "6C757D")
        }
    }
}

// Helper struct for map pins
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Dark-themed Location Picker View
struct DarkLocationPickerView: View {
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
            // Dark background to match theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55")
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
                    .foregroundColor(Color(hex: "64B5F6"))
                    
                    Spacer()
                    
                    Text("Select Location")
                        .font(.headline)
                        .foregroundColor(.white)
                    
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
                    .foregroundColor(Color(hex: "64B5F6"))
                }
                .padding()
                .background(Color(hex: "1A2133"))
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "64B5F6"))
                    
                    TextField("Search for a location", text: $searchText)
                        .foregroundColor(.white)
                        .onSubmit {
                            searchForLocation()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(hex: "1A2133"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Search results with dark theme
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
                                        .foregroundColor(.white)
                                    
                                    if let address = mapItem.placemark.thoroughfare {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(Color.gray)
                                    }
                                }
                            }
                            .listRowBackground(Color(hex: "1A2133"))
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(hex: "1A2133"))
                }
                
                // Map view remains largely the same
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
                
                // Helper text with dark theme
                Text(selectedLocation == nil ? "Tap on the map to select a location" : "Location selected")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "1A2133").opacity(0.9))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                    .padding(.bottom, 8)
            }
        }
    }
    
    private func searchForLocation() {
        // Search functionality remains unchanged
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

// Add this extension at the bottom of your file
extension View {
    func placeholderStyle(color: Color) -> some View {
        self.modifier(PlaceholderStyleModifier(color: color))
    }
}

struct PlaceholderStyleModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                UITextField.appearance().attributedPlaceholder = NSAttributedString(
                    string: " ", // This is a hack to make it work
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor(color)]
                )
            }
    }
}

#Preview {
    AddCrimeFormView()
        .environmentObject(CrimeViewModel())
}
