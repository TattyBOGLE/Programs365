import Foundation
import SwiftUI

// Achievement model
public struct Achievement: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let date: String
    public let icon: String
    public let description: String?
    public let category: String
    public let progress: Double
    
    public init(id: UUID = UUID(), title: String, date: String, icon: String, description: String?, category: String, progress: Double) {
        self.id = id
        self.title = title
        self.date = date
        self.icon = icon
        self.description = description
        self.category = category
        self.progress = progress
    }
}

// Coach model
public struct Coach: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let specialization: String
    public let bio: String
    public let imageName: String
    public let location: String
    
    public init(id: UUID = UUID(), name: String, specialization: String, bio: String, imageName: String, location: String) {
        self.id = id
        self.name = name
        self.specialization = specialization
        self.bio = bio
        self.imageName = imageName
        self.location = location
    }
}

extension Coach {
    public static let allCoaches: [Coach] = [
        // Sprints & Hurdles Coaches
        Coach(
            name: "Jonas Tawiah-Dodoo",
            specialization: "Elite Sprint & Jumps",
            bio: "Based at Loughborough, specializes in elite sprint and jumps coaching.",
            imageName: "coach_jonas",
            location: "Loughborough"
        ),
        Coach(
            name: "Richard Kilty",
            specialization: "Sprints (60m-200m)",
            bio: "Former European champion, now coaching sprints from 60m to 200m.",
            imageName: "coach_richard",
            location: "Teesside"
        ),
        Coach(
            name: "Linford Christie",
            specialization: "Sprints",
            bio: "Olympic 100m champion, now coaching the next generation of sprinters.",
            imageName: "coach_linford",
            location: "London"
        ),
        Coach(
            name: "Leon Baptiste",
            specialization: "Sprints",
            bio: "Former Commonwealth 200m champion, now coaching sprints at Loughborough.",
            imageName: "coach_leon",
            location: "Loughborough"
        ),
        
        // Jumps Coaches
        Coach(
            name: "Aston Moore",
            specialization: "Triple/Long Jump",
            bio: "Coached Phillips Idowu and Olivia Breen to Commonwealth gold. Based in Birmingham.",
            imageName: "coach_aston",
            location: "Birmingham"
        ),
        Coach(
            name: "John Shepherd",
            specialization: "Long Jump & Sprints",
            bio: "Specializes in long jump, sprints, and biomechanics. Based in London.",
            imageName: "coach_john_s",
            location: "London"
        ),
        Coach(
            name: "Keith Hunter",
            specialization: "Long/Triple Jump & Disability",
            bio: "Based in Manchester. Coached athlete to European gold and para-athlete to World bronze.",
            imageName: "coach_keith",
            location: "Manchester"
        ),
        Coach(
            name: "Shara Proctor",
            specialization: "Long Jump",
            bio: "Former GB long jumper, now coaching the next generation.",
            imageName: "coach_shara",
            location: "London"
        ),
        
        // Disability & Para Athletics Coaches
        Coach(
            name: "Verona Elder",
            specialization: "400m & Disability Athletics",
            bio: "Team manager for disability athletics in London.",
            imageName: "coach_verona",
            location: "London"
        ),
        Coach(
            name: "Ian Jones",
            specialization: "Disability Athletics",
            bio: "Former Paralympic sprinter, now coaching disability athletics in Manchester.",
            imageName: "coach_ian",
            location: "Manchester"
        ),
        Coach(
            name: "Jenni Banks",
            specialization: "Paralympic Wheelchair Athletics",
            bio: "UK-wide wheelchair athletics coach.",
            imageName: "coach_jenni",
            location: "UK-wide"
        ),
        Coach(
            name: "Vicky Tolfrey",
            specialization: "Disability & Parasport",
            bio: "Specialist in disability and parasport at Loughborough.",
            imageName: "coach_vicky",
            location: "Loughborough"
        ),
        Coach(
            name: "Paula Dunn",
            specialization: "Paralympic Head Coach",
            bio: "Head coach for British Athletics Paralympic team in Manchester.",
            imageName: "coach_paula",
            location: "Manchester"
        ),
        Coach(
            name: "Claire Buckle",
            specialization: "Para-Athletics",
            bio: "Para-athletics coach with Ability Consultancy in Lancashire.",
            imageName: "coach_claire",
            location: "Lancashire"
        ),
        Coach(
            name: "Graham Pilkington",
            specialization: "Lead Speed Coach",
            bio: "Coached para-athlete to Commonwealth bronze. Based in Liverpool.",
            imageName: "coach_graham",
            location: "Liverpool"
        ),
        
        // Middle Distance Coaches
        Coach(
            name: "Jenny Meadows",
            specialization: "400m/800m & Conditioning",
            bio: "Based in Wigan, specializing in 400m/800m and conditioning.",
            imageName: "coach_jenny",
            location: "Wigan"
        ),
        
        // Multi-Events Coaches
        Coach(
            name: "Julie Hollman Dodoo",
            specialization: "Multi-Events & Sprints",
            bio: "Olympian and multi-events coach based in London.",
            imageName: "coach_julie",
            location: "London"
        ),
        
        // Youth Development Coaches
        Coach(
            name: "Danny Sawyers",
            specialization: "Youth Development",
            bio: "Sprint coach with focus on youth development in Birmingham.",
            imageName: "coach_danny",
            location: "Birmingham"
        )
    ]
}

