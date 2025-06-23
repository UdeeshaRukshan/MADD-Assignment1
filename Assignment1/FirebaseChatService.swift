//
//  FirebaseChatService.swift
//  Assignment1
//
//  Created by udeesha rukshan on 2025-04-02.
//

import Foundation
import Firebase
import FirebaseFirestore


class FirebaseChatService: ObservableObject {
    @Published var conversations: [ChatConversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var conversationListeners: [ListenerRegistration] = []
    private var db = Firestore.firestore()
    
    init() {
        // Initialize with empty data
        createLocalConversations()
    }
    
    deinit {
        // Remove all listeners when this service is deallocated
        removeAllListeners()
    }
    
    func removeAllListeners() {
        for listener in conversationListeners {
            listener.remove()
        }
        conversationListeners.removeAll()
    }
    
    // Create local conversations without requiring Firebase permissions
    private func createLocalConversations() {
        // Create some sample users
        let officer = ChatUser(
            id: "officer1",
            name: "Officer Johnson",
            avatar: "person.crop.circle.badge.checkmark.fill",
            isVerified: true,
            isOnline: true
        )
        
        let neighbor = ChatUser(
            id: "neighbor1",
            name: "Sarah Thompson",
            avatar: "person.crop.circle.fill",
            isVerified: false,
            isOnline: true
        )
        
        let currentUser = ChatUser(
            id: "current_user_id",
            name: "You",
            avatar: "person.crop.circle.fill",
            isVerified: true,
            isOnline: true
        )
        
        // Create sample messages
        let alertMessage = ChatMessage(
            id: "msg1",
            content: "ALERT: Suspicious activity reported near Main Street",
            timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            sender: officer,
            isAlert: true,
            isRead: false
        )
        
        let regularMessage = ChatMessage(
            id: "msg2",
            content: "Has anyone seen a suspicious white van in the neighborhood?",
            timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
            sender: neighbor,
            isAlert: false,
            isRead: true
        )
        
        let userMessage = ChatMessage(
            id: "msg3",
            content: "I think I saw it yesterday around 3pm near the park",
            timestamp: Date().addingTimeInterval(-900), // 15 minutes ago
            sender: currentUser,
            isAlert: false,
            isRead: true
        )
        
        // Create sample conversations
        let publicConversation = ChatConversation(
            id: "public1",
            participants: [officer, neighbor, currentUser],
            messages: [alertMessage, regularMessage, userMessage],
            isPublic: true,
            title: "Neighborhood Watch"
        )
        
        let privateMessage1 = ChatMessage(
            id: "private1",
            content: "Thank you for your recent crime report. We're investigating.",
            timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            sender: officer,
            isAlert: false,
            isRead: true
        )
        
        let privateMessage2 = ChatMessage(
            id: "private2",
            content: "Do you have any additional details about what you saw?",
            timestamp: Date().addingTimeInterval(-5400), // 1.5 hours ago
            sender: officer,
            isAlert: false,
            isRead: false
        )
        
        let privateConversation = ChatConversation(
            id: "private1",
            participants: [officer, currentUser],
            messages: [privateMessage1, privateMessage2],
            isPublic: false,
            title: "Officer Johnson"
        )
        
        // Add conversations to the published array
        conversations = [publicConversation, privateConversation]
    }
    
    // Load all conversations for the current user
    func loadConversations(for userId: String) {
        isLoading = true
        
        // Add debug print
        print("Loading conversations for user: \(userId)")
        
        // Try to load from Firebase, but with better error handling
        let query = db.collection("conversations")
            .whereField("participantIds", arrayContains: userId)
        
        let listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading conversations: \(error.localizedDescription)")
                // On permission error, just use local conversations instead of showing error
                if error.localizedDescription.contains("permission") {
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No conversations found in Firestore")
                // Keep using local conversations if Firestore returns empty
                self.isLoading = false
                return
            }
            
            // If we got here, we have Firebase data, so we can replace our local data
            self.conversations = []
            self.processConversations(documents, userId: userId)
        }
        
        conversationListeners.append(listener)
        
        // Set a timeout to ensure UI doesn't stay in loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.isLoading == true {
                self?.isLoading = false
            }
        }
    }
    
    // Rest of the methods modified to handle permissions better
    
    private func processConversations(_ documents: [QueryDocumentSnapshot], userId: String) {
        // Process conversation documents with better error handling
        for document in documents {
            let conversationId = document.documentID
            
            do {
                // Get conversation data
                guard let data = document.data() as [String: Any]?,
                      let title = data["title"] as? String,
                      let isPublic = data["isPublic"] as? Bool,
                      let participantIds = data["participantIds"] as? [String] else {
                    continue
                }
                
                // Create placeholder participants
                let participants = participantIds.map { participantId -> ChatUser in
                    return ChatUser(
                        id: participantId,
                        name: participantId == userId ? "You" : "User \(participantId.prefix(4))",
                        avatar: participantId == userId ? "person.crop.circle.fill" : "person.fill",
                        isVerified: false,
                        isOnline: true
                    )
                }
                
                // Try to load messages, but with fallback
                let messageListener = self.db.collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 20) // Limit for performance
                    .addSnapshotListener { [weak self] messagesSnapshot, messagesError in
                        guard let self = self else { return }
                        
                        var messages: [ChatMessage] = []
                        
                        if let messagesError = messagesError {
                            print("Error loading messages: \(messagesError.localizedDescription)")
                            // Create a fallback message
                            messages = [self.createFallbackMessage(for: participants.first ?? participants[0])]
                        } else if let messageDocuments = messagesSnapshot?.documents {
                            // Process actual messages
                            messages = self.processMessageDocuments(messageDocuments, participants: participants)
                        }
                        
                        // Create the conversation with whatever messages we have
                        let conversation = ChatConversation(
                            id: conversationId,
                            participants: participants,
                            messages: messages,
                            isPublic: isPublic,
                            title: title
                        )
                        
                        // Update in our published list
                        if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
                            self.conversations[index] = conversation
                        } else {
                            self.conversations.append(conversation)
                        }
                    }
                
                self.conversationListeners.append(messageListener)
            } catch {
                print("Error processing conversation \(conversationId): \(error)")
            }
        }
        
        self.isLoading = false
    }
    
    private func processMessageDocuments(_ documents: [QueryDocumentSnapshot], participants: [ChatUser]) -> [ChatMessage] {
        var messages: [ChatMessage] = []
        
        for document in documents {
            do {
                let data = document.data()
                
                guard let content = data["content"] as? String,
                      let senderId = data["senderId"] as? String else {
                    continue
                }
                
                // Handle missing or invalid fields gracefully
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let isAlert = data["isAlert"] as? Bool ?? false
                let isRead = data["isRead"] as? Bool ?? false
                
                // Find sender in participants, or create a placeholder
                let sender = participants.first(where: { $0.id == senderId }) ?? 
                             ChatUser(id: senderId, name: "User", avatar: "person.fill", 
                                     isVerified: false, isOnline: false)
                
                let message = ChatMessage(
                    id: document.documentID,
                    content: content,
                    timestamp: timestamp,
                    sender: sender,
                    isAlert: isAlert,
                    isRead: isRead
                )
                
                messages.append(message)
            } catch {
                print("Error processing message: \(error)")
            }
        }
        
        return messages
    }
    
    // Create a fallback message when there's a permission issue
    private func createFallbackMessage(for user: ChatUser) -> ChatMessage {
        return ChatMessage(
            id: "fallback_\(UUID().uuidString)",
            content: "Welcome to the conversation! Messages will appear here.",
            timestamp: Date(),
            sender: user,
            isAlert: false,
            isRead: true
        )
    }
    
    // Send a message with better error handling
    func sendMessage(conversationId: String, content: String, senderId: String, isAlert: Bool = false) {
        // First update the local conversation immediately for responsiveness
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            let sender = conversations[index].participants.first(where: { $0.id == senderId }) ?? 
                         ChatUser(id: senderId, name: "You", avatar: "person.crop.circle.fill", 
                                 isVerified: true, isOnline: true)
            
            let newMessage = ChatMessage(
                id: UUID().uuidString,
                content: content,
                timestamp: Date(),
                sender: sender,
                isAlert: isAlert,
                isRead: true
            )
            
            // Add to local conversation
            conversations[index].messages.append(newMessage)
        }
        
        // Then try to send to Firebase
        let messageRef = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document()
        
        let messageData: [String: Any] = [
            "content": content,
            "timestamp": FieldValue.serverTimestamp(),
            "senderId": senderId,
            "isAlert": isAlert,
            "isRead": false
        ]
        
        messageRef.setData(messageData) { [weak self] error in
            if let error = error {
                print("Error sending message to Firebase: \(error.localizedDescription)")
                // Just show an error toast or notification here if needed
            } else {
                // Update the conversation's last activity timestamp
                self?.db.collection("conversations").document(conversationId).updateData([
                    "lastActivity": FieldValue.serverTimestamp()
                ])
            }
        }
    }
    
    // Mark messages as read with better error handling
    func markMessagesAsRead(conversationId: String, messageIds: [String]) {
        // First update local state
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            for i in 0..<conversations[index].messages.count {
                if messageIds.contains(conversations[index].messages[i].id) {
                    conversations[index].messages[i].isRead = true
                }
            }
        }
        
        // Then try to update in Firebase
        let batch = db.batch()
        
        for messageId in messageIds {
            let messageRef = db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(messageId)
            
            batch.updateData(["isRead": true], forDocument: messageRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error marking messages as read in Firebase: \(error.localizedDescription)")
                // Just continue with local state updates
            }
        }
    }
    
    // Create a new conversation
    func createConversation(title: String, participantIds: [String], isPublic: Bool, completion: @escaping (String?) -> Void) {
        // Generate a local ID
        let conversationId = UUID().uuidString
        
        // Create participants
        let participants = participantIds.map { participantId -> ChatUser in
            return ChatUser(
                id: participantId,
                name: participantId == "current_user_id" ? "You" : "User \(participantId.prefix(4))",
                avatar: participantId == "current_user_id" ? "person.crop.circle.fill" : "person.fill",
                isVerified: false,
                isOnline: true
            )
        }
        
        // Create welcome message
        let welcomeMessage = ChatMessage(
            id: UUID().uuidString,
            content: isPublic ? "Welcome to the new channel!" : "This is the start of your conversation.",
            timestamp: Date(),
            sender: participants.first ?? ChatUser(id: "system", name: "System", avatar: "gear", isVerified: true, isOnline: true),
            isAlert: false,
            isRead: true
        )
        
        // Create local conversation
        let newConversation = ChatConversation(
            id: conversationId,
            participants: participants,
            messages: [welcomeMessage],
            isPublic: isPublic,
            title: title
        )
        
        // Add to published conversations
        conversations.append(newConversation)
        
        // Try to create in Firebase
        let conversationRef = db.collection("conversations").document(conversationId)
        
        let conversationData: [String: Any] = [
            "title": title,
            "participantIds": participantIds,
            "isPublic": isPublic,
            "createdAt": FieldValue.serverTimestamp(),
            "lastActivity": FieldValue.serverTimestamp()
        ]
        
        conversationRef.setData(conversationData) { error in
            if let error = error {
                print("Error creating conversation in Firebase: \(error.localizedDescription)")
                // Return the local ID anyway so UI continues to work
                completion(conversationId)
            } else {
                // Add welcome message to Firebase
                conversationRef.collection("messages").document(welcomeMessage.id).setData([
                    "content": welcomeMessage.content,
                    "timestamp": FieldValue.serverTimestamp(),
                    "senderId": welcomeMessage.sender.id,
                    "isAlert": welcomeMessage.isAlert,
                    "isRead": welcomeMessage.isRead
                ])
                
                completion(conversationId)
            }
        }
    }
}