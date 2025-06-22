//
//  CctvList.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-03-15.
//

import SwiftUI
import WebKit
import AVKit

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
        CCTVCamera(name: "Camera 1", location: "Street 1", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 2", location: "Street 2", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 3", location: "Street 3", thumbnailName: "camera.fill", isOnline: false),
        CCTVCamera(name: "Camera 4", location: "Street 4", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 5", location: "Street 5", thumbnailName: "camera.fill", isOnline: true),
        CCTVCamera(name: "Camera 6", location: "Street 6", thumbnailName: "camera.fill", isOnline: false)
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
            ZStack {
                // Modern gradient background - matching other views
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "141E30"),
                        Color(hex: "243B55")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Custom header styling to match theme
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SECURITY")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(Color(hex: "64B5F6"))
                                .kerning(2)
                            
                            Text("Camera Monitoring")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
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
            }
            .navigationBarHidden(true)
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
            // Background with gradient that matches the app theme
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: camera.isOnline ?
                            [Color(hex: "1A2133"), Color(hex: "243B55")] :
                            [Color(hex: "1A2133").opacity(0.7), Color(hex: "243B55").opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.7), radius: 20, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            
            // Content
            VStack(spacing: 10) {
                // Camera icon or thumbnail
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 60)
                    
                    Image(systemName: camera.thumbnailName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(camera.isOnline ? Color(hex: "64B5F6") : Color.gray)
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
                        .frame(width: 10, height: 10)
                    
                    Text(camera.isOnline ? "Online" : "Offline")
                        .font(.system(size: 12))
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
    @State private var isLoading = true
    @State private var loadError = false
    // Add refreshID to trigger new random video each time
    @State private var refreshID = UUID()
    
    var body: some View {
        ZStack {
            // Modern gradient background to match the main view
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text(camera.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                }
                .padding()
                
                // Camera feed - Replace CCTVVideoPlayerView with CCTVPlayerView
                ZStack {
                    if camera.isOnline {
                        // Use the CCTVPlayerView with random video selection
                        CCTVPlayerView(refreshID: $refreshID)
                            .frame(height: 300)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .overlay(
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("LIVE")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(hex: "FF416C"))
                                            .cornerRadius(4)
                                        
                                        Spacer()
                                        
                                        Text("Security Feed • \(camera.location)")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                    .padding(8)
                                    .background(Color.black.opacity(0.5))
                                }
                            )
                            .onAppear {
                                // Generate a new random video each time the view appears
                                refreshID = UUID()
                                
                                // Hide loading indicator after a brief delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    isLoading = false
                                }
                            }
                    } else {
                        // Offline message
                        Rectangle()
                            .fill(Color(hex: "1A2133"))
                            .frame(height: 300)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .overlay(
                                VStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(hex: "FF416C"))
                                    
                                    Text("Camera Offline")
                                        .foregroundColor(.white)
                                        .padding(.top, 10)
                                }
                            )
                    }
                    
                    // Show loading indicator
                    if isLoading && camera.isOnline {
                        ZStack {
                            Color.black.opacity(0.7)
                                .cornerRadius(16)
                            
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                    .scaleEffect(1.5)
                                
                                Text("Loading Feed...")
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                            }
                        }
                    }
                    
                    // Show error message if needed
                    if loadError && camera.isOnline {
                        ZStack {
                            Color.black.opacity(0.7)
                                .cornerRadius(16)
                            
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 30)
                                    .foregroundColor(Color(hex: "FF416C"))
                                
                                Text("Failed to load camera feed")
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                                
                                Button("Retry") {
                                    isLoading = true
                                    loadError = false
                                    // Simulate retry
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isLoading = false
                                    }
                                }
                                .foregroundColor(Color(hex: "64B5F6"))
                                .padding(.top, 10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Camera details
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(title: "Location", value: camera.location)
                    DetailRow(title: "Status", value: camera.isOnline ? "Online" : "Offline",
                              valueColor: camera.isOnline ? .green : Color(hex: "FF416C"))
                    DetailRow(title: "Last Updated", value: "Just now")
                }
                .padding()
                .background(Color(hex: "1A2133"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Add a new "Change Feed" button
                Button(action: {
                    // Generate a new UUID to trigger the refresh
                    refreshID = UUID()
                }) {
                    Label("Switch Feed", systemImage: "arrow.triangle.2.circlepath")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(hex: "64B5F6").opacity(0.6))
                        .cornerRadius(8)
                }
                .padding(.top, 12)
                .opacity(camera.isOnline ? 1.0 : 0.0) // Only show when camera is online
                
                Spacer()
            }
        }
    }
}

// Helper view for details - updated for dark theme
struct DetailRow: View {
    let title: String
    let value: String
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(Color.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

// Helper view for control buttons - updated for dark theme
struct ControlButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(Color(hex: "64B5F6"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "1A2133"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Add this fixed CCTVVideoPlayerView directly to this file for better integration
struct CCTVVideoPlayerView: View {
    @State private var player = AVPlayer()
    @State private var showControls = false
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .aspectRatio(16/9, contentMode: .fit)
                .onAppear {
                    // First try to load from bundle
                    if let videoURL = Bundle.main.url(forResource: "cctv", withExtension: "mp4") {
                        setupPlayer(with: videoURL)
                    } else {
                        // Try to load from Assets catalog in a different way
                        loadVideoFromAssets()
                    }
                }
                .onDisappear {
                    // Clean up when the view disappears
                    player.pause()
                    NotificationCenter.default.removeObserver(self)
                }
            
            // Video controls that appear on tap
            if showControls {
                HStack(spacing: 40) {
                    Button(action: {
                        player.seek(to: CMTime(seconds: max(0, player.currentTime().seconds - 10), preferredTimescale: 600))
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        if player.timeControlStatus == .playing {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }) {
                        Image(systemName: player.timeControlStatus == .playing ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        player.seek(to: CMTime(seconds: player.currentTime().seconds + 10, preferredTimescale: 600))
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(10)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Show controls when tapped
            withAnimation {
                showControls = true
            }
            
            // Auto-hide controls after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showControls = false
                }
            }
        }
    }
    
    private func setupPlayer(with url: URL) {
        // Set up the player with the video URL
        player = AVPlayer(url: url)
        
        // Configure playback settings
        player.automaticallyWaitsToMinimizeStalling = true
        player.volume = 0.5  // 50% volume by default
        player.play()
        
        // Add observer for when playback ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            // Loop the video
            player.seek(to: .zero)
            player.play()
        }
    }
    
    private func loadVideoFromAssets() {
        // Alternative method to load video from asset catalog
        if let dataAsset = NSDataAsset(name: "cctv") {
            // Create a temporary file to play the video from
            let temporaryDirectoryURL = FileManager.default.temporaryDirectory
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("temp_cctv.mp4")
            
            do {
                try dataAsset.data.write(to: temporaryFileURL)
                setupPlayer(with: temporaryFileURL)
            } catch {
                print("Error writing video data to temporary file: \(error)")
            }
        } else {
            print("Could not load video data from assets")
        }
    }
}


#Preview {
    CCTVListView()
}
