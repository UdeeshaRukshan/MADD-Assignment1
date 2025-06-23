import SwiftUI

struct SOSButton: View {
    @Binding var isActivated: Bool
    @State private var pulsate = false
    
    var body: some View {
        Button {
            hapticFeedback(style: .heavy)
            isActivated = true
        } label: {
            ZStack {
                // Background circles for visual effect
                Circle()
                    .fill(Color.red.opacity(pulsate ? 0.3 : 0.0))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulsate ? 1.2 : 1.0)
                
                Circle()
                    .fill(Color.red.opacity(pulsate ? 0.5 : 0.0))
                    .frame(width: 65, height: 65)
                    .scaleEffect(pulsate ? 1.1 : 1.0)
                
                // Main button
                Circle()
                    .fill(Color.red)
                    .frame(width: 55, height: 55)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                
                // SOS text
                Text("SOS")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsate = true
            }
        }
    }
    
    private func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if !targetEnvironment(simulator)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
        #endif
    }
}

// Use the correct SwiftUI preview provider syntax
struct SOSButton_Previews: PreviewProvider {
    static var previews: some View {
        SOSButtonPreviewWrapper()
    }
}

// Move the wrapper struct outside of the previews closure
struct SOSButtonPreviewWrapper: View {
    @State private var isActivated = false
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            SOSButton(isActivated: $isActivated)
        }
    }
}