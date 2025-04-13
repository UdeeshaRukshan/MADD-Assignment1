import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditing = false
    @State private var showImagePicker = false
    @State private var showSettingsSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                ZStack(alignment: .bottom) {
                    // Background header gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                        .clipShape(RoundedShape(corners: [.bottomLeft, .bottomRight], radius: 30))
                    
                    // Profile image
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            if let profileImage = viewModel.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            
                            if isEditing {
                                Button {
                                    showImagePicker = true
                                } label: {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.white)
                                        )
                                }
                                .offset(x: 42, y: 42)
                            }
                        }
                        
                        if isEditing {
                            TextField("Enter your name", text: $viewModel.name)
                                .font(.title2.bold())
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        } else {
                            Text(viewModel.name)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        
                        Text(viewModel.role)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .offset(y: 60)
                }
                .padding(.bottom, 70)
                
                // Stats cards
                HStack(spacing: 16) {
                    StatCard(title: "Reports", value: "\(viewModel.reportCount)", icon: "exclamationmark.triangle.fill", color: .red)
                    StatCard(title: "Alerts", value: "\(viewModel.alertCount)", icon: "bell.fill", color: .orange)
                    StatCard(title: "Badges", value: "\(viewModel.badges.count)", icon: "star.fill", color: .yellow)
                }
                .padding(.horizontal)
                
                // User Information Section
                VStack(alignment: .leading, spacing: 20) {
                    // Personal Information
                    SectionContainer(title: "Personal Information") {
                        if isEditing {
                            InfoEditRow(icon: "envelope.fill", title: "Email", value: $viewModel.email)
                            InfoEditRow(icon: "phone.fill", title: "Phone", value: $viewModel.phone)
                            InfoEditRow(icon: "mappin.circle.fill", title: "Location", value: $viewModel.location)
                        } else {
                            InfoRow(icon: "envelope.fill", title: "Email", value: viewModel.email)
                            InfoRow(icon: "phone.fill", title: "Phone", value: viewModel.phone)
                            InfoRow(icon: "mappin.circle.fill", title: "Location", value: viewModel.location)
                        }
                    }
                    
                    // Notification Settings
                    SectionContainer(title: "Notification Settings") {
                        ToggleRow(icon: "bell.fill", title: "Crime Alerts", isOn: $viewModel.crimeAlertsEnabled)
                        ToggleRow(icon: "bell.badge.fill", title: "Nearby Warnings", isOn: $viewModel.nearbyWarningsEnabled)
                        ToggleRow(icon: "speaker.wave.2.fill", title: "Sound Alerts", isOn: $viewModel.soundAlertsEnabled)
                    }
                    
                    // Badges Section
                    SectionContainer(title: "Earned Badges") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(viewModel.badges) { badge in
                                    VStack {
                                        Image(systemName: badge.icon)
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                            .frame(width: 60, height: 60)
                                            .background(badge.color)
                                            .clipShape(Circle())
                                            .shadow(color: badge.color.opacity(0.5), radius: 5)
                                        
                                        Text(badge.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Recent Activity
                SectionContainer(title: "Recent Activity") {
                    ForEach(viewModel.recentActivities) { activity in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(activity.type.color)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(activity.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text(activity.timeAgo)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        
                        if activity.id != viewModel.recentActivities.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isEditing {
                        // Save changes
                        viewModel.saveProfile()
                        isEditing = false
                    } else {
                        isEditing = true
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                        .fontWeight(.medium)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $viewModel.profileImage)
        }
        .sheet(isPresented: $showSettingsSheet) {
            ProfileSettingsView()
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
}

struct RoundedShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                content
                    .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct InfoEditRow: View {
    let icon: String
    let title: String
    @Binding var value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.gray)
                .frame(width: 80, alignment: .leading)
            
            TextField(title, text: $value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}