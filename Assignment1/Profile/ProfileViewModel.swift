import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var name: String = "Udeesha Rukshan"
    @Published var role: String = "Citizen"
    @Published var email: String = "udeeshagamage12@gmail.com"
    @Published var phone: String = "+940702796111"
    @Published var location: String = "Kaduwela"
    @Published var profileImage: UIImage?
    
    @Published var crimeAlertsEnabled: Bool = true
    @Published var nearbyWarningsEnabled: Bool = true
    @Published var soundAlertsEnabled: Bool = true
    
    @Published var reportCount: Int = 12
    @Published var alertCount: Int = 38
    
    @Published var badges: [Badge] = []
    @Published var recentActivities: [Activity] = []
    
    func loadProfile() {
        // In a real app, this would load from UserDefaults or a backend service
        // For now, we'll just set up some sample data
        badges = [
            Badge(name: "First Report", icon: "flag.fill", color: .blue),
            Badge(name: "Guardian", icon: "shield.fill", color: .green),
            Badge(name: "Alert Hero", icon: "bell.fill", color: .orange),
            Badge(name: "Protector", icon: "person.fill.checkmark", color: .purple)
        ]
        
        recentActivities = [
            Activity(
                title: "Reported Suspicious Activity",
                description: "Near Central Park",
                timeAgo: "2h ago",
                type: .report
            ),
            Activity(
                title: "Received Crime Alert",
                description: "Robbery reported 0.5 miles away",
                timeAgo: "Yesterday",
                type: .alert
            ),
            Activity(
                title: "Updated Profile Information",
                description: "Changed contact details",
                timeAgo: "3d ago",
                type: .system
            ),
            Activity(
                title: "Earned Badge: Guardian",
                description: "For consistent community monitoring",
                timeAgo: "1w ago",
                type: .achievement
            )
        ]
        
        // Load profile image from UserDefaults if available
        if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
            profileImage = UIImage(data: imageData)
        }
    }
    
    func saveProfile() {
        // In a real app, this would save to UserDefaults or a backend service
        // For demonstration, we'll just save the profile image
        if let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
        
        // Simulate saving other profile details
        print("Profile saved: \(name), \(email), \(phone), \(location)")
    }
}

struct Badge: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let timeAgo: String
    let type: ActivityType
    
    enum ActivityType {
        case report, alert, system, achievement
        
        var color: Color {
            switch self {
            case .report: return .red
            case .alert: return .orange
            case .system: return .blue
            case .achievement: return .green
            }
        }
    }
}
