import SwiftUI
import UIKit

// Scene delegate to handle multiple windows on iPad
class MultiSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootView = MainTabView()
            .environmentObject(CrimeViewModel())
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
    }
}

// Helper struct for creating new windows on iPad
struct NewWindowView: View {
    let viewType: WindowViewType
    let crime: CriminalActivity?
    
    enum WindowViewType: String {
        case crimeDetail
        case cctv
        case chat
    }
    
    var body: some View {
        Group {
            switch viewType {
            case .crimeDetail:
                if let crime = crime {
                    CrimeDetailView(crime: crime)
                } else {
                    Text("No crime details available")
                        .foregroundColor(.white)
                }
            case .cctv:
                CCTVListView()
            case .chat:
                ChatListView()
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}

// Extension for UIApplication to create new windows
extension UIApplication {
    func createNewWindow(for view: NewWindowView) {
        guard let sceneSession = UIApplication.shared.openSessions.first else { return }
        
        let userActivity = NSUserActivity(activityType: "com.staysafe.openNewWindow")
        userActivity.userInfo = ["viewType": view.viewType.rawValue]
        
        UIApplication.shared.requestSceneSessionActivation(
            sceneSession,
            userActivity: userActivity,
            options: nil,
            errorHandler: nil
        )
    }
}
