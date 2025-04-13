//
//  CrimeModels.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import Foundation
import CoreLocation
import SwiftUI

struct CriminalActivity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: CrimeCategory
    let date: Date
    let locations: [CrimeLocation]
    let severity: Int // 1-5
    let isPriority: Bool
    
    static let sample = CriminalActivity(
        title: "Sample Crime",
        description: "This is a sample crime for preview purposes.",
        category: .theft,
        date: Date(),
        locations: [
            CrimeLocation(
                title: "Sample Location",
                description: "This is a sample location.",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                address: "123 Sample St, San Francisco, CA",
                timestamp: Date(),
                evidencePhotos: [],
                witnesses: 1,
                isSolved: false
            )
        ],
        severity: 3,
        isPriority: false
    )
}

struct CrimeLocation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let timestamp: Date
    let evidencePhotos: [String] // Image names
    let witnesses: Int
    let isSolved: Bool
}

enum CrimeCategory: String, CaseIterable {
    case theft = "Theft"
    case assault = "Assault"
    case vandalism = "Vandalism"
    case drugRelated = "Drug Related"
    case fraud = "Fraud"
    case other = "Other"
    
    var color: Color {
        switch self {
        case .theft: return .blue
        case .assault: return .red
        case .vandalism: return .purple
        case .drugRelated: return .green
        case .fraud: return .orange
        case .other: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .theft: return "bag.fill"
        case .assault: return "person.fill.xmark"
        case .vandalism: return "hammer.fill"
        case .drugRelated: return "pills.fill"
        case .fraud: return "creditcard.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}