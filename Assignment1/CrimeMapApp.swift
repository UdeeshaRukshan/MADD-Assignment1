//
//  CrimeMapApp.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI

// Removed @main attribute
struct CrimeMapApp: App {
    var body: some Scene {
        WindowGroup {
            PlaceholderView() // Replace ContentView with PlaceholderView
                .environmentObject(CrimeViewModel())
        }
    }
}

#Preview {
    PlaceholderView() // Preview the placeholder view
        .environmentObject(CrimeViewModel())
}
