//
//  CrimeViewModel.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Firebase
import FirebaseFirestore

class CrimeViewModel: ObservableObject {
    @Published var criminalActivities: [CriminalActivity] = []
    @Published var selectedActivity: CriminalActivity?
    @Published var selectedLocation: CrimeLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var notificationMessage: String?
    
    private var db = Firestore.firestore()
    
    init() {
        fetchCrimes()
    }
    
    func fetchCrimes() {
        db.collection("crimes").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else {
                print("Error fetching crimes: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Convert Firebase documents to CriminalActivity objects
            self.criminalActivities = documents.compactMap { document -> CriminalActivity? in
                let data = document.data()
                
                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let categoryRaw = data["category"] as? String,
                      let category = CrimeCategory(rawValue: categoryRaw),
                      let dateTimestamp = data["date"] as? Timestamp,
                      let severity = data["severity"] as? Int,
                      let isPriority = data["isPriority"] as? Bool,
                      let locationsData = data["locations"] as? [[String: Any]] else {
                    return nil
                }
                
                // Convert timestamp to Date
                let date = dateTimestamp.dateValue()
                
                // Convert locations data
                let locations = locationsData.compactMap { locationData -> CrimeLocation? in
                    guard let title = locationData["title"] as? String,
                          let description = locationData["description"] as? String,
                          let latitude = locationData["latitude"] as? Double,
                          let longitude = locationData["longitude"] as? Double,
                          let address = locationData["address"] as? String,
                          let timestampData = locationData["timestamp"] as? Timestamp,
                          let evidencePhotos = locationData["evidencePhotos"] as? [String],
                          let witnesses = locationData["witnesses"] as? Int,
                          let isSolved = locationData["isSolved"] as? Bool else {
                        return nil
                    }
                    
                    return CrimeLocation(
                        title: title,
                        description: description,
                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                        address: address,
                        timestamp: timestampData.dateValue(),
                        evidencePhotos: evidencePhotos,
                        witnesses: witnesses,
                        isSolved: isSolved
                    )
                }
                
                return CriminalActivity(
                    title: title,
                    description: description,
                    category: category,
                    date: date,
                    locations: locations,
                    severity: severity,
                    isPriority: isPriority
                )
            }
        }
    }
    
    func addCrime(_ crime: CriminalActivity) {
        // Convert CriminalActivity to Firebase document
        var crimeData: [String: Any] = [
            "title": crime.title,
            "description": crime.description,
            "category": crime.category.rawValue,
            "date": Timestamp(date: crime.date),
            "severity": crime.severity,
            "isPriority": crime.isPriority
        ]
        
        // Convert locations to dictionaries
        let locationsData = crime.locations.map { location -> [String: Any] in
            return [
                "title": location.title,
                "description": location.description,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "address": location.address,
                "timestamp": Timestamp(date: location.timestamp),
                "evidencePhotos": location.evidencePhotos,
                "witnesses": location.witnesses,
                "isSolved": location.isSolved
            ]
        }
        
        crimeData["locations"] = locationsData
        
        // Add to Firestore
        db.collection("crimes").addDocument(data: crimeData) { [weak self] error in
            if let error = error {
                print("Error adding crime: \(error.localizedDescription)")
                return
            }
            
            // No need to manually append to array since we're using a snapshot listener
            self?.triggerNotification(for: crime)
        }
         if crime.severity >= 2{
        let message = "High priority crime reported: \(crime.title)"
        showNotification(message: message)
    }
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
            
            withAnimation {
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
    // Add these methods to your existing CrimeViewModel class

// Inside your CrimeViewModel class:
func showNotification(message: String, sendSystemNotification: Bool = true) {
    // Show in-app notification
    self.notificationMessage = message
    
    // Also send system notification if requested
    if sendSystemNotification {
        NotificationService.shared.scheduleNotification(
            title: "Safety Alert",
            body: message
        )
    }
}


    private func triggerNotification(for crime: CriminalActivity) {
        notificationMessage = "New Crime Reported: \(crime.title)"
        
        // Automatically clear the notification after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.notificationMessage = nil
        }
    }
}