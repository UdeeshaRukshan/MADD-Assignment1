//
//  Assignment1App.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-03-03.
//

import SwiftUI

@main
struct Assignment1App: App {
    @State private var showSplashScreen = true
    
    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                InitialScreen(navigateToContent: $showSplashScreen)
            } else {
                MainTabView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
