//
//  YouTubePlayerView.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import SwiftUI
import WebKit
import AVKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Create the YouTube embed HTML
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                body, html, #player {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    background-color: #000;
                    overflow: hidden;
                }
            </style>
        </head>
        <body>
            <div id="player"></div>
            <script>
                var tag = document.createElement('script');
                tag.src = "https://www.youtube.com/iframe_api";
                var firstScriptTag = document.getElementsByTagName('script')[0];
                firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
                
                var player;
                function onYouTubeIframeAPIReady() {
                    player = new YT.Player('player', {
                        videoId: '\(videoID)',
                        playerVars: {
                            'playsinline': 1,
                            'autoplay': 1,
                            'controls': 1,
                            'showinfo': 0,
                            'rel': 0,
                            'loop': 1,
                            'playlist': '\(videoID)'
                        },
                        events: {
                            'onReady': onPlayerReady
                        }
                    });
                }
                
                function onPlayerReady(event) {
                    event.target.playVideo();
                }
            </script>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(embedHTML, baseURL: nil)
    }
}

struct OnlineVideoPlayerView: View {
    var body: some View {
        VStack {
            // Using the specific YouTube video ID from your link
            YouTubePlayerView(videoID: "ms-Q3t5IqNM")
                .frame(height: 240)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
            
            Text("Neighborhood Safety - Live Feed")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 8)
        }
    }
}

struct LocalVideoPlayerView: View {
    let videoURL: URL
    @State private var player = AVPlayer()
    
    var body: some View {
        VideoPlayer(player: player)
            .aspectRatio(16/9, contentMode: .fit)
            .onAppear {
                // Set up the player when the view appears
                player = AVPlayer(url: videoURL)
                
                // Configure playback settings
                player.isMuted = false
                player.play()
                
                // Add observer for when playback ends
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: .main
                ) { _ in
                    // Loop the video if needed
                    player.seek(to: .zero)
                    player.play()
                }
            }
            .onDisappear {
                // Clean up when the view disappears
                player.pause()
                NotificationCenter.default.removeObserver(self)
            }
    }
}

// Example usage with file from local bundle
struct VideoPlayerContainerView: View {
    var body: some View {
        VStack {
            // Toggle between local and YouTube video
            if let bundleURL = Bundle.main.url(forResource: "cctv", withExtension: "mp4") {
                LocalVideoPlayerView(videoURL: bundleURL)
                    .frame(height: 240)
                    .cornerRadius(12)
                
                Text("Local CCTV Camera Feed")
                    .font(.headline)
                    .foregroundColor(.white)
            } else {
                // Fallback to YouTube if local file not found
                OnlineVideoPlayerView()
            }
        }
    }
}

// Example usage with file from documents directory
struct DocumentsVideoPlayerView: View {
    let videoFileName: String
    
    var body: some View {
        VStack {
            if let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
               let videoURL = URL(string: videoFileName, relativeTo: docsURL) {
                LocalVideoPlayerView(videoURL: videoURL)
            } else {
                Text("Video file not found")
                    .foregroundColor(.red)
            }
        }
    }
}

// Rename this to avoid conflict
struct YouTubeCCTVPlayerView: View {
    @State private var player = AVPlayer()
    @State private var isShowingYouTubeVideo = false
    @State private var loadError = false
    @State private var selectedVideoName: String = ""
    // Add a UUID that will change whenever we need to refresh
    @Binding var refreshID: UUID
    
    var body: some View {
        ZStack {
            if isShowingYouTubeVideo {
                // YouTube video as fallback
                OnlineVideoPlayerView()
            } else {
                // Local video player
                VideoPlayer(player: player)
                    .aspectRatio(16/9, contentMode: .fit)
                    .id(refreshID) // This forces the view to recreate when refreshID changes
                    .onAppear {
                        loadRandomVideo()
                    }
                    .onDisappear {
                        // Clean up when the view disappears
                        player.pause()
                        NotificationCenter.default.removeObserver(self)
                    }
            }
            
            // Show error view if needed
            if loadError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)
                    
                    Text("Local video could not be loaded")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button("Show Online Feed") {
                        isShowingYouTubeVideo = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(20)
                .background(Color.black.opacity(0.7))
                .cornerRadius(12)
            }
            
            // Show caption with the camera feed name
            VStack {
                Spacer()
                
                HStack {
                    Text(selectedVideoName.isEmpty ? "CCTV Feed" : "CCTV Feed: \(selectedVideoName)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                .padding(.leading, 8)
            }
            .allowsHitTesting(false)
        }
        // Add a onChange modifier to detect when refreshID changes
        .onChange(of: refreshID) { _ in
            // Reset state and load a new random video
            isShowingYouTubeVideo = false
            loadError = false
            loadRandomVideo()
        }
    }
    
    // Function to randomly choose and load a video
    private func loadRandomVideo() {
        // Array of available video names
        let videoNames = ["cctv", "cctv1", "cctv2"]
        
        // Randomly select a video
        let randomIndex = Int.random(in: 0..<videoNames.count)
        let selectedVideo = videoNames[randomIndex]
        
        // Store selected video name for display
        selectedVideoName = selectedVideo
        
        print("Selected random video: \(selectedVideo)")
        
        // First try to load the randomly selected video from bundle
        if let videoURL = Bundle.main.url(forResource: selectedVideo, withExtension: "mp4") {
            setupPlayer(with: videoURL)
            return
        }
        
        // If the selected video failed, try the other videos in sequence
        for videoName in videoNames where videoName != selectedVideo {
            if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                selectedVideoName = videoName
                setupPlayer(with: videoURL)
                return
            }
        }
        
        // If bundle loading failed, try from Assets catalog
        if let dataAsset = NSDataAsset(name: selectedVideo) {
            // Create a temporary file to play the video from
            let temporaryDirectoryURL = FileManager.default.temporaryDirectory
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("temp_\(selectedVideo).mp4")
            
            do {
                try dataAsset.data.write(to: temporaryFileURL)
                setupPlayer(with: temporaryFileURL)
                return
            } catch {
                print("Error writing video data to temporary file: \(error)")
            }
        }
        
        // If all else fails, set error state
        print("Could not load any video data")
        loadError = true
    }
    
    private func setupPlayer(with url: URL) {
        // Set up the player with the video URL
        player = AVPlayer(url: url)
        
        // Configure playback settings
        player.isMuted = false
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
}

// Updated container view with working refresh mechanism
struct CCTVContainerView: View {
    // This UUID will be changed whenever we want a new random video
    @State private var refreshID = UUID()
    @State private var currentFrame: UIImage?
    
    var body: some View {
        VStack {
            // Use the renamed view here
            YouTubeCCTVPlayerView(refreshID: $refreshID)
                .frame(height: 240)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text("Security Camera Feed")
                .font(.headline)
                .foregroundColor(.white)
            
            // Add a working refresh button to choose another random video
            Button(action: {
                // Generate a new UUID to trigger the refresh
                refreshID = UUID()
            }) {
                Label("Change Camera", systemImage: "arrow.triangle.2.circlepath")
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue.opacity(0.6))
                    .cornerRadius(8)
            }
            .padding(.top, 12)
        }
    }
}
