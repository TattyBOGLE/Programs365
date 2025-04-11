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
            ScrollView {
                VStack(spacing: 20) {
                    Text("More Options")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Text("Access additional features and settings")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Injury Analysis Section
                    NavigationLink(destination: InjuryAnalysisView()) {
                        MoreOptionCardNew(
                            title: "Injury Analysis".localized,
                            subtitle: "Analyze and track injuries".localized,
                            icon: "bandage.fill",
                            iconColor: .red
                        )
                    }
                    
                    // Injury Section
                    NavigationLink(destination: InjuryView()) {
                        MoreOptionCardNew(
                            title: "Injury".localized,
                            subtitle: "Manage and track injuries".localized,
                            icon: "cross.case.fill",
                            iconColor: .red
                        )
                    }
                    
                    // Progress Section
                    NavigationLink(destination: ProgressView()) {
                        MoreOptionCardNew(
                            title: "Progress".localized,
                            subtitle: "Track your progress".localized,
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: .green
                        )
                    }
                    
                    // Nutrition Plans Section
                    NavigationLink(destination: NutritionPlansView()) {
                        MoreOptionCardNew(
                            title: "Nutrition Plans".localized,
                            subtitle: "Manage nutrition plans".localized,
                            icon: "fork.knife",
                            iconColor: .orange
                        )
                    }
                    
                    // Achievements Section
                    NavigationLink(destination: AchievementsView()) {
                        MoreOptionCardNew(
                            title: "Achievements".localized,
                            subtitle: "View your achievements".localized,
                            icon: "trophy.fill",
                            iconColor: .yellow
                        )
                    }
                    
                    // Training History Section
                    NavigationLink(destination: TrainingHistoryView()) {
                        MoreOptionCardNew(
                            title: "Training History".localized,
                            subtitle: "View your training history".localized,
                            icon: "clock.fill",
                            iconColor: .blue
                        )
                    }
                    
                    // Settings Section
                    NavigationLink(destination: SettingsView()) {
                        MoreOptionCardNew(
                            title: "Settings".localized,
                            subtitle: "Configure app settings".localized,
                            icon: "gear",
                            iconColor: .gray
                        )
                    }
                    
                    // Help & Support Section
                    NavigationLink(destination: HelpSupportView()) {
                        MoreOptionCardNew(
                            title: "Help & Support".localized,
                            subtitle: "Get help and support".localized,
                            icon: "questionmark.circle.fill",
                            iconColor: .blue
                        )
                    }
                    
                    // Power of 10 Section
                    NavigationLink(destination: PowerOf10View()) {
                        MoreOptionCardNew(
                            title: "Power of 10".localized,
                            subtitle: "View Power of 10 rankings".localized,
                            icon: "list.number",
                            iconColor: .purple
                        )
                    }
                    
                    // Coaches Corner Section
                    NavigationLink(destination: CoachesCornerView()) {
                        MoreOptionCardNew(
                            title: "Coaches Corner".localized,
                            subtitle: "Access coaching resources".localized,
                            icon: "person.2.fill",
                            iconColor: .red
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
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