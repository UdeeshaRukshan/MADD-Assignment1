import SwiftUI

// MARK: - Models
// MARK: - Models
struct ChatUser: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let avatar: String // System image name
    let isVerified: Bool
    let isOnline: Bool
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(avatar)
        hasher.combine(isVerified)
        hasher.combine(isOnline)
    }
    
    static func ==(lhs: ChatUser, rhs: ChatUser) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let sender: ChatUser
    let isAlert: Bool
    var isRead: Bool = false
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(content)
        hasher.combine(timestamp)
        hasher.combine(sender)
        hasher.combine(isAlert)
        hasher.combine(isRead)
    }
    
    static func ==(lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatConversation: Identifiable, Hashable {
    let id = UUID()
    let participants: [ChatUser]
    var messages: [ChatMessage]
    let isPublic: Bool
    let title: String
    
    var lastMessage: ChatMessage? {
        messages.sorted(by: { $0.timestamp > $1.timestamp }).first
    }
    
    var unreadCount: Int {
        messages.filter { !$0.isRead }.count
    }
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(isPublic)
        hasher.combine(participants)
        hasher.combine(messages)
    }
    
    static func ==(lhs: ChatConversation, rhs: ChatConversation) -> Bool {
        return lhs.id == rhs.id
    }
}




// MARK: - Chat List View
struct ChatListView: View {
    // Current user
    let currentUser = ChatUser(
        name: "You",
        avatar: "person.crop.circle.fill",
        isVerified: true,
        isOnline: true
    )
    
    // Sample users
    let officer1 = ChatUser(
        name: "Officer Johnson",
        avatar: "person.crop.circle.badge.checkmark.fill",
        isVerified: true,
        isOnline: true
    )
    
    let officer2 = ChatUser(
        name: "Officer Martinez",
        avatar: "person.crop.circle.badge.checkmark.fill",
        isVerified: true,
        isOnline: false
    )
    
    let neighbor1 = ChatUser(
        name: "Sarah Thompson",
        avatar: "person.crop.circle.fill",
        isVerified: false,
        isOnline: true
    )
    
    let neighbor2 = ChatUser(
        name: "Mike Chen",
        avatar: "person.crop.circle.fill",
        isVerified: false,
        isOnline: false
    )
    
    // State variables
    @State private var showingPublicChats = true
    @State private var selectedConversation: ChatConversation?
    @State private var searchText = ""
    @State private var conversations: [ChatConversation] = []
    
