//
//  CrimeViewModel.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI // Add this import to use withAnimation

class CrimeViewModel: ObservableObject {
    @Published var criminalActivities: [CriminalActivity] = []
    @Published var selectedActivity: CriminalActivity?
    @Published var selectedLocation: CrimeLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var notificationMessage: String? // For notifications
    
    init() {
        loadSampleData()
    }
    
    func selectActivity(_ activity: CriminalActivity) {
        selectedActivity = activity
        
        // Calculate the region to encompass all locations
        if let locations = selectedActivity?.locations, !locations.isEmpty {
            let coordinates = locations.map { $0.coordinate }
            let minLat = coordinates.map { $0.latitude }.min() ?? 0
            let maxLat = coordinates.map { $0.latitude }.max() ?? 0
            let minLong = coordinates.map { $0.longitude }.min() ?? 0
            let maxLong = coordinates.map { $0.longitude }.max() ?? 0
            
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLong + maxLong) / 2
            )
            
            // Add some padding
            let latDelta = (maxLat - minLat) * 1.5
            let longDelta = (maxLong - minLong) * 1.5
            
            withAnimation { // Now this will work
                region = MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(
                        latitudeDelta: max(latDelta, 0.01),
                        longitudeDelta: max(longDelta, 0.01)
                    )
                )
            }
        }
    }
    
    func clearSelection() {
        selectedActivity = nil
        selectedLocation = nil
    }
    
    func addCrime(_ crime: CriminalActivity) {
        criminalActivities.append(crime)
        triggerNotification(for: crime)
    }
    
    private func triggerNotification(for crime: CriminalActivity) {
        notificationMessage = "New Crime Reported: \(crime.title)"
        
        // Automatically clear the notification after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.notificationMessage = nil
        }
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        criminalActivities = [
            CriminalActivity(
                title: "Robbery",
                description: "A robbery occurred at a local store.",
                category: .theft,
                date: Date(),
                locations: [
                    CrimeLocation(
                        title: "Store",
                        description: "The robbery happened here.",
                        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                        address: "123 Main St, San Francisco, CA",
                        timestamp: Date(),
                        evidencePhotos: [],
                        witnesses: 2,
                        isSolved: false
                    )
                ],
                severity: 4,
                isPriority: true
            ),
            CriminalActivity(
                title: "Vandalism",
                description: "Graffiti on public property.",
                category: .vandalism,
                date: Date(),
                locations: [
                    CrimeLocation(
                        title: "Park",
                        description: "Graffiti was found here.",
                        coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                        address: "456 Park Ave, San Francisco, CA",
                        timestamp: Date(),
                        evidencePhotos: [],
                        witnesses: 0,
                        isSolved: false
                    )
                ],
                severity: 2,
                isPriority: false
            )
        ]
    }
}