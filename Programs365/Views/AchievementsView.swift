import SwiftUI
import UIKit

struct AchievementsView: View {
    @State private var achievements: [Achievement] = []
    @State private var selectedTimeFrame: TimeFrame = .allTime
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Frame Selector
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Medals Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Medals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        MedalCard(type: .gold, count: 5)
                        MedalCard(type: .silver, count: 8)
                        MedalCard(type: .bronze, count: 12)
                    }
                }
                .padding()
                
                // Personal Records Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Personal Records")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        RecordCard(event: "Triple Jump", record: "16.85m", date: "Mar 15, 2024")
                        RecordCard(event: "Long Jump", record: "8.20m", date: "Feb 28, 2024")
                        RecordCard(event: "100m", record: "10.5s", date: "Mar 10, 2024")
                        RecordCard(event: "200m", record: "21.2s", date: "Mar 5, 2024")
                    }
                }
                .padding()
                
                // Recent Achievements
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Achievements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            loadAchievements()
        }
    }
    
    private func loadAchievements() {
        // Sample data - replace with actual data loading
        achievements = [
            Achievement(title: "Triple Jump Master", description: "Completed 100 triple jump training sessions", date: Date(), type: .milestone),
            Achievement(title: "Gold Medal", description: "National Championships - Triple Jump", date: Date(), type: .competition),
            Achievement(title: "Personal Best", description: "New PB in Triple Jump: 16.85m", date: Date(), type: .record)
        ]
    }
}

// Supporting Views
struct MedalCard: View {
    let type: MedalType
    let count: Int
    
    var body: some View {
        VStack {
            Image(systemName: type.iconName)
                .font(.system(size: 40))
                .foregroundColor(type.color)
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(type.rawValue)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct RecordCard: View {
    let event: String
    let record: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event)
                .font(.headline)
                .foregroundColor(.white)
            Text(record)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.type.iconName)
                .font(.system(size: 30))
                .foregroundColor(achievement.type.color)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(achievement.formattedDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

// Models
enum MedalType: String {
    case gold = "Gold"
    case silver = "Silver"
    case bronze = "Bronze"
    
    var color: Color {
        switch self {
        case .gold: return .yellow
        case .silver: return .gray
        case .bronze: return .brown
        }
    }
    
    var iconName: String {
        "medal.fill"
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let type: AchievementType
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum AchievementType {
    case milestone
    case competition
    case record
    
    var iconName: String {
        switch self {
        case .milestone: return "star.fill"
        case .competition: return "trophy.fill"
        case .record: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: Color {
        switch self {
        case .milestone: return .yellow
        case .competition: return .red
        case .record: return .blue
        }
    }
}

#Preview {
    NavigationView {
        AchievementsView()
    }
} 