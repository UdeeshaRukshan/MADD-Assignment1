import SwiftUI
import Firebase
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Enable offline data persistence
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        
        return true
    }
    
    // Add this for Firebase Cloud Messaging setup if needed
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to Firebase for FCM
        Messaging.messaging().apnsToken = deviceToken
    }
}