import SwiftUI

class SimpleSOSViewModel: ObservableObject {
    @Published var isCountdownActive = true
    @Published var timeRemaining: TimeInterval = 15
    @Published var isRecording = false
    let emergencyPin = "1234"
    @Published var latestHeartRate: Double? = 72

    func startCountdown() {
        // No-op for preview
    }
    func stopRecording() {
        // No-op for preview
    }
    func stopEmergency() {
        isCountdownActive = false
    }
}

struct SOSOverlayView: View {
    @Binding var isActivated: Bool
    @StateObject private var viewModel = SimpleSOSViewModel()
    @State private var pinInput = ""
    @FocusState private var isPinFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
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
                    VStack(spacing: 15) {
                        Text("SOS will be sent in")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 15)
                                .frame(width: 120, height: 120)
                            Circle()
                                .trim(
                                    from: 0,
                                    to: CGFloat(viewModel.timeRemaining) / 15
                                )
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
                                if newValue.count > 4 {
                                    pinInput = String(newValue.prefix(4))
                                }
                                if newValue.count == 4 && newValue == viewModel.emergencyPin {
                                    cancelEmergency()
                                }
                            }
                            .padding()
                            .frame(width: 200)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .opacity(0.01)
                        if let bpm = viewModel.latestHeartRate {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Heart Rate: \(Int(bpm)) BPM")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .onAppear {
                        isPinFieldFocused = true
                    }
                } else {
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
                            if let bpm = viewModel.latestHeartRate {
                                SOSActionRow(icon: "heart.fill", text: "Heart Rate Evidence: \(Int(bpm)) BPM")
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                Button {
                    if viewModel.isCountdownActive {
                        isPinFieldFocused = true
                    } else {
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
        viewModel.stopEmergency()
        isActivated = false
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
        .environment(\.colorScheme, .dark)
}