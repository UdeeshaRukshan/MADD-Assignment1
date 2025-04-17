import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}