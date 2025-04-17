import SwiftUI

// MARK: - Models
struct ChatUser: Identifiable, Hashable {
    let id: String
    let name: String
    let avatar: String // System image name
    let isVerified: Bool
    let isOnline: Bool
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: ChatUser, rhs: ChatUser) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let content: String
    let timestamp: Date
    let sender: ChatUser
    let isAlert: Bool
    var isRead: Bool
    
    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatConversation: Identifiable, Hashable {
    let id: String
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
    }
    
    static func ==(lhs: ChatConversation, rhs: ChatConversation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Chat List View
struct ChatListView: View {
    @StateObject private var chatService = FirebaseChatService()
    @State private var showingPublicChats = true
    @State private var searchText = ""
    @State private var showingNewChatSheet = false
    
    // Current user - In a real app, this would come from your auth system
    let currentUser = ChatUser(
        id: "current_user_id",
        name: "You",
        avatar: "person.crop.circle.fill",
        isVerified: true,
        isOnline: true
    )
    
    var filteredConversations: [ChatConversation] {
        let filtered = chatService.conversations.filter { $0.isPublic == showingPublicChats }
        
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
                if chatService.isLoading {
                    ProgressView("Loading conversations...")
                        .padding()
                } else if let errorMessage = chatService.errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                        
                        Button("Retry") {
                            chatService.loadConversations(for: currentUser.id)
                        }
                        .buttonStyle(.bordered)
                    }
                } else if filteredConversations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: showingPublicChats ? "person.3.fill" : "message.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.top, 80)
                        
                        Text(showingPublicChats ? "No Public Channels" : "No Private Messages")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(showingPublicChats ? 
                             "Join a public channel or create one" : 
                             "Start a conversation with someone")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showingNewChatSheet = true
                        }) {
                            Label(showingPublicChats ? "Create Channel" : "Start Conversation", 
                                 systemImage: "plus.circle.fill")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(20)
                        }
                        .padding(.top, 10)
                    }
                } else {
                    List {
                        ForEach(filteredConversations) { conversation in
                            NavigationLink(value: conversation) {
                                ChatRowView(conversation: conversation)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        chatService.loadConversations(for: currentUser.id)
                    }
                }
            }
            .navigationTitle("Chats")
            .navigationDestination(for: ChatConversation.self) { conversation in
                let viewModel = ConversationViewModel(conversation: conversation, chatService: chatService)
                ChatDetailView(conversationViewModel: viewModel, currentUser: currentUser, chatService: chatService)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewChatSheet = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingNewChatSheet) {
                NewChatView(chatService: chatService, currentUser: currentUser, isPublic: showingPublicChats)
            }
            .onAppear {
                chatService.loadConversations(for: currentUser.id)
            }
        }
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
    @ObservedObject var conversationViewModel: ConversationViewModel
    let currentUser: ChatUser
    @ObservedObject var chatService: FirebaseChatService
    @State private var messageText = ""
    @State private var isShowingAttachmentOptions = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(conversationViewModel.conversation.messages.sorted(by: { $0.timestamp < $1.timestamp })) { message in
                        MessageBubble(message: message, isFromCurrentUser: message.sender.id == currentUser.id)
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)
            
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
                        AttachmentButton(icon: "exclamationmark.triangle.fill", label: "Alert", action: {
                            sendAlertMessage()
                        })
                        AttachmentButton(icon: "doc.fill", label: "Document")
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                }
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle(conversationViewModel.conversation.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !conversationViewModel.conversation.isPublic {
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
            print("ChatDetailView appeared with \(conversationViewModel.conversation.messages.count) messages")
            conversationViewModel.conversation.messages.forEach { message in
                print("Message: \(message.content) from \(message.sender.name)")
            }
            
            // Mark messages as read
            let unreadMessageIds = conversationViewModel.conversation.messages
                .filter { !$0.isRead && $0.sender.id != currentUser.id }
                .map { $0.id }
            
            if !unreadMessageIds.isEmpty {
                chatService.markMessagesAsRead(conversationId: conversationViewModel.conversation.id, messageIds: unreadMessageIds)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        conversationViewModel.addMessage(
            content: messageText,
            senderId: currentUser.id,
            isAlert: false
        )
        
        messageText = ""
    }
    
    private func sendAlertMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        conversationViewModel.addMessage(
            content: messageText,
            senderId: currentUser.id,
            isAlert: true
        )
        
        messageText = ""
        isShowingAttachmentOptions = false
    }
}