    var filteredConversations: [ChatConversation] {
        let filtered = conversations.filter { $0.isPublic == showingPublicChats }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { conversation in
                conversation.title.lowercased().contains(searchText.lowercased()) ||
                conversation.messages.contains { message in
                    message.content.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented control for public/private chats
                Picker("Chat Type", selection: $showingPublicChats) {
                    Text("Public Channels").tag(true)
                    Text("Private Messages").tag(false)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // Chat list
                List {
                    ForEach(filteredConversations) { conversation in
                        NavigationLink(value: conversation) {
                            ChatRowView(conversation: conversation)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Chats")
            .navigationDestination(for: ChatConversation.self) { conversation in
                ChatDetailView(conversation: conversation, currentUser: currentUser)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to create new chat
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                // Initialize sample conversations if empty
                if conversations.isEmpty {
                    initializeConversations()
                }
            }
        }
    }
    
    // Initialize sample conversations
    private func initializeConversations() {
        // Sample conversations
        let publicAlerts = ChatConversation(
            participants: [officer1, officer2, neighbor1, neighbor2],
            messages: [
                ChatMessage(
                    content: "ALERT: Suspicious activity reported near Oak Street and 5th Avenue. Please stay vigilant.",
                    timestamp: Date().addingTimeInterval(-3600),
                    sender: officer1,
                    isAlert: true
                ),
                ChatMessage(
                    content: "I saw someone checking car doors in that area around 9pm.",
                    timestamp: Date().addingTimeInterval(-3400),
                    sender: neighbor1,
                    isAlert: false
                ),
                ChatMessage(
                    content: "We've dispatched a patrol car to investigate. Thank you for the report.",
                    timestamp: Date().addingTimeInterval(-3200),
                    sender: officer1,
                    isAlert: false
                )
            ],
            isPublic: true,
            title: "Neighborhood Alerts"
        )
        
        let communityChat = ChatConversation(
            participants: [officer1, neighbor1, neighbor2],
            messages: [
                ChatMessage(
                    content: "The community watch meeting is scheduled for this Friday at 7pm in the community center.",
                    timestamp: Date().addingTimeInterval(-86400),
                    sender: officer1,
                    isAlert: false
                ),
                ChatMessage(
                    content: "Will there be any training on how to report suspicious activities?",
                    timestamp: Date().addingTimeInterval(-80000),
                    sender: neighbor2,
                    isAlert: false
                ),
                ChatMessage(
                    content: "Yes, we'll cover the reporting process and what details are most helpful for investigations.",
                    timestamp: Date().addingTimeInterval(-79000),
                    sender: officer1,
                    isAlert: false
                )
            ],
            isPublic: true,
            title: "Community Discussion"
        )
        
        let privateChat1 = ChatConversation(
            participants: [officer1],
            messages: [
                ChatMessage(
                    content: "I'd like to report a recurring issue with teenagers gathering in the park after hours.",
                    timestamp: Date().addingTimeInterval(-7200),
                    sender: currentUser,
                    isAlert: false
                ),
                ChatMessage(
                    content: "Thank you for letting us know. What time do they usually gather?",
                    timestamp: Date().addingTimeInterval(-7100),
                    sender: officer1,
                    isAlert: false,
                    isRead: false
                )
            ],
            isPublic: false,
            title: "Officer Johnson"
        )
        
        let privateChat2 = ChatConversation(
            participants: [neighbor1],
            messages: [
                ChatMessage(
                    content: "Hi Sarah, did you also get the alert about the suspicious activity?",
                    timestamp: Date().addingTimeInterval(-43200),
                    sender: currentUser,
                    isAlert: false
                ),
                ChatMessage(
                    content: "Yes, I've been keeping my porch light on and making sure all doors are locked.",
                    timestamp: Date().addingTimeInterval(-42000),
                    sender: neighbor1,
                    isAlert: false,
                    isRead: true
                )
            ],
            isPublic: false,
            title: "Sarah Thompson"
        )
        
        conversations = [publicAlerts, communityChat, privateChat1, privateChat2]
    }
}

// MARK: - Chat Row View
struct ChatRowView: View {
    let conversation: ChatConversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar or group icon
            if conversation.isPublic {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: conversation.title.contains("Alert") ? "bell.fill" : "person.3.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 22))
                }
            } else {
                Image(systemName: conversation.participants.first?.avatar ?? "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if !conversation.isPublic && conversation.participants.first?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                    }
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(formatDate(lastMessage.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        if lastMessage.isAlert {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                        }
                        
                        Text(lastMessage.sender.name == "You" ? "You: \(lastMessage.content)" : lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(lastMessage.isAlert ? .orange : .gray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Chat Detail View
struct ChatDetailView: View {
    @State var conversation: ChatConversation
    let currentUser: ChatUser
    @State private var messageText = ""
    @State private var isShowingAttachmentOptions = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(conversation.messages.sorted(by: { $0.timestamp < $1.timestamp })) { message in
                        MessageBubble(message: message, isFromCurrentUser: message.sender.name == currentUser.name)
                    }
                }
                .padding()
            }
            
            // Message input
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        isShowingAttachmentOptions.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    TextField("Type a message", text: $messageText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                
                if isShowingAttachmentOptions {
                    HStack(spacing: 20) {
                        AttachmentButton(icon: "camera.fill", label: "Photo")
                        AttachmentButton(icon: "location.fill", label: "Location")
                        AttachmentButton(icon: "exclamationmark.triangle.fill", label: "Alert")
                        AttachmentButton(icon: "doc.fill", label: "Document")
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                }
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle(conversation.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !conversation.isPublic {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Call action
                    }) {
                        Image(systemName: "phone.fill")
                    }
                }
            }
        }
        .onAppear {
            // Mark messages as read
            for i in 0..<conversation.messages.count {
                conversation.messages[i].isRead = true
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            content: messageText,
            timestamp: Date(),
            sender: currentUser,
            isAlert: false
        )
        
        conversation.messages.append(newMessage)
        messageText = ""
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isFromCurrentUser {
                    Text(message.sender.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                
                HStack {
                    if message.isAlert && !isFromCurrentUser {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
                    
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            message.isAlert ? Color.orange :
                                (isFromCurrentUser ? Color.blue : Color(.systemGray5))
                        )
                        .foregroundColor(
                            (isFromCurrentUser || message.isAlert) ? .white : .primary
                        )
                        .cornerRadius(16)
                }
                
                HStack {
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if isFromCurrentUser {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 10))
                            .foregroundColor(message.isRead ? .blue : .gray)
                    }
                }
                .padding(.horizontal, 8)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Attachment Button
struct AttachmentButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ChatListView()
}
