import SwiftUI
import WebKit

struct MoreViewNew: View {
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @State private var showingSavedPrograms = false
    @State private var showingInjuryAnalysis = false
    @State private var showingInjury = false
    @State private var showingProgress = false
    @State private var showingNutritionPlans = false
    @State private var showingAchievements = false
    @State private var showingTrainingHistory = false
    @State private var showingSettings = false
    @State private var showingHelpSupport = false
    @State private var showingPowerOf10 = false
    @State private var showingCoachesCorner = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Resources")) {
                    Button(action: { showingCoachesCorner = true }) {
                        Label("Coaches Corner", systemImage: "person.2.fill")
                    }
                    
                    NavigationLink(destination: InjuryView()) {
                        Label("Injury Prevention", systemImage: "bandage.fill")
                    }
                    
                    NavigationLink(destination: NutritionPlansView()) {
                        Label("Nutrition Guide", systemImage: "fork.knife")
                    }
                }
                
                Section(header: Text("Settings")) {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    NavigationLink(destination: ProfileSettingsView()) {
                        Label("Profile", systemImage: "person.fill")
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutAppView()) {
                        Label("About", systemImage: "info.circle.fill")
                    }
                    
                    NavigationLink(destination: ContactSupportView()) {
                        Label("Contact", systemImage: "envelope.fill")
                    }
                }
            }
            .navigationTitle("More")
            .sheet(isPresented: $showingCoachesCorner) {
                CoachesCornerView()
            }
        }
    }
}

struct AboutAppView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About Programs365")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Programs365 is a comprehensive training and competition management app designed for athletes and coaches. Our mission is to provide accessible, high-quality training programs and resources to help athletes reach their full potential.")
                    .font(.body)
                
                Text("Features")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(icon: "dumbbell.fill", text: "Customized Training Programs")
                    FeatureRow(icon: "trophy.fill", text: "Competition Management")
                    FeatureRow(icon: "figure.roll", text: "Para Athletics Support")
                    FeatureRow(icon: "person.2.fill", text: "Coaches Corner")
                    FeatureRow(icon: "bandage.fill", text: "Injury Prevention")
                }
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

struct ContactSupportView: View {
    @State private var email = ""
    @State private var message = ""
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Contact Information")) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                TextEditor(text: $message)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            Section {
                Button(action: sendMessage) {
                    HStack {
                        Spacer()
                        Text("Send Message")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Contact Support")
        .alert("Message Sent", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your message. We'll get back to you soon.")
        }
    }
    
    private func sendMessage() {
        // In a real app, this would send the message to your backend
        showingAlert = true
        email = ""
        message = ""
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 30)
            Text(text)
        }
    }
}

struct MoreOptionCardNew: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    MoreViewNew()
} 