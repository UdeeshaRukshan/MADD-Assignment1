//
//  PlaceholderView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI
import MapKit

struct PlaceholderView: View {
    @EnvironmentObject var viewModel: CrimeViewModel
    @State private var isShowingAddCrime = false
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    // Add this computed property for filtered crimes
    private var filteredCrimes: [CriminalActivity] {
        if searchText.isEmpty {
            return viewModel.criminalActivities
        } else {
            return viewModel.criminalActivities.filter { crime in
                crime.title.localizedCaseInsensitiveContains(searchText) ||
                crime.description.localizedCaseInsensitiveContains(searchText) ||
                crime.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                crime.locations.contains(where: { 
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.address.localizedCaseInsensitiveContains(searchText)
                })
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
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
                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CRIME MAP")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(Color(hex: "64B5F6"))
                                .kerning(2)
                            
                            Text("Stay Safe Today")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: NotificationContentView(viewModel: viewModel)) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                // Add notification badge if there are active notifications
                                .overlay(
                                    Group {
                                        if viewModel.notificationMessage != nil {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 12, height: 12)
                                                .offset(x: 10, y: -10)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "64B5F6"))
                        
                        TextField("Search crimes...", text: $searchText)
                            .foregroundColor(.white)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    // Tab selector
                    HStack(spacing: 0) {
                        ForEach(["Recent", "Nearby", "Alerts"], id: \.self) { tab in
                            Button(action: {
                                withAnimation { selectedTab = ["Recent", "Nearby", "Alerts"].firstIndex(of: tab) ?? 0 }
                            }) {
                                VStack(spacing: 8) {
                                    Text(tab)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedTab == ["Recent", "Nearby", "Alerts"].firstIndex(of: tab) ? .white : .gray)
                                    
                                    if selectedTab == ["Recent", "Nearby", "Alerts"].firstIndex(of: tab) {
                                        Rectangle()
                                            .fill(Color(hex: "64B5F6"))
                                            .frame(height: 3)
                                            .matchedGeometryEffect(id: "tab", in: NamespaceWrapper.namespace)
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Tab content area
                    if selectedTab == 0 { // Recent
                        // Crime list
                        ScrollView {
                            if searchText.isEmpty || !filteredCrimes.isEmpty {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredCrimes) { crime in
                                        NavigationLink(destination: CrimeDetailView(crime: crime)) {
                                            CrimeCard(crime: crime)
                                                .transition(.scale)
                                        }
                                    }
                                }
                                .padding()
                            } else {
                                // Show empty search results message
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(Color(hex: "64B5F6").opacity(0.8))
                                        .padding()
                                    
                                    Text("No Results Found")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Try another search term")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            }
                        }
                    } else if selectedTab == 1 { // Nearby
                        ScrollView {
                            VStack(spacing: 20) {
                                // Map view for nearby crimes
                                Map(coordinateRegion: .constant(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 6.9311, longitude: 79.9794),
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )))
                                .frame(height: 200)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                // Nearby crimes list - filter this too
                                LazyVStack(spacing: 16) {
                                    if searchText.isEmpty || !filteredCrimes.isEmpty {
                                        ForEach(filteredCrimes.prefix(3)) { crime in
                                            NavigationLink(destination: CrimeDetailView(crime: crime)) {
                                                CrimeCard(crime: crime)
                                                    .transition(.scale)
                                            }
                                        }
                                    } else {
                                        // Show empty search results message
                                        Text("No nearby results match your search")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 20)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else { // Alerts (selectedTab == 2)
                        ScrollView {
                            // Filter priority crimes
                            let filteredPriorityCrimes = filteredCrimes.filter { $0.isPriority }
                            
                            if searchText.isEmpty || !filteredPriorityCrimes.isEmpty {
                                VStack(spacing: 16) {
                                    ForEach(filteredPriorityCrimes) { crime in
                                        NavigationLink(destination: CrimeDetailView(crime: crime)) {
                                            CrimeCard(crime: crime)
                                                .transition(.scale)
                                        }
                                    }
                                }
                                .padding()
                            } else if !searchText.isEmpty {
                                // Show empty search results for priority crimes
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(Color(hex: "64B5F6").opacity(0.8))
                                        .padding()
                                    
                                    Text("No Priority Alerts Found")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("No priority crimes match your search")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else if filteredPriorityCrimes.isEmpty {
                                // Original empty state for no priority crimes
                                VStack(spacing: 20) {
                                    Image(systemName: "checkmark.shield.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(Color(hex: "64B5F6").opacity(0.8))
                                        .padding()
                                    
                                    Text("No Priority Alerts")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("You're all caught up!")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Floating action button for "Report a Crime"
                    Button(action: { isShowingAddCrime = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 20))
                            
                            Text("REPORT A CRIME")
                                .font(.system(size: 16, weight: .bold))
                                .kerning(1)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FF416C"),
                                    Color(hex: "FF4B2B")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(30)
                        .shadow(color: Color(hex: "FF416C").opacity(0.5), radius: 15, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingAddCrime) {
                AddCrimeFormView()
            }
        }
    }
}

// Crime card component
struct CrimeCard: View {
    let crime: CriminalActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with category and severity
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: crime.category.icon)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(crime.category.color.opacity(0.8))
                        .clipShape(Circle())
                    
                    Text(crime.category.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(crime.category.color)
                }
                
                Spacer()
                
                // Severity indicator
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Circle()
                            .fill(index <= crime.severity ? Color(hex: "FF416C") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                if crime.isPriority {
                    Text("PRIORITY")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FF416C"))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "1A2133"))
            
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                Text(crime.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(crime.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                HStack(spacing: 16) {
                    Label("\(crime.locations.count) locations", systemImage: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .medium))
                    
                    Label(crime.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "64B5F6"))
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "243B55"))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Helpers for the design

// Namespace for animations
struct NamespaceWrapper {
    @Namespace static var namespace
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    PlaceholderView()
        .environmentObject(CrimeViewModel())
}