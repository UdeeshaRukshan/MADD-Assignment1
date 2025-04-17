//
//  NotificationBanner.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI

struct NotificationBanner: View {
    var message: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Alert icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .opacity(isAnimating ? 0.8 : 1.0)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            // Message text
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FF416C"),
                    Color(hex: "FF4B2B")
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .shadow(color: Color(hex: "FF416C").opacity(0.5), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct NotificationContentView: View {
    @ObservedObject var viewModel: CrimeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 8)
                    
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Clear all notifications action
                        viewModel.notificationMessage = nil
                    }) {
                        Text("Clear All")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "64B5F6"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Notification display
                if let message = viewModel.notificationMessage {
                    NotificationBanner(message: message)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 100)
                        
                        Text("No New Notifications")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("When you receive notifications, they'll appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Recent activity list
                VStack(alignment: .leading) {
                    Text("RECENT ACTIVITY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "64B5F6"))
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                    
                    List(viewModel.criminalActivities.prefix(5)) { crime in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(crime.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(crime.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(crime.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(Color(hex: "64B5F6"))
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color(hex: "1A2133"))
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NotificationContentView(viewModel: CrimeViewModel())
}