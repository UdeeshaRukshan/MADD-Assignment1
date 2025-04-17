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
    
    // Load all conversations for the current user
    func loadConversations(for userId: String) {
        isLoading = true
        
        // Add debug print
        print("Loading conversations for user: \(userId)")
        
        // For debugging: Add a dummy conversation if none are found after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            
            if self.conversations.isEmpty {
                print("Creating dummy conversation for testing")
                let dummyUser = ChatUser(
                    id: "dummy_user",
                    name: "Test User",
                    avatar: "person.circle",
                    isVerified: true,
                    isOnline: true
                )
                
                let dummyMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: "This is a test message from Firebase service",
                    timestamp: Date(),
                    sender: dummyUser,
                    isAlert: false,
                    isRead: false
                )
                
                let dummyConversation = ChatConversation(
                    id: "dummy_convo",
                    participants: [dummyUser],
                    messages: [dummyMessage],
                    isPublic: true,
                    title: "Test Conversation"
                )
                
                self.conversations.append(dummyConversation)
                self.isLoading = false
            }
        }
        
        // Query conversations where the user is a participant
        let query = db.collection("conversations")
            .whereField("participantIds", arrayContains: userId)
        
        let listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error loading conversations: \(error.localizedDescription)"
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.errorMessage = "No conversations found"
                self.isLoading = false
                return
            }
            
            // Process the documents into conversations
            self.processConversations(documents, userId: userId)
        }
        
        conversationListeners.append(listener)
    }
    
    private func processConversations(_ documents: [QueryDocumentSnapshot], userId: String) {
        // Clear current conversations
        self.conversations = []
        
        // For each conversation document
        for document in documents {
            let conversationId = document.documentID
            
            // Get conversation data
            guard let data = document.data() as [String: Any]?,
                  let title = data["title"] as? String,
                  let isPublic = data["isPublic"] as? Bool,
                  let participantIds = data["participantIds"] as? [String] else {
                continue
            }
            
            // Load participants (we'll fetch user details in a separate step)
            var participants: [ChatUser] = []
            
            // Load messages for this conversation
            let messageListener = self.db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { [weak self] messagesSnapshot, messagesError in
                    guard let self = self else { return }
                    
                    if let messagesError = messagesError {
                        self.errorMessage = "Error loading messages: \(messagesError.localizedDescription)"
                        return
                    }
                    
                    guard let messageDocuments = messagesSnapshot?.documents else { return }
                    
                    // Load participant details first (only if needed)
                    if participants.isEmpty {
                        self.loadParticipantDetails(participantIds) { fetchedParticipants in
                            participants = fetchedParticipants
                            
                            // Then process messages
                            self.processMessages(messageDocuments, conversationId: conversationId, 
                                              title: title, isPublic: isPublic, participants: participants)
                        }
                    } else {
                        // If we already have participants, just process messages
                        self.processMessages(messageDocuments, conversationId: conversationId, 
                                          title: title, isPublic: isPublic, participants: participants)
                    }
                }
            
            self.conversationListeners.append(messageListener)
        }
        
        self.isLoading = false
    }
    
    private func loadParticipantDetails(_ participantIds: [String], completion: @escaping ([ChatUser]) -> Void) {
        var participants: [ChatUser] = []
        let group = DispatchGroup()
        
        for participantId in participantIds {
            group.enter()
            
            db.collection("users").document(participantId).getDocument { snapshot, error in
                defer { group.leave() }
                
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                let user = ChatUser(
                    id: participantId,
                    name: data["name"] as? String ?? "Unknown User",
                    avatar: data["avatar"] as? String ?? "person.crop.circle.fill",
                    isVerified: data["isVerified"] as? Bool ?? false,
                    isOnline: data["isOnline"] as? Bool ?? false
                )
                
                participants.append(user)
            }
        }
        
        group.notify(queue: .main) {
            completion(participants)
        }
    }
    
    private func processMessages(_ messageDocuments: [QueryDocumentSnapshot], 
                              conversationId: String, title: String, 
                              isPublic: Bool, participants: [ChatUser]) {
        var messages: [ChatMessage] = []
        
        for messageDoc in messageDocuments {
            let messageData = messageDoc.data()
            
            guard let content = messageData["content"] as? String,
                  let timestamp = (messageData["timestamp"] as? Timestamp)?.dateValue(),
                  let senderId = messageData["senderId"] as? String,
                  let isAlert = messageData["isAlert"] as? Bool,
                  let isRead = messageData["isRead"] as? Bool else {
                continue
            }
            
            // Find the sender in participants
            let sender = participants.first(where: { $0.id == senderId }) ?? 
                         ChatUser(id: senderId, name: "Unknown", avatar: "person.fill", 
                                 isVerified: false, isOnline: false)
            
            let message = ChatMessage(
                id: messageDoc.documentID,
                content: content,
                timestamp: timestamp,
                sender: sender,
                isAlert: isAlert,
                isRead: isRead
            )
            
            messages.append(message)
        }
        
        // Create or update the conversation
        let conversation = ChatConversation(
            id: conversationId,
            participants: participants,
            messages: messages,
            isPublic: isPublic,
            title: title
        )
        
        // Update the conversation in our published list
        if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
            self.conversations[index] = conversation
        } else {
            self.conversations.append(conversation)
        }
    }
    
    // Send a new message
    func sendMessage(conversationId: String, content: String, senderId: String, isAlert: Bool = false) {
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
        
        messageRef.setData(messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
        
        // Also update the conversation's last activity timestamp
        db.collection("conversations").document(conversationId).updateData([
            "lastActivity": FieldValue.serverTimestamp()
        ])
    }
    
    // Mark messages as read
    func markMessagesAsRead(conversationId: String, messageIds: [String]) {
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
                print("Error marking messages as read: \(error.localizedDescription)")
            }
        }
    }
    
    // Create a new conversation
    func createConversation(title: String, participantIds: [String], isPublic: Bool, completion: @escaping (String?) -> Void) {
        let conversationRef = db.collection("conversations").document()
        
        let conversationData: [String: Any] = [
            "title": title,
            "participantIds": participantIds,
            "isPublic": isPublic,
            "createdAt": FieldValue.serverTimestamp(),
            "lastActivity": FieldValue.serverTimestamp()
        ]
        
        conversationRef.setData(conversationData) { error in
            if let error = error {
                print("Error creating conversation: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(conversationRef.documentID)
            }
        }
    }
}