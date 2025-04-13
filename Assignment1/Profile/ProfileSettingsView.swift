import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var notifications = true
    @State private var locationSharing = true
    @State private var darkMode = false
    @State private var dataUsage: DataUsage = .highQuality
    @State private var selectedLanguage = "English"
    @State private var showDeleteConfirmation = false
    
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese"]
    
    enum DataUsage: String, CaseIterable, Identifiable {
        case lowData = "Low Data"
        case mediumQuality = "Medium Quality"
        case highQuality = "High Quality"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("App Preferences")) {
                    Toggle(isOn: $notifications) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    Toggle(isOn: $locationSharing) {
                        Label("Location Sharing", systemImage: "location.fill")
                    }
                    
                    Toggle(isOn: $darkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                
                Section(header: Text("Content")) {
                    Picker("Data Usage", selection: $dataUsage) {
                        ForEach(DataUsage.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Change Password")) {
                        Label("Change Password", systemImage: "lock.fill")
                    }
                    
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy Settings", systemImage: "hand.raised.fill")
                    }
                    
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Account", systemImage: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Help Center")) {
                        Label("Help Center", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: Text("Report a Problem")) {
                        Label("Report a Problem", systemImage: "exclamationmark.triangle.fill")
                    }
                    
                    NavigationLink(destination: Text("Terms of Service")) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                }
                
                Section {
                    Button {
                        // Log out action
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    ProfileSettingsView()
}