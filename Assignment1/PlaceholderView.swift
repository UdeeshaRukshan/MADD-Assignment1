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
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.criminalActivities) { crime in
                    NavigationLink(destination: CrimeDetailView(crime: crime)) {
                        VStack(alignment: .leading) {
                            Text(crime.title)
                                .font(.headline)
                            Text(crime.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationTitle("Crimes")
                
                NavigationLink(destination: AddCrimeFormView()) {
                    Text("Report a Crime")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    PlaceholderView()
        .environmentObject(CrimeViewModel())
}