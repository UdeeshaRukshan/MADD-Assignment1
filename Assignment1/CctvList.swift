//
//  CctvList.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-03-15.
//

import SwiftUI

// Model for CCTV Camera
struct CCTVCamera: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let thumbnailName: String
    let isOnline: Bool
}

struct CCTVListView: View {
    // Sample data for CCTV cameras
    @State private var cameras = [
        CCTVCamera(name: "Camera 1", location: "Front Door", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 2", location: "Back Yard", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 3", location: "Garage", thumbnailName: "camera.fill", isOnline: false),
        CCTVCamera(name: "Camera 4", location: "Living Room", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 5", location: "Kitchen", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 6", location: "Basement", thumbnailName: "camera.fill", isOnline: false)
    ]
    
    @State private var selectedCamera: CCTVCamera? = nil
    @State private var showPreview = false
    
    // Grid layout configuration
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Grid of CCTV cameras
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(cameras) { camera in
                        CameraCell(camera: camera)
                            .onTapGesture {
                                selectedCamera = camera
                                showPreview = true
                            }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Security Cameras")
            .sheet(isPresented: $showPreview) {
                if let camera = selectedCamera {
                    CameraPreviewView(camera: camera)
                }
            }
        }
    }
}

// Individual camera cell in grid
struct CameraCell: View {
    let camera: CCTVCamera
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: camera.isOnline ?
                            [Color.blue.opacity(0.7), Color.blue.opacity(0.5)] :
                            [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            
            // Content
            VStack(spacing: 10) {
                // Camera icon or thumbnail
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: camera.thumbnailName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                
                // Camera name
                Text(camera.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                // Location
                Text(camera.location)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                // Status indicator
                HStack(spacing: 5) {
                    Circle()
                        .fill(camera.isOnline ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(camera.isOnline ? "Online" : "Offline")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.vertical, 15)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// Camera preview view
struct CameraPreviewView: View {
    let camera: CCTVCamera
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text(camera.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Camera feed (simulated)
            ZStack {
                if camera.isOnline {
                    // Simulated camera feed
                    Rectangle()
                        .fill(Color.black)
                        .overlay(
                            // This would be your actual camera feed
                            // For now, we'll use a placeholder
                            VStack {
                                Image(systemName: "video.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.white.opacity(0.5))
                                
                                Text("Live Feed")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 10)
                            }
                        )
                } else {
                    // Offline message
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.orange)
                                
                                Text("Camera Offline")
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                            }
                        )
                }
            }
            .frame(height: 300)
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Camera details
            VStack(alignment: .leading, spacing: 15) {
                DetailRow(title: "Location", value: camera.location)
                DetailRow(title: "Status", value: camera.isOnline ? "Online" : "Offline",
                          valueColor: camera.isOnline ? .green : .red)
                DetailRow(title: "Last Updated", value: "Just now")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Control buttons
            HStack(spacing: 20) {
                ControlButton(title: "Record", icon: "record.circle")
                ControlButton(title: "Screenshot", icon: "camera")
                ControlButton(title: "Settings", icon: "gear")
            }
            .padding()
            
            Spacer()
        }
    }
}

// Helper view for details
struct DetailRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

// Helper view for control buttons
struct ControlButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    CCTVListView()
}
