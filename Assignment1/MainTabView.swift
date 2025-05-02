import SwiftUI

struct MainTabView: View {
    @StateObject private var crimeViewModel = CrimeViewModel()
    @State private var sosActivated = false
    @State private var selectedTab = 0 // Add this to control the tab state
    
    var body: some View {
        ZStack {
            // Add the modern gradient background here
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "2B32B2"),
                    Color(hex: "1488CC")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                // Crime Map & Reporting Tab
                PlaceholderView()
                    .environmentObject(crimeViewModel)
                    .tabItem {
                        Label("Crime Map", systemImage: "map.fill")
                    }
                    .tag(0)
                
                // Chat Features Tab
                ChatListView()
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .tag(1)
                
                // CCTV Monitoring Tab
                CCTVListView()
                    .tabItem {
                        Label("CCTV", systemImage: "video.fill")
                    }
                    .tag(2)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
            }
            .onAppear {
                // Set the accent color for tab items
                let appearance = UITabBarAppearance()
                appearance.backgroundColor = UIColor(Color(hex: "141E30")) // Match gradient start
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
                // Add this to onAppear for consistent appearance
                UINavigationBar.appearance().tintColor = UIColor(Color(hex: "64B5F6")) // Match your accent color
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
