//
//  Assignment1App.swift
//  Assignment1
//
//  Created by Udeesha Rukshan on 2025-04-02.
//

import SwiftUI

@main
struct Assignment1App: App {
    var body: some Scene {
        WindowGroup {
            // Initialize the MainTabView without passing arguments
            MainTabView()
        }
    }
}

#Preview {
    // For the preview, we also don't pass any arguments
    MainTabView()
}
