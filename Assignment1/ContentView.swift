//
//  ContentView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Welcome to Crime Map App!")
            .font(.title)
            .padding()
    }
}

#Preview {
    ContentView()
            .environmentObject(CrimeViewModel())
}
