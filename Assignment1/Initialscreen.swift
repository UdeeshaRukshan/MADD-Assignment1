import SwiftUI

struct InitialScreen: View {
    @State private var isAnimating = false
    @State private var navigateToContent = false
    @State private var logoScale = 0.8
    @State private var rotation = 0.0
    @State private var gradientPosition = -200.0
    
    // Create a gradient for the background
    let gradient = LinearGradient(
        colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                Rectangle()
                    .fill(gradient)
                    .ignoresSafeArea()
                
                // Animated circles in background
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .offset(x: isAnimating ? 100 : -100, y: -150)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .offset(x: isAnimating ? -120 : 120, y: 170)
                    .blur(radius: 25)
                
                // Content
                VStack(spacing: 30) {
                    // Logo
                    ZStack {
                       
                        // Replace with your app icon or custom logo
                        Image("staysafe")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 150)
//                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            
                           


                    }
                    .scaleEffect(logoScale)
                    
                    // Welcome text with enhanced animation
                    VStack(spacing: 10) {
                        Text("StaySafe")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 30)
                        
                        Text("Criminal alert app")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                            .padding(.top, -5)
                    }
                    
                    // Loading indicator
                    HStack(spacing: 5) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1 : 0.5)
                                .opacity(isAnimating ? 1 : 0.3)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    .padding(.top, 20)
                    .opacity(isAnimating ? 1 : 0)
                }
            }
            .onAppear {
                // Start animations
                withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                    isAnimating = true
                    logoScale = 1.0
                }
                
                // Rotate logo
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                
                // Navigate after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    navigateToContent = true
                }
            }
            .navigationDestination(isPresented: $navigateToContent) {
                MainTabView() // Navigate to ContentView automatically
            }
        }
    }
}

#Preview {
    InitialScreen()
}
