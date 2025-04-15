import SwiftUI
import PhotosUI

// UserSettings class to manage user data
class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: "userName") }
    }
    
    @Published var email: String {
        didSet { UserDefaults.standard.set(email, forKey: "userEmail") }
    }
    
    @Published var bio: String {
        didSet { UserDefaults.standard.set(bio, forKey: "userBio") }
    }
    
    @Published var notificationSettings: NotificationSettings {
        didSet { saveNotificationSettings() }
    }
    
    @Published var privacySettings: PrivacySettings {
        didSet { savePrivacySettings() }
    }
    
    struct NotificationSettings: Codable {
        var trainingReminders: Bool
        var competitionAlerts: Bool
        var achievementNotifications: Bool
        var injuryReminders: Bool
        var newsletterUpdates: Bool
    }
    
    struct PrivacySettings: Codable {
        var locationServices: Bool
        var activityTracking: Bool
        var dataSharing: Bool
        var analyticsCollection: Bool
    }
    
    private init() {
        self.name = UserDefaults.standard.string(forKey: "userName") ?? ""
        self.email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        self.bio = UserDefaults.standard.string(forKey: "userBio") ?? ""
        
        if let data = UserDefaults.standard.data(forKey: "notificationSettings"),
           let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            self.notificationSettings = settings
        } else {
            self.notificationSettings = NotificationSettings(
                trainingReminders: true,
                competitionAlerts: true,
                achievementNotifications: true,
                injuryReminders: true,
                newsletterUpdates: false
            )
        }
        
        if let data = UserDefaults.standard.data(forKey: "privacySettings"),
           let settings = try? JSONDecoder().decode(PrivacySettings.self, from: data) {
            self.privacySettings = settings
        } else {
            self.privacySettings = PrivacySettings(
                locationServices: true,
                activityTracking: true,
                dataSharing: false,
                analyticsCollection: true
            )
        }
    }
    
    private func saveNotificationSettings() {
        if let encoded = try? JSONEncoder().encode(notificationSettings) {
            UserDefaults.standard.set(encoded, forKey: "notificationSettings")
        }
    }
    
    private func savePrivacySettings() {
        if let encoded = try? JSONEncoder().encode(privacySettings) {
            UserDefaults.standard.set(encoded, forKey: "privacySettings")
        }
    }
}

