//
//  Assignment1App.swift
//  Assignment1
//
//  Created by Udeesha Rukshan on 2025-04-02.
//

import SwiftUI
import Firebase

@main
struct Assignment1App: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Create a shared instance of CrimeViewModel
    @StateObject private var crimeViewModel = CrimeViewModel()
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some Scene {
        WindowGroup {
            InitialScreen()
                .environmentObject(crimeViewModel) // Inject CrimeViewModel into the environment
        .onAppear {
                    // Request notification permissions when app launches
                    NotificationService.shared.requestPermission()
                }
        }
    }
}


#Preview {
    InitialScreen()
        .environmentObject(CrimeViewModel()) // Ensure previews also inject the environment object
}
