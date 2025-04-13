import SwiftUI
import AVFoundation
import CoreLocation

struct SOSOverlayView: View {
    @Binding var isActivated: Bool
    @StateObject private var viewModel = SOSViewModel()
    @State private var pinInput = ""
    @FocusState private var isPinFieldFocused: Bool
    
    let timerInterval: TimeInterval = 5
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Emergency banner
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 22))
                    Text("EMERGENCY SOS ACTIVATED")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                
                if viewModel.isCountdownActive {
                    // Countdown section
                    VStack(spacing: 15) {
                        Text("SOS will be sent in")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        ZStack {
                            // Countdown circle
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 15)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / CGFloat(timerInterval))
                                .stroke(Color.red, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear, value: viewModel.timeRemaining)
                            
                            Text("\(Int(viewModel.timeRemaining))")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Enter PIN to cancel")
                            .foregroundColor(.white.opacity(0.8))
                        
                        // PIN input
                        HStack(spacing: 15) {
                            ForEach(0..<4, id: \.self) { index in
                                Circle()
                                    .fill(index < pinInput.count ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        SecureField("", text: $pinInput)
                            .keyboardType(.numberPad)
                            .focused($isPinFieldFocused)
                            .onChange(of: pinInput) { newValue in
                                // Limit to 4 digits
                                if newValue.count > 4 {
                                    pinInput = String(newValue.prefix(4))
                                }
                                
                                // Check if PIN is correct
                                if newValue.count == 4 && newValue == viewModel.emergencyPin {
                                    cancelEmergency()
                                }
                            }
                            .padding()
                            .frame(width: 200)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .opacity(0.01) // Hidden but functional
                    }
                    .onAppear {
                        // Focus the PIN field immediately
                        isPinFieldFocused = true
                    }
                } else {
                    // SOS sent state
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("SOS Alert Sent")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            SOSActionRow(icon: "location.fill", text: "Location shared with emergency contacts")
                            SOSActionRow(icon: "phone.fill", text: "Emergency services notified")
                            if viewModel.isRecording {
                                SOSActionRow(icon: "record.circle", text: "Recording in progress...", isActive: true)
                            } else {
                                SOSActionRow(icon: "record.circle", text: "Evidence recording started")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Cancel or End buttons
                Button {
                    if viewModel.isCountdownActive {
                        // During countdown, show PIN pad
                        isPinFieldFocused = true
                    } else {
                        // After SOS is sent, just end session
                        cancelEmergency()
                    }
                } label: {
                    Text(viewModel.isCountdownActive ? "Enter PIN to Cancel" : "End Emergency")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            viewModel.startCountdown()
        }
        .onDisappear {
            viewModel.stopRecording()
        }
    }
    
    private func cancelEmergency() {
        hapticFeedback(style: .medium)
        viewModel.stopEmergency()
        isActivated = false
    }
    
    private func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct SOSActionRow: View {
    var icon: String
    var text: String
    var isActive: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(isActive ? .red : .green)
                .imageScale(.large)
            
            Text(text)
                .foregroundColor(.white)
            
            if isActive {
                Spacer()
                
                // Pulsing indicator for active actions
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .opacity(isActive ? 1 : 0)
            }
        }
    }
}

#Preview {
    SOSOverlayView(isActivated: .constant(true))
}