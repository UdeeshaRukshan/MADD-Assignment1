//
//  AddCrimeFormView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI
import CoreLocation

struct AddCrimeFormView: View {
    @EnvironmentObject var viewModel: CrimeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: CrimeCategory = .other
    @State private var severity: Int = 1
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Crime Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                Picker("Category", selection: $category) {
                    ForEach(CrimeCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                Stepper("Severity: \(severity)", value: $severity, in: 1...5)
            }
            
            Section(header: Text("Location")) {
                TextField("Latitude", text: $latitude)
                    .keyboardType(.decimalPad)
                TextField("Longitude", text: $longitude)
                    .keyboardType(.decimalPad)
            }
            
            Button(action: addCrime) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Report a Crime")
    }
    
    private func addCrime() {
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            // Show an alert if coordinates are invalid
            return
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
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    address: "Unknown Address",
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

#Preview {
    AddCrimeFormView()
        .environmentObject(CrimeViewModel())
}