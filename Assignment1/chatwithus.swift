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
    @State private var selectedConversation: ChatConversation? // Use this for programmatic navigation
    
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
            ZStack {
                // Add the modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "141E30"),
                        Color(hex: "243B55")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom title styling to match theme
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MESSAGES")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(Color(hex: "64B5F6"))
                                .kerning(2)
                            
                            Text("Communications Center")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingNewChatSheet = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    
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
                            .foregroundColor(Color(hex: "64B5F6"))
                        
                        TextField("Search", text: $searchText)
                            .foregroundColor(.white)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    // Chat list
                    if chatService.isLoading {
                        ProgressView("Loading conversations...")
                            .foregroundColor(.white)
                            .padding()
                    } else if let errorMessage = chatService.errorMessage {
                        VStack {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(Color(hex: "FF416C"))
                                .padding()
                            
                            Button("Retry") {
                                chatService.loadConversations(for: currentUser.id)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "64B5F6").opacity(0.2))
                            .foregroundColor(Color(hex: "64B5F6"))
                            .cornerRadius(10)
                        }
                    } else if filteredConversations.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: showingPublicChats ? "person.3.fill" : "message.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "64B5F6").opacity(0.6))
                                .padding(.top, 80)
                            
                            Text(showingPublicChats ? "No Public Channels" : "No Private Messages")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
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
                                    .background(Color(hex: "64B5F6").opacity(0.2))
                                    .foregroundColor(Color(hex: "64B5F6"))
                                    .cornerRadius(20)
                            }
                            .padding(.top, 10)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredConversations) { conversation in
                                    Button {
                                        // Set the selected conversation for navigation
                                        selectedConversation = conversation
                                    } label: {
                                        ChatRowView(conversation: conversation)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color(hex: "1A2133"))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: Binding(
                get: { selectedConversation != nil },
                set: { if !$0 { selectedConversation = nil } }
            )) {
                if let conversation = selectedConversation {
                    let viewModel = ConversationViewModel(conversation: conversation, chatService: chatService)
                    ChatDetailView(
                        conversationViewModel: viewModel, 
                        currentUser: currentUser, 
                        chatService: chatService, 
                        onDismiss: { selectedConversation = nil }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewChatSheet = true
                    } label: {
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
                        .fill(Color(hex: "2D4263").opacity(0.7))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: conversation.title.contains("Alert") ? "bell.fill" : "person.3.fill")
                        .foregroundColor(Color(hex: "64D2FF"))
                        .font(.system(size: 22))
                }
            } else {
                Image(systemName: conversation.participants.first?.avatar ?? "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(hex: "64D2FF"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.title)
                        .font(.headline)
                        .foregroundColor(Color(hex: "E0E0E0"))
                        .lineLimit(1)
                    
                    if !conversation.isPublic && conversation.participants.first?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(hex: "4A90E2"))
                            .font(.system(size: 12))
                    }
                    
                    Spacer()
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(formatDate(lastMessage.timestamp))
                            .font(.caption)
                            .foregroundColor(Color(hex: "9EAFC2"))
                    }
                }
                
                HStack {
                    if let lastMessage = conversation.lastMessage {
                        if lastMessage.isAlert {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Color(hex: "FF6B6B"))
                                .font(.system(size: 12))
                        }
                        
                        Text(lastMessage.sender.name == "You" ? "You: \(lastMessage.content)" : lastMessage.content)
                            .font(.subheadline)
                            .foregroundColor(lastMessage.isAlert ? Color(hex: "FF6B6B") : Color(hex: "9EAFC2"))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "4A90E2"))
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
    var onDismiss: (() -> Void)? // Add this callback
    
    var body: some View {
        ZStack {
            // Add the modern gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "141E30"),
                    Color(hex: "243B55")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Button {
                        // Call custom dismiss action first
                        // Then dismiss the view
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Spacer()
                    
                    Text(conversationViewModel.conversation.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if !conversationViewModel.conversation.isPublic {
                        Button(action: {
                            // Call action
                        }) {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color(hex: "1A2133"))
                
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
                        .background(Color.white.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            isShowingAttachmentOptions.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "64B5F6"))
                        }
                        
                        TextField("Type a message", text: $messageText)
                            .padding(10)
                            .background(Color(hex: "1A2133"))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(messageText.isEmpty ? Color.gray : Color(hex: "64B5F6"))
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding()
                    .background(Color(hex: "243B55"))
                    
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
                        .background(Color(hex: "243B55"))
                    }
                }
            }
        }
        .onAppear {
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
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 8) {
            HStack {
                if isFromCurrentUser {
                    Spacer()
                }
                
                VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                    if !isFromCurrentUser {
                        Text(message.sender.name)
                            .font(.caption)
                            .foregroundColor(Color(hex: "9EAFC2"))
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
                                message.isAlert ? Color(hex: "FF5252") :
                                    (isFromCurrentUser ? Color(hex: "4A90E2") : Color(hex: "2A3142"))
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    
                    HStack {
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(Color(hex: "9EAFC2"))
                        
                        if isFromCurrentUser {
                            Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.system(size: 10))
                                .foregroundColor(message.isRead ? Color(hex: "5CDB95") : Color(hex: "9EAFC2"))
                        }
                    }
                    .padding(.horizontal, 8)
                }
                
                if !isFromCurrentUser {
                    Spacer()
                }
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
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "4A90E2"),
                                Color(hex: "64D2FF")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(hex: "4A90E2").opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color(hex: "E0E0E0"))
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var dotsOpacity: Double = 0.3
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 6, height: 6)
                    .opacity(dotsOpacity)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: dotsOpacity
                    )
            }
        }
        .padding(8)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .onAppear {
            dotsOpacity = 0.9
        }
    }
}


// MARK: - Voice Message Recorder
struct VoiceMessageRecorder: View {
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    var onComplete: (URL) -> Void
    
    var body: some View {
        VStack {
            if isRecording {
                HStack {
                    Text(timeString(from: recordingTime))
                        .font(.title2)
                        .monospacedDigit()
                    
                    // Waveform visualization
                    ForEach(0..<10, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: 3, height: CGFloat.random(in: 5...30))
                            .animation(.easeInOut(duration: 0.2), value: isRecording)
                    }
                }
                .padding()
                
                Button(action: stopRecording) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.red)
                }
            } else {
                Button(action: startRecording) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func startRecording() {
        // Permission and recording setup would go here
        isRecording = true
        recordingTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        isRecording = false
        
        // Here you would stop recording and get the URL
        // For demo, we're creating a mock URL
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioUrl = documentsPath.appendingPathComponent("recording.m4a")
        
        onComplete(audioUrl)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let tenths = Int((timeInterval - floor(timeInterval)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, tenths)
    }
}

#Preview {
    ChatListView()
}
