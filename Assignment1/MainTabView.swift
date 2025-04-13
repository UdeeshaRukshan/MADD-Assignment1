import SwiftUI

struct MainTabView: View {
    @StateObject private var crimeViewModel = CrimeViewModel()
    @State private var sosActivated = false
    
    var body: some View {
        ZStack {
            TabView {
                // Crime Map & Reporting Tab
                PlaceholderView()
                    .environmentObject(crimeViewModel)
                    .tabItem {
                        Label("Crime Map", systemImage: "map.fill")
                    }
                
                // Chat Features Tab
                ChatListView()
                    .tabItem {
                        Label("Communications", systemImage: "message.fill")
                    }
                
                // CCTV Monitoring Tab
                CCTVListView()
                    .tabItem {
                        Label("CCTV", systemImage: "video.fill")
                    }
                
                // Profile Tab
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            }
            .onAppear {
                // Set the accent color for tab items
                let appearance = UITabBarAppearance()
                appearance.backgroundColor = UIColor.systemBackground
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
                // Add this to onAppear for consistent appearance
                UINavigationBar.appearance().tintColor = UIColor.systemBlue
            }
            
            // Floating SOS button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    SOSButton(isActivated: $sosActivated)
                        .padding(.trailing, 20)
                        .padding(.bottom, 120) // Position above tab bar
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // SOS Overlay when activated
            if sosActivated {
                SOSOverlayView(isActivated: $sosActivated)
                    .transition(.opacity)
                    .zIndex(100) // Ensure it's above everything
            }
        }
    }
}

#Preview {
    MainTabView()
}

/*
 Add these to your Info.plist
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>Your location is needed to send to emergency contacts during an SOS alert.</string>
 <key>NSMicrophoneUsageDescription</key>
 <string>Microphone access is needed to record audio evidence during emergency situations.</string>
 <key>NSContactsUsageDescription</key>
 <string>Contact access allows you to select emergency contacts for SOS alerts.</string>
*/