// Settings View
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("measurementUnit") private var measurementUnit = "metric"
    @State private var showingProfileSettings = false
    @State private var showingNotificationSettings = false
    @State private var showingPrivacySettings = false
    @State private var showingTerms = false
    @State private var showingPrivacyPolicy = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    let languages = [
        ("en", "English"),
        ("es", "Español"),
        ("fr", "Français"),
        ("de", "Deutsch"),
        ("zh", "中文")
    ]
    
    let units = [
        ("metric", "Metric (km, kg)"),
        ("imperial", "Imperial (mi, lb)")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Account".localized)) {
                Button(action: { showingProfileSettings = true }) {
                    HStack {
                        Label("Profile Settings".localized, systemImage: "person.circle")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { showingNotificationSettings = true }) {
                    HStack {
                        Label("Notifications".localized, systemImage: "bell")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { showingPrivacySettings = true }) {
                    HStack {
                        Label("Privacy".localized, systemImage: "lock")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("App Settings".localized)) {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode".localized, systemImage: "moon")
                }
                
                Picker("Language".localized, selection: $localizationManager.currentLanguage) {
                    ForEach(languages, id: \.0) { code, name in
                        Text(name).tag(code)
                    }
                }
                
                Picker("Units".localized, selection: $measurementUnit) {
                    ForEach(units, id: \.0) { code, name in
                        Text(name).tag(code)
                    }
                }
            }
            
            Section(header: Text("About".localized)) {
                HStack {
                    Label("Version".localized, systemImage: "info.circle")
                    Spacer()
                    Text(Bundle.main.releaseVersionNumber ?? "1.0.0")
                        .foregroundColor(.gray)
                }
                
                Button(action: { showingTerms = true }) {
                    HStack {
                        Label("Terms of Service".localized, systemImage: "doc.text")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { showingPrivacyPolicy = true }) {
                    HStack {
                        Label("Privacy Policy".localized, systemImage: "hand.raised")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Settings".localized)
        .sheet(isPresented: $showingProfileSettings) {
            ProfileSettingsView()
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showingTerms) {
            TermsView()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

// Profile Settings View
struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userSettings = UserSettings.shared
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    @State private var showingSaveError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture".localized)) {
                    HStack {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .accessibilityLabel("Profile picture")
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .accessibilityLabel("Default profile picture")
                        }
                        
                        Button("Change Photo".localized) {
                            showingImagePicker = true
                        }
                        .accessibilityHint("Opens photo picker to select a new profile picture")
                    }
                }
                
                Section(header: Text("Personal Information".localized)) {
                    TextField("Name".localized, text: $userSettings.name)
                        .textContentType(.name)
                        .accessibilityLabel("Name field")
                    
                    TextField("Email".localized, text: $userSettings.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityLabel("Email field")
                    
                    TextEditor(text: $userSettings.bio)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if userSettings.bio.isEmpty {
                                    Text("Bio".localized)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 4)
                                }
                            },
                            alignment: .topLeading
                        )
                        .accessibilityLabel("Biography field")
                }
            }
            .navigationTitle("Profile Settings".localized)
            .navigationBarItems(
                leading: Button("Cancel".localized) { dismiss() },
                trailing: Button("Save".localized) { saveProfile() }
                    .disabled(!isValidEmail(userSettings.email))
            )
            .sheet(isPresented: $showingImagePicker) {
                SharedImagePicker(image: $profileImage, sourceType: .photoLibrary)
            }
            .alert("Error".localized, isPresented: $showingSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return email.isEmpty || emailPredicate.evaluate(with: email)
    }
    
    private func saveProfile() {
        guard isValidEmail(userSettings.email) else {
            errorMessage = "Please enter a valid email address".localized
            showingSaveError = true
            return
        }
        
        // Save profile image logic would go here
        dismiss()
    }
}

// Notification Settings View
struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userSettings = UserSettings.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Training".localized)) {
                    Toggle("Training Reminders".localized, isOn: $userSettings.notificationSettings.trainingReminders)
                        .accessibilityHint("Toggle training reminder notifications")
                    Toggle("Competition Alerts".localized, isOn: $userSettings.notificationSettings.competitionAlerts)
                        .accessibilityHint("Toggle competition alert notifications")
                    Toggle("Achievement Notifications".localized, isOn: $userSettings.notificationSettings.achievementNotifications)
                        .accessibilityHint("Toggle achievement notifications")
                }
                
                Section(header: Text("Health".localized)) {
                    Toggle("Injury Prevention Reminders".localized, isOn: $userSettings.notificationSettings.injuryReminders)
                        .accessibilityHint("Toggle injury prevention reminder notifications")
                }
                
                Section(header: Text("Updates".localized)) {
                    Toggle("Newsletter Updates".localized, isOn: $userSettings.notificationSettings.newsletterUpdates)
                        .accessibilityHint("Toggle newsletter update notifications")
                }
            }
            .navigationTitle("Notifications".localized)
            .navigationBarItems(trailing: Button("Done".localized) { dismiss() })
        }
    }
}

