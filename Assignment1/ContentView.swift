//
//  ContentView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-03-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack{
                Text("Hello, world!")
                Text("Hello, world!")
                Text("Hello, world!")
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
