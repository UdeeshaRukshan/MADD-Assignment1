//
//  NotificationBanner.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI

struct NotificationBanner: View {
    var message: String
    
    var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
            .padding()
    }
}

struct NotificationContentView: View { // Renamed from ContentView to NotificationContentView
    @ObservedObject var viewModel: CrimeViewModel // Replaced ViewModel with CrimeViewModel
    
    var body: some View {
        VStack {
            if let message = viewModel.notificationMessage {
                NotificationBanner(message: message)
            }
            List(viewModel.criminalActivities) { crime in
                VStack(alignment: .leading) {
                    Text(crime.title)
                        .font(.headline)
                    Text(crime.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    NotificationContentView(viewModel: CrimeViewModel())
}