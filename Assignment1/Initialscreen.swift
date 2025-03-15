//
//  Initialscreen.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-03-04.
//
import SwiftUI

struct InitialScreen: View {
    @State private var isAnimating = false
    @State private var navigateToContent = false // State to trigger navigation

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .offset(y: isAnimating ? 0 : 50)
                    .animation(.easeOut(duration: 1.2), value: isAnimating)
            }
            .onAppear {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Wait 2 seconds
                    navigateToContent = true
                }
            }
            .navigationDestination(isPresented: $navigateToContent) {
                ContentView() // Navigate to ContentView automatically
            }
        }
    }
}

#Preview {
    InitialScreen()
}