// Privacy Settings View
struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userSettings = UserSettings.shared
    @State private var showingDeleteConfirmation = false
    @State private var showingExportConfirmation = false
    @State private var showingExportSuccess = false
    @State private var showingExportError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Collection".localized)) {
                    Toggle("Location Services".localized, isOn: $userSettings.privacySettings.locationServices)
                        .accessibilityHint("Toggle location services for the app")
                    Toggle("Activity Tracking".localized, isOn: $userSettings.privacySettings.activityTracking)
                        .accessibilityHint("Toggle activity tracking features")
                    Toggle("Data Sharing".localized, isOn: $userSettings.privacySettings.dataSharing)
                        .accessibilityHint("Toggle data sharing with third parties")
                    Toggle("Analytics Collection".localized, isOn: $userSettings.privacySettings.analyticsCollection)
                        .accessibilityHint("Toggle analytics data collection")
                }
                
                Section(header: Text("Data Management".localized), footer: Text("Exporting data may take a few minutes.".localized)) {
                    Button("Export My Data".localized) {
                        showingExportConfirmation = true
                    }
                    .accessibilityHint("Export all your data in a downloadable format")
                    
                    Button("Delete My Account".localized) {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                    .accessibilityHint("Permanently delete your account and all associated data")
                }
            }
            .navigationTitle("Privacy".localized)
            .navigationBarItems(trailing: Button("Done".localized) { dismiss() })
            .alert("Delete Account".localized, isPresented: $showingDeleteConfirmation) {
                Button("Cancel".localized, role: .cancel) { }
                Button("Delete".localized, role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.".localized)
            }
            .alert("Export Data".localized, isPresented: $showingExportConfirmation) {
                Button("Cancel".localized, role: .cancel) { }
                Button("Export".localized) {
                    exportData()
                }
            } message: {
                Text("This will export all your personal data. The process may take a few minutes.".localized)
            }
            .alert("Export Successful".localized, isPresented: $showingExportSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your data has been exported successfully.".localized)
            }
            .alert("Export Failed".localized, isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
                Button("Try Again".localized) {
                    exportData()
                }
            } message: {
                Text("There was an error exporting your data. Please try again.".localized)
            }
        }
    }
    
    private func exportData() {
        // Simulated export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // For demo purposes, show success 90% of the time
            if Double.random(in: 0...1) < 0.9 {
                showingExportSuccess = true
            } else {
                showingExportError = true
            }
        }
    }
    
    private func deleteAccount() {
        // Account deletion logic would go here
        // For now, just dismiss the view
        dismiss()
    }
}

// Terms View
struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service".localized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Group {
                        termsSection(
                            title: "1. Acceptance of Terms".localized,
                            content: "By accessing and using Programs365, you accept and agree to be bound by the terms and provision of this agreement.".localized
                        )
                        
                        termsSection(
                            title: "2. Use License".localized,
                            content: "Permission is granted to temporarily download one copy of Programs365 for personal, non-commercial transitory viewing only.".localized
                        )
                        
                        termsSection(
                            title: "3. Disclaimer".localized,
                            content: "The materials on Programs365 are provided on an 'as is' basis.".localized
                        )
                        
                        termsSection(
                            title: "4. Limitations".localized,
                            content: "In no event shall Programs365 or its suppliers be liable for any damages arising out of the use or inability to use the materials on Programs365.".localized
                        )
                        
                        termsSection(
                            title: "5. Revisions".localized,
                            content: "The materials appearing on Programs365 could include technical, typographical, or photographic errors.".localized
                        )
                        
                        termsSection(
                            title: "6. Links".localized,
                            content: "Programs365 has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site.".localized
                        )
                        
                        termsSection(
                            title: "7. Modifications".localized,
                            content: "Programs365 may revise these terms of service for its website at any time without notice.".localized
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Terms of Service".localized)
            .navigationBarItems(trailing: Button("Done".localized) { dismiss() })
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
}

// Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy".localized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Group {
                        policySection(
                            title: "1. Information Collection".localized,
                            content: "We collect information that you provide directly to us, including when you create an account, make a purchase, or contact us for support.".localized
                        )
                        
                        policySection(
                            title: "2. Use of Information".localized,
                            content: "We use the information we collect to operate, maintain, and provide you with the features and functionality of Programs365.".localized
                        )
                        
                        policySection(
                            title: "3. Information Sharing".localized,
                            content: "We do not share your personal information with third parties except as described in this privacy policy.".localized
                        )
                        
                        policySection(
                            title: "4. Data Security".localized,
                            content: "We use reasonable measures to help protect information about you from loss, theft, misuse, unauthorized access, disclosure, alteration, and destruction.".localized
                        )
                        
                        policySection(
                            title: "5. Your Rights".localized,
                            content: "You have the right to access, update, or delete your information and to opt out of certain uses of your information.".localized
                        )
                        
                        policySection(
                            title: "6. Changes to Policy".localized,
                            content: "We may change this privacy policy from time to time. If we make changes, we will notify you by revising the date at the top of the policy.".localized
                        )
                        
                        policySection(
                            title: "7. Contact Us".localized,
                            content: "If you have any questions about this privacy policy or Programs365, please contact us.".localized
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy".localized)
            .navigationBarItems(trailing: Button("Done".localized) { dismiss() })
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.gray)
        }
    }
}

// Bundle Extension for Version Number
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

// Preview Provider
#Preview {
    NavigationView {
        SettingsView()
    }
} 