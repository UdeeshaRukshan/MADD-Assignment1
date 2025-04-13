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
    
    @State private var region: MKCoordinateRegion
    
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
        VStack {
            Map(coordinateRegion: $region, annotationItems: crime.locations) { location in
                MapPin(coordinate: location.coordinate, tint: .red)
            }
            .frame(height: 300)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Title: \(crime.title)")
                    .font(.headline)
                Text("Description: \(crime.description)")
                Text("Category: \(crime.category.rawValue)")
                Text("Severity: \(crime.severity)")
                Text("Priority: \(crime.isPriority ? "Yes" : "No")")
                Text("Date: \(crime.date.formatted())")
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Crime Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CrimeDetailView(crime: CriminalActivity.sample)
}