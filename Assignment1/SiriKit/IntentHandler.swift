import Intents
import UIKit

// Main intent handler that routes intents to appropriate handlers
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // Handle different intent types
        switch intent {
        case is INSendMessageIntent:
            return SendMessageIntentHandler()
        case is INStartCallIntent:
            return StartCallIntentHandler()
        default:
            return self
        }
    }
}

// Handler for sending emergency messages
class SendMessageIntentHandler: NSObject, INSendMessageIntentHandling {
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Code to handle sending emergency messages
        let response = INSendMessageIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
    
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        // Code to resolve message recipients
        if let recipients = intent.recipients, !recipients.isEmpty {
            completion([.success(with: recipients[0])])
        } else {
            completion([.needsValue()])
        }
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        // Code to resolve message content
        if let content = intent.content, !content.isEmpty {
            completion(.success(with: content))
        } else {
            completion(.needsValue())
        }
    }
}

// Handler for starting emergency calls
class StartCallIntentHandler: NSObject, INStartCallIntentHandling {
    func handle(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {
        // Code to handle emergency calls
        // Using the correct response code enum
        let response = INStartCallIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }
    
    func resolveDestinationType(for intent: INStartCallIntent, with completion: @escaping (INCallDestinationTypeResolutionResult) -> Void) {
        // Code to resolve call destination type
        completion(.success(with: .emergency))
    }
}

// Custom handler for safety reporting
class SafetyReportHandler: NSObject {
    func handleSafetyReport(with details: String, at location: String?, completion: @escaping (Bool) -> Void) {
        // In a real app, this would integrate with your app's reporting system
        print("Safety report received: \(details), location: \(location ?? "Unknown")")
        
        // Create a user activity that could be used to open the app to the report screen
        let userActivity = NSUserActivity(activityType: "com.staysafe.reportIncident")
        userActivity.userInfo = [
            "details": details,
            "location": location ?? "Unknown",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Return success
        completion(true)
    }
}
