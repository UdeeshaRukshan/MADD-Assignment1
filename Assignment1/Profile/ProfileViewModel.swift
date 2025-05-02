import SwiftUI
import Firebase
import FirebaseFirestore

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
    
    @Published var reportCount: Int = 0
    @Published var alertCount: Int = 0
    
    @Published var badges: [Badge] = []
    @Published var recentActivities: [Activity] = []
    
    private var db = Firestore.firestore()
    private var crimeCountListener: ListenerRegistration?
    private var activitiesListener: ListenerRegistration?
    
    init() {
        loadProfile()
    }
    
    deinit {
        // Remove listeners when viewmodel is deallocated
        crimeCountListener?.remove()
        activitiesListener?.remove()
    }
    
    func loadProfile() {
        // Fetch crime report count from Firebase
        fetchCrimeReportCount()
        
        // Fetch activities from Firebase
        fetchActivities()
        
        // Load badges - could also come from Firebase in a future update
        badges = [
            Badge(name: "First Report", icon: "flag.fill", color: .blue),
            Badge(name: "Guardian", icon: "shield.fill", color: .green),
            Badge(name: "Alert Hero", icon: "bell.fill", color: .orange),
            Badge(name: "Protector", icon: "person.fill.checkmark", color: .purple)
        ]
        
        // Load profile image from UserDefaults if available
        if let imageData = UserDefaults.standard.data(forKey: "profileImage") {
            profileImage = UIImage(data: imageData)
        }
    }
    
    private func fetchCrimeReportCount() {
        // Remove any existing listener
        crimeCountListener?.remove()
        
        // Set up a real-time listener for the crimes collection
        crimeCountListener = db.collection("crimes")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching crime count: \(error.localizedDescription)")
                    return
                }
                
                // Update the report count with the number of documents in the collection
                DispatchQueue.main.async {
                    self.reportCount = snapshot?.documents.count ?? 0
                    self.alertCount = snapshot?.documents.count ?? 0
                }
            }
    }
    
    private func fetchActivities() {
        // Remove any existing listener
        activitiesListener?.remove()
        
        // Set up a real-time listener for the crimes collection instead of activities
        activitiesListener = db.collection("crimes")
            .order(by: "timestamp", descending: true)
            .limit(to: 10) // Limit to 10 most recent crimes
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching crimes for activities: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No crimes found")
                    return
                }
                
                // Map Firestore crime documents to Activity objects
                DispatchQueue.main.async {
                    let mappedActivities = documents.compactMap { document -> Activity? in
                        let data = document.data()
                        
                        // Use conditional binding to safely extract values from crime documents
                        guard 
                            let title = data["title"] as? String,
                            let description = data["description"] as? String,
                            let timestamp = data["timestamp"] as? Timestamp
                        else {
                            print("Failed to parse crime for activity: \(data)")
                            return nil
                        }
                        
                        // Determine severity and activity type
                        let severity = data["severity"] as? Int ?? 1
                        let activityType: Activity.ActivityType = severity >= 4 ? .alert : .report
                        
                        // Create the time ago string
                        let timeAgo = self.timeAgoSinceDate(timestamp.dateValue())
                        
                        // Create and return an Activity object from the crime data
                        return Activity(
                            title: title,
                            description: description,
                            timeAgo: timeAgo,
                            type: activityType
                        )
                    }
                    
                    // Now assign the filtered array
                    self.recentActivities = mappedActivities
                    
                    // If no crimes were found, add a default one
                    if self.recentActivities.isEmpty {
                        self.recentActivities = [
                            Activity(
                                title: "No Recent Crime Reports",
                                description: "Your community is currently peaceful",
                                timeAgo: "Now",
                                type: .system
                            )
                        ]
                    }
                }
            }
    }
    
    // Helper method to convert string type to ActivityType enum
    private func activityTypeFromString(_ string: String) -> Activity.ActivityType? {
        switch string.lowercased() {
        case "report":
            return .report
        case "alert":
            return .alert
        case "system":
            return .system
        case "achievement":
            return .achievement
        default:
            return nil
        }
    }
    
    // Helper method to format date as "time ago" string
    private func timeAgoSinceDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfMonth, .month, .year], from: date, to: now)
        
        if let year = components.year, year >= 1 {
            return year == 1 ? "1y ago" : "\(year)y ago"
        }
        
        if let month = components.month, month >= 1 {
            return month == 1 ? "1mo ago" : "\(month)mo ago"
        }
        
        if let week = components.weekOfMonth, week >= 1 {
            return week == 1 ? "1w ago" : "\(week)w ago"
        }
        
        if let day = components.day, day >= 1 {
            return day == 1 ? "Yesterday" : "\(day)d ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1h ago" : "\(hour)h ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1m ago" : "\(minute)m ago"
        }
        
        return "Just now"
    }
    
    // Method to add a new activity
    func addActivity(title: String, description: String, type: Activity.ActivityType) {
        // Create activity data
        let activityData: [String: Any] = [
            "title": title,
            "description": description,
            "timestamp": FieldValue.serverTimestamp(),
            "type": typeToString(type)
        ]
        
        // Add to Firestore global activities collection
        db.collection("activities")
            .addDocument(data: activityData) { error in
                if let error = error {
                    print("Error adding activity: \(error.localizedDescription)")
                } else {
                    print("Activity added successfully")
                }
            }
    }
    
    // Helper to convert ActivityType to string for storage
    private func typeToString(_ type: Activity.ActivityType) -> String {
        switch type {
        case .report:
            return "report"
        case .alert:
            return "alert"
        case .system:
            return "system"
        case .achievement:
            return "achievement"
        }
    }
    
    func saveProfile() {
        // Existing saveProfile code...
        if let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
        
        // Simulate saving other profile details
        print("Profile saved: \(name), \(email), \(phone), \(location)")
        
        // Add an activity for profile update
        addActivity(
            title: "Updated Profile Information",
            description: "Changed profile details",
            type: .system
        )
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
