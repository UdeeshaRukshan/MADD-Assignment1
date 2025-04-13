import Foundation
import CoreLocation
import AVFoundation
import Contacts
import SwiftUI

class SOSViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    // State tracking
    @Published var isCountdownActive = true
    @Published var timeRemaining: TimeInterval = 5
    @Published var isRecording = false
    @Published var emergencyContacts: [EmergencyContact] = []
    
    // Location tracking
    private var locationManager: CLLocationManager?
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // Recording
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    // Emergency PIN - in a real app this would be stored securely
    let emergencyPin = "1234"
    
    // Timer for countdown
    private var countdownTimer: Timer?
    
    override init() {
        super.init()
        setupLocationManager()
        loadEmergencyContacts()
    }
    
    func startCountdown() {
        // Reset state
        timeRemaining = 5
        isCountdownActive = true
        
        // Play warning sound
        playEmergencySound()
        
        // Start countdown timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                
                // Provide haptic feedback for each second
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            } else {
                // Time's up - trigger emergency actions
                self.triggerEmergency()
            }
        }
    }
    
    func triggerEmergency() {
        // Cancel the countdown timer
        countdownTimer?.invalidate()
        
        // Switch to sent state
        isCountdownActive = false
        
        // Get current location
        requestLocationUpdate()
        
        // Call emergency services
        callEmergencyServices()
        
        // Send messages to emergency contacts
        notifyEmergencyContacts()
        
        // Start recording audio/video as evidence
        startRecording()
    }
    
    func stopEmergency() {
        // Stop the countdown if it's still active
        countdownTimer?.invalidate()
        
        // Stop recording if it's in progress
        stopRecording()
    }
    
    // MARK: - Location Methods
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func requestLocationUpdate() {
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            print("Location obtained: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    // MARK: - Emergency Contact Methods
    
    private func loadEmergencyContacts() {
        // In a real app, this would load from UserDefaults or a database
        // For now, we'll use sample data
        emergencyContacts = [
            EmergencyContact(name: "Emergency Services", phoneNumber: "911", isPrimary: true),
            EmergencyContact(name: "John Doe", phoneNumber: "555-123-4567", isPrimary: false),
            EmergencyContact(name: "Jane Smith", phoneNumber: "555-987-6543", isPrimary: false)
        ]
    }
    
    private func notifyEmergencyContacts() {
        guard let location = currentLocation else {
            print("Location not available")
            return
        }
        
        // In a real app, this would send SMS or app notifications with the location
        // For demonstration purposes, we'll just print
        for contact in emergencyContacts.filter({ !$0.isPrimary }) {
            let message = "EMERGENCY: I need help. My current location is: https://maps.google.com/maps?q=\(location.latitude),\(location.longitude)"
            print("Sending to \(contact.name): \(message)")
        }
    }
    
    private func callEmergencyServices() {
        // In a real app, this would initiate a phone call
        // For demonstration purposes, we'll just log it
        if let emergencyService = emergencyContacts.first(where: { $0.isPrimary }) {
            let phoneNumber = "tel://\(emergencyService.phoneNumber.replacingOccurrences(of: "-", with: ""))"
            print("Calling emergency services: \(phoneNumber)")
            
            // Note: In a real app, we would use this code to actually make the call
            // if let url = URL(string: phoneNumber), UIApplication.shared.canOpenURL(url) {
            //     UIApplication.shared.open(url)
            // }
        }
    }
    
    // MARK: - Recording Methods
    
    private func startRecording() {
        // Set up recording session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // Create the recording directory if it doesn't exist
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let recordingsPath = documentsPath.appendingPathComponent("EmergencyRecordings")
            
            try FileManager.default.createDirectory(at: recordingsPath, withIntermediateDirectories: true)
            
            // Create a filename with timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let fileName = "emergency_\(dateFormatter.string(from: Date())).m4a"
            recordingURL = recordingsPath.appendingPathComponent(fileName)
            
            // Setup recorder
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Start recording
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            print("Recording started at \(recordingURL?.path ?? "unknown path")")
        } catch {
            print("Recording failed to start: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        if isRecording {
            audioRecorder?.stop()
            isRecording = false
            print("Recording stopped")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
        }
    }
    
    // MARK: - Helper Methods
    
    private func playEmergencySound() {
        // In a real app, play a warning sound
        // For now, we'll just use the system sound
        AudioServicesPlaySystemSound(1521) // Standard system sound
    }
}

struct EmergencyContact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let isPrimary: Bool // Is this emergency services (911, etc)?
}