// Event model
public struct Event: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let date: Date
    public let location: String
    public let category: String
    public let level: String
    public let description: String
    public let status: String
    public let registrationDeadline: Date
    public let entryFee: String
    public let contact: String
}

// SavedProgram model
public struct SavedProgram: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let description: String
    public let category: ProgramCategory
    public let weeks: [String]
    public let dateCreated: Date
    
    public enum ProgramCategory: String, Codable, CaseIterable {
        case sprints = "Sprints"
        case middleDistance = "Middle Distance"
        case longDistance = "Long Distance"
        case hurdles = "Hurdles"
        case relays = "Relays"
        case jumps = "Jumps"
        case throwing = "Throws"
        case combined = "Combined"
        case custom = "Custom"
        case prevention = "Prevention"
        case rehabilitation = "Rehabilitation"
    }
    
    public init(id: UUID = UUID(), name: String, description: String, category: ProgramCategory, weeks: [String], dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.weeks = weeks
        self.dateCreated = dateCreated
    }
}

// SavedProgramManager
public class SavedProgramManager: ObservableObject {
    public static let shared = SavedProgramManager()
    @Published public var savedPrograms: [SavedProgram] = []
    private let savedProgramsKey = "savedPrograms"
    
    private init() {
        loadSavedPrograms()
    }
    
    private func loadSavedPrograms() {
        if let data = UserDefaults.standard.data(forKey: savedProgramsKey) {
            if let decoded = try? JSONDecoder().decode([SavedProgram].self, from: data) {
                savedPrograms = decoded.sorted(by: { $0.dateCreated > $1.dateCreated })
                return
            }
        }
        savedPrograms = []
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedPrograms) {
            UserDefaults.standard.set(encoded, forKey: savedProgramsKey)
        }
    }
    
    public func addProgram(_ program: SavedProgram) {
        savedPrograms.append(program)
        saveToDisk()
    }
    
    public func deleteProgram(_ program: SavedProgram) {
        savedPrograms.removeAll { $0.id == program.id }
        saveToDisk()
    }
    
    public func saveProgram(_ program: SavedProgram) {
        if let index = savedPrograms.firstIndex(where: { $0.id == program.id }) {
            savedPrograms[index] = program
        } else {
            addProgram(program)
        }
        saveToDisk()
    }
    
    public func getPrograms(ofCategory category: SavedProgram.ProgramCategory) -> [SavedProgram] {
        return savedPrograms.filter { $0.category == category }
    }
}

// ShareSheet
public struct ShareSheet: UIViewControllerRepresentable {
    public let activityItems: [Any]
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// EventCard
public struct EventCard: View {
    public let event: Event
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(event.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                
                Spacer()
                
                Text(event.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            
            // Title
            Text(event.title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            // Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.gray)
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text(event.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "trophy")
                        .foregroundColor(.gray)
                    Text(event.level)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// AchievementCard
public struct AchievementCard: View {
    public let achievement: Achievement
    
    public var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(achievement.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

// Training Term enum
public enum TrainingTerm: String, CaseIterable, Codable, Identifiable {
    case shortTerm = "Short Term"
    case mediumTerm = "Medium Term"
    case longTerm = "Long Term"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .shortTerm:
            return "4-6 weeks of focused training for immediate performance improvements"
        case .mediumTerm:
            return "8-12 weeks of progressive training to build strength and technique"
        case .longTerm:
            return "16+ weeks of comprehensive training for major competitions"
        }
    }
    
    public var duration: String {
        switch self {
        case .shortTerm:
            return "4-6 weeks"
        case .mediumTerm:
            return "8-12 weeks"
        case .longTerm:
            return "16+ weeks"
        }
    }
}

// TermCard
public struct TermCard: View {
    let term: TrainingTerm
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(term.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(term.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Text(term.duration)
                .font(.headline)
                .foregroundColor(.red)
            
            Spacer()
            
            HStack {
                Text("View Periods")
                    .foregroundColor(.red)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
        }
        .frame(height: 200)
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
} 