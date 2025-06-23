//
//  CrimeDetailView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI
import MapKit

struct CrimeDetailView: View {
    var crime: CriminalActivity
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion
    @State private var selectedLocationIndex = 0
    @State private var showFullDescription = false
    
    // Add keyboard shortcut states
    @State private var showKeyboardShortcutHelp = false
    @State private var isPresentingInNewWindow = false
    
    init(crime: CriminalActivity) {
        self.crime = crime
        if let firstLocation = crime.locations.first {
            _region = State(initialValue: MKCoordinateRegion(
                center: firstLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                    // Custom header
                    ZStack(alignment: .top) {
                        // Map view
                        Map(coordinateRegion: $region, annotationItems: crime.locations) { location in
                            MapAnnotation(coordinate: location.coordinate) {
                                VStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                        .background(Circle().fill(Color.white).frame(width: 18, height: 18))
                                        .shadow(radius: 2)
                                    
                                    if crime.locations.count > 1 {
                                        Text(location.title)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(4)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        .frame(height: 280)
                        .cornerRadius(0)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.black.opacity(0.5), location: 0),
                                    .init(color: Color.black.opacity(0), location: 0.3)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Back button
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(Color.black.opacity(0.3)))
                            }
                            .padding(.leading, 16)
                            .padding(.top, 16)
                            
                            Spacer()
                            
                            // Share button
                            Button(action: {
                                // Share functionality would go here
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(Color.black.opacity(0.3)))
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                        }
                    }
                    
                    // Main content
                    VStack(spacing: 0) {
                        // Section 1: Crime header
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                // Title and category
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(crime.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        HStack(spacing: 8) {
                                            Image(systemName: crime.category.icon)
                                                .foregroundColor(crime.category.color)
                                            
                                            Text(crime.category.rawValue)
                                                .font(.subheadline)
                                                .foregroundColor(crime.category.color)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(crime.category.color.opacity(0.2))
                                        .cornerRadius(20)
                                        
                                        if crime.isPriority {
                                            HStack(spacing: 4) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                Text("Priority")
                                            }
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color(hex: "FF416C"))
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                // Severity indicator
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Severity")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 4) {
                                        ForEach(1...5, id: \.self) { index in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(index <= crime.severity ? 
                                                    (crime.severity >= 4 ? Color(hex: "FF416C") : Color(hex: "64B5F6")) : 
                                                    Color.gray.opacity(0.3))
                                                .frame(width: 8, height: index <= crime.severity ? 24 : 12)
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Date and time
                            HStack {
                                Label {
                                    Text(crime.date.formatted(date: .long, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                } icon: {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color(hex: "64B5F6"))
                                }
                                
                                Spacer()
                                
                                Label {
                                    Text("\(crime.locations.count) location\(crime.locations.count > 1 ? "s" : "")")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                } icon: {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(Color(hex: "64B5F6"))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .background(Color(hex: "1A2133"))
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .offset(y: -20)
                        
                        // Section 2: Description
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DESCRIPTION")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "64B5F6"))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(crime.description)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(showFullDescription ? nil : 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if !showFullDescription && crime.description.count > 200 {
                                    Button(action: {
                                        withAnimation {
                                            showFullDescription = true
                                        }
                                    }) {
                                        Text("Read more")
                                            .font(.subheadline)
                                            .foregroundColor(Color(hex: "64B5F6"))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                            .frame(minHeight: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                        .background(Color(hex: "1A2133").opacity(0.7))
                        .frame(maxWidth: .infinity)
                        
                        // Section 3: Location Details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LOCATION DETAILS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "64B5F6"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if crime.locations.count > 1 {
                                // Location selector
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<crime.locations.count, id: \.self) { index in
                                            Button(action: {
                                                selectedLocationIndex = index
                                                withAnimation {
                                                    region = MKCoordinateRegion(
                                                        center: crime.locations[index].coordinate,
                                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                                    )
                                                }
                                            }) {
                                                Text(crime.locations[index].title)
                                                    .font(.subheadline)
                                                    .foregroundColor(selectedLocationIndex == index ? .white : .gray)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .fill(selectedLocationIndex == index ? 
                                                                 Color(hex: "64B5F6").opacity(0.2) : Color.clear)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .stroke(selectedLocationIndex == index ? 
                                                                           Color(hex: "64B5F6") : Color.gray.opacity(0.5), 
                                                                           lineWidth: 1)
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                                .frame(height: 44)
                            }
                            
                            // Selected location details
                            if !crime.locations.isEmpty {
                                let location = crime.locations[selectedLocationIndex]
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    // Address
                                    HStack(alignment: .top) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(Color(hex: "64B5F6"))
                                            .frame(width: 24)
                                        
                                        Text(location.address)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    // Time
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(Color(hex: "64B5F6"))
                                            .frame(width: 24)
                                        
                                        Text(location.timestamp.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    // Witnesses
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(Color(hex: "64B5F6"))
                                            .frame(width: 24)
                                        
                                        Text("\(location.witnesses) witness\(location.witnesses != 1 ? "es" : "")")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    // Status
                                    HStack {
                                        Image(systemName: location.isSolved ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                            .foregroundColor(location.isSolved ? .green : .orange)
                                            .frame(width: 24)
                                        
                                        Text(location.isSolved ? "Case closed" : "Under investigation")
                                            .font(.subheadline)
                                            .foregroundColor(location.isSolved ? .green : .orange)
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.vertical, 8)
                                    
                                    // Description
                                    Text(location.description)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                }
                                .padding(16)
                                .background(Color(hex: "243B55").opacity(0.5))
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Add sketch display if available - Fix conditional binding
                            if !crime.locations.isEmpty {
                                let location = crime.locations[selectedLocationIndex]
                                if !location.evidencePhotos.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("EVIDENCE SKETCHES")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(hex: "64B5F6"))
                                            .padding(.top, 16)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(location.evidencePhotos, id: \.self) { base64String in
                                                    if let data = Data(base64Encoded: base64String),
                                                       let image = UIImage(data: data) {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 160)
                                                            .cornerRadius(8)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                            )
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 8)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .background(Color(hex: "1A2133"))
                        .frame(maxWidth: .infinity)
                        
                        // Section 4: Actions
                        VStack(spacing: 16) {
                            // Report button
                            Button(action: {
                                // Report additional information
                            }) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                    Text("Report Additional Information")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "64B5F6"), Color(hex: "1976D2")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            // Alert button
                            Button(action: {
                                // Set up alert for this area
                            }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                    Text("Set Up Alerts For This Area")
                                }
                                .font(.headline)
                                .foregroundColor(Color(hex: "1976D2"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "1976D2").opacity(0.5), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .background(Color(hex: "141E30"))
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
        .alert(isPresented: $showKeyboardShortcutHelp) {
            Alert(
                title: Text("Keyboard Shortcuts"),
                message: Text("⌘+N: Open in new window\n⌘+R: Report additional info\n⌘+E: Set up alerts\n⌘+D: View on map\n⌘+F: Toggle description\n⌘+W: Close this view"),
                dismissButton: .default(Text("OK"))
            )
        }
        // Replace keyCommands with onAppear to set up the key commands
        .onAppear {
            setupKeyCommands()
        }
    }
    
    // Add this private method to set up the UIKeyCommands
    private func setupKeyCommands() {
        // Since we can't add key commands directly to a SwiftUI view,
        // we can use UIApplication.shared to handle them
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Register for keyboard shortcuts via responder chain
            DispatchQueue.main.async {
                let newWindowSelector = Selector(("openInNewWindow"))
                let reportSelector = Selector(("reportAdditionalInfo"))
                let toggleSelector = Selector(("toggleDescription"))
                let closeSelector = Selector(("closeView"))
                
                // We need to use UIKeyCommand at the UIKit level, not directly in SwiftUI
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController?.addKeyCommand(
                        UIKeyCommand(input: "n", modifierFlags: .command, action: newWindowSelector)
                    )
                    window.rootViewController?.addKeyCommand(
                        UIKeyCommand(input: "r", modifierFlags: .command, action: reportSelector)
                    )
                    window.rootViewController?.addKeyCommand(
                        UIKeyCommand(input: "f", modifierFlags: .command, action: toggleSelector)
                    )
                    window.rootViewController?.addKeyCommand(
                        UIKeyCommand(input: "w", modifierFlags: .command, action: closeSelector)
                    )
                }
            }
        }
    }
    
    // Replace @objc methods with regular methods
    private func openInNewWindow() {
        isPresentingInNewWindow = true
        
        let newWindowView = NewWindowView(viewType: .crimeDetail, crime: crime)
        UIApplication.shared.createNewWindow(for: newWindowView)
    }
    
    private func reportAdditionalInfo() {
        // Report additional information logic
    }
    
    private func toggleDescription() {
        withAnimation {
            showFullDescription.toggle()
        }
    }
    
    private func closeView() {
        dismiss()
    }
}

// Custom extensions to support the UI
extension CrimeCategory {
    var icon: String {
        switch self {
        case .theft: return "bag.fill"
        case .assault: return "person.fill.xmark"
        case .vandalism: return "hammer.fill"
        case .other: return "exclamationmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .theft: return Color(hex: "FF9800")
        case .assault: return Color(hex: "F44336")
        case .vandalism: return Color(hex: "9C27B0")
        case .other: return Color(hex: "607D8B")
        }
    }
}

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Preview
#Preview {
    NavigationView {
        CrimeDetailView(crime: CriminalActivity.sample)
    }
}
