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
    
    // Determine if this is an admin user and platform type
    @State private var isAdminMode = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                #if os(visionOS)
                // On visionOS, we'll use our specialized admin monitoring views
                if isAdminMode {
                    VisionOSMainView(selectedTab: .constant(.dashboard))
                        .environmentObject(crimeViewModel)
                } else {
                    // User mode still shows login screen first
                    InitialScreen()
                        .environmentObject(crimeViewModel)
                        .onAppear {
                            // Request notification permissions when app launches
                            NotificationService.shared.requestPermission()
                        }
                }
                #else
                // Standard iOS views
                InitialScreen()
                    .environmentObject(crimeViewModel)
                    .onAppear {
                        // Request notification permissions when app launches
                        NotificationService.shared.requestPermission()
                    }
                #endif
            }
            .sheet(isPresented: $showingLoginModal) {
                // Admin login modal
                AdminLoginView(isAdminMode: $isAdminMode)
            }
            .onAppear {
                // Check if the app was launched with admin flags (for development purposes)
                #if DEBUG
                let arguments = ProcessInfo.processInfo.arguments
                if arguments.contains("--adminMode") {
                    isAdminMode = true
                }
                #endif
                
                // For demonstration, show login modal after a delay
                #if os(visionOS)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingLoginModal = true
                }
                #endif
            }
        }
        
        #if os(visionOS)
        // Add an immersive space for 3D map visualization if needed
        if isAdminMode {
            ImmersiveSpace(id: "CrimeMapSpace") {
                ImmersiveCrimeMapView()
                    .environmentObject(crimeViewModel)
            }
        }
        #endif
    }
    
    // State for admin login modal
    @State private var showingLoginModal = false
}

// Simple admin login view
struct AdminLoginView: View {
    @Binding var isAdminMode: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Admin Login")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if showError {
                Text("Invalid credentials")
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Login") {
                    // For demo purposes, accept basic credentials
                    if username == "admin" && password == "admin" {
                        isAdminMode = true
                        dismiss()
                    } else {
                        showError = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .padding()
        .frame(width: 350)
    }
}


#Preview {
    InitialScreen()
        .environmentObject(CrimeViewModel()) // Ensure previews also inject the environment object
}
