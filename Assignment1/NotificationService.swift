import SwiftUI
import UserNotifications

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    @Published var isPermissionGranted = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, categoryIdentifier: String = "crime") {
        // Check permission before scheduling
        if !isPermissionGranted {
            print("Cannot schedule notification: Permission not granted")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = categoryIdentifier
        
        // Create a trigger (immediate in this case)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create request
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add the request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule notification for a specific time
    func scheduleTimedNotification(title: String, body: String, date: Date, categoryIdentifier: String = "crime") {
        if !isPermissionGranted {
            print("Cannot schedule notification: Permission not granted")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = categoryIdentifier
        
        // Create a date components from the date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling timed notification: \(error.localizedDescription)")
            }
        }
    }
    
    // For notifications that have actions (like "View" or "Dismiss")
    func setupNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: .destructive
        )
        
        let crimeCategory = UNNotificationCategory(
            identifier: "crime",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([crimeCategory])
    }
    
    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // This is called when a notification arrives while the app is in the foreground
        // We choose to still show the notification
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response (when user taps on notification)
        let identifier = response.actionIdentifier
        
        switch identifier {
        case "VIEW_ACTION":
            // Handle view action
            NotificationCenter.default.post(name: NSNotification.Name("OpenCrimeDetails"), object: nil, userInfo: response.notification.request.content.userInfo)
        case UNNotificationDefaultActionIdentifier:
            // This is the default action (when user taps the notification itself)
            NotificationCenter.default.post(name: NSNotification.Name("OpenNotifications"), object: nil)
        default:
            break
        }
        
        completionHandler()
    }
}