// MARK: - Conversation ViewModel
class ConversationViewModel: ObservableObject {
    @Published var conversation: ChatConversation
    private let chatService: FirebaseChatService
    
    init(conversation: ChatConversation, chatService: FirebaseChatService) {
        self.conversation = conversation
        self.chatService = chatService
    }
    
    func addMessage(content: String, senderId: String, isAlert: Bool) {
        chatService.sendMessage(
            conversationId: conversation.id,
            content: content,
            senderId: senderId,
            isAlert: isAlert
        )
    }
}

// MARK: - New Chat View
struct NewChatView: View {
    @ObservedObject var chatService: FirebaseChatService
    let currentUser: ChatUser
    let isPublic: Bool
    
    @State private var title = ""
    @State private var selectedUsers: [ChatUser] = []
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    // In a real app, you'd fetch this from Firebase
    let availableUsers: [ChatUser] = [
        ChatUser(
            id: "officer1",
            name: "Officer Johnson",
            avatar: "person.crop.circle.badge.checkmark.fill",
            isVerified: true,
            isOnline: true
        ),
        ChatUser(
            id: "officer2",
            name: "Officer Martinez",
            avatar: "person.crop.circle.badge.checkmark.fill",
            isVerified: true,
            isOnline: false
        ),
        ChatUser(
            id: "neighbor1",
            name: "Sarah Thompson",
            avatar: "person.crop.circle.fill",
            isVerified: false,
            isOnline: true
        ),
        ChatUser(
            id: "neighbor2",
            name: "Mike Chen",
            avatar: "person.crop.circle.fill",
            isVerified: false,
            isOnline: false
        )
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Conversation title", text: $title)
                }
                
                if !isPublic {
                    Section(header: Text("Select Users")) {
                        ForEach(availableUsers) { user in
                            Button(action: {
                                toggleUserSelection(user)
                            }) {
                                HStack {
                                    Image(systemName: user.avatar)
                                        .foregroundColor(.blue)
                                    
                                    Text(user.name)
                                    
                                    Spacer()
                                    
                                    if selectedUsers.contains(where: { $0.id == user.id }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                Section {
                    Button(action: createConversation) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text(isPublic ? "Create Public Channel" : "Start Conversation")
                                .foregroundColor(.blue)
                        }
                    }
                    .disabled(isLoading || title.isEmpty || (!isPublic && selectedUsers.isEmpty))
                }
            }
            .navigationTitle(isPublic ? "New Public Channel" : "New Conversation")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleUserSelection(_ user: ChatUser) {
        if let index = selectedUsers.firstIndex(where: { $0.id == user.id }) {
            selectedUsers.remove(at: index)
        } else {
            selectedUsers.append(user)
        }
    }
    
    private func createConversation() {
        isLoading = true
        
        // In a public chat, we might want to include all users automatically
        var participantIds = selectedUsers.map { $0.id }
        
        // Always include the current user
        if !participantIds.contains(currentUser.id) {
            participantIds.append(currentUser.id)
        }
        
        chatService.createConversation(
            title: title,
            participantIds: participantIds,
            isPublic: isPublic
        ) { conversationId in
            isLoading = false
            
            if conversationId != nil {
                dismiss()
            } else {
                // Handle error - in a real app, show an alert
            }
        }
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
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
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
}

#Preview {
    ChatListView()
}
