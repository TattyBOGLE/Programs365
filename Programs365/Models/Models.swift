import Foundation

enum AgeGroup: String, CaseIterable, Identifiable {
    case u12 = "U12"
    case u14 = "U14"
    case u16 = "U16"
    case u18 = "U18"
    case u20 = "U20"
    case senior = "Senior"
    
    var id: String { self.rawValue }
    
    var allowedEvents: [TrackEvent] {
        switch self {
        case .u12:
            return [.sprints75m, .sprints150m, .middleDistance800m, .middleDistance1200m]
        case .u14:
            return [.sprints100m, .sprints200m, .sprints300m, .middleDistance800m, .middleDistance1500m, .hurdles75m, .longJump, .highJump]
        case .u16:
            return [.sprints100m, .sprints200m, .sprints300m, .middleDistance800m, .middleDistance1500m, .hurdles80m, .hurdles300m, .longJump, .tripleJump, .highJump, .poleVault]
        case .u18, .u20, .senior:
            return TrackEvent.allCases
        }
    }
}

enum TrackEvent: String, CaseIterable, Identifiable {
    // Sprints
    case sprints75m = "75m"
    case sprints100m = "100m"
    case sprints150m = "150m"
    case sprints200m = "200m"
    case sprints300m = "300m"
    case sprints400m = "400m"
    
    // Middle Distance
    case middleDistance800m = "800m"
    case middleDistance1200m = "1200m"
    case middleDistance1500m = "1500m"
    case middleDistance3000m = "3000m"
    
    // Hurdles
    case hurdles75m = "75m Hurdles"
    case hurdles80m = "80m Hurdles"
    case hurdles100m = "100m Hurdles"
    case hurdles110m = "110m Hurdles"
    case hurdles300m = "300m Hurdles"
    case hurdles400m = "400m Hurdles"
    
    // Jumps
    case longJump = "Long Jump"
    case tripleJump = "Triple Jump"
    case highJump = "High Jump"
    case poleVault = "Pole Vault"
    
    var id: String { self.rawValue }
    
    var category: String {
        switch self {
        case .sprints75m, .sprints100m, .sprints150m, .sprints200m, .sprints300m, .sprints400m:
            return "Sprints"
        case .middleDistance800m, .middleDistance1200m, .middleDistance1500m, .middleDistance3000m:
            return "Middle Distance"
        case .hurdles75m, .hurdles80m, .hurdles100m, .hurdles110m, .hurdles300m, .hurdles400m:
            return "Hurdles"
        case .longJump, .tripleJump, .highJump, .poleVault:
            return "Jumps"
        }
    }
}

enum TrainingTerm: String, CaseIterable, Identifiable {
    case shortTerm = "Short Term (8 weeks)"
    case mediumTerm = "Medium Term (16 weeks)"
    case longTerm = "Long Term (24 weeks)"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .shortTerm:
            return "Ideal for athletes preparing for a specific competition or peak performance window within 2 months. Perfect for targeting regional championships or specific meets."
        case .mediumTerm:
            return "Balanced program for athletes looking to peak during the main competition season. Suitable for national championships or series of important meets."
        case .longTerm:
            return "Comprehensive preparation for major championships or full season planning. Allows for proper periodization and multiple peak performances."
        }
    }
    
    var weeks: Int {
        switch self {
        case .shortTerm: return 8
        case .mediumTerm: return 16
        case .longTerm: return 24
        }
    }
}

enum TrainingPeriod: String, CaseIterable, Identifiable {
    case generalPreparation = "General Preparation"
    case specificPreparation = "Specific Preparation"
    case preCompetition = "Pre-Competition"
    case competition = "Competition"
    case transition = "Transition"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .generalPreparation:
            return "Focus on building general fitness, strength, and foundational skills"
        case .specificPreparation:
            return "Develop event-specific techniques and energy systems"
        case .preCompetition:
            return "Fine-tune competition skills and reduce training volume"
        case .competition:
            return "Peak performance phase with competition-specific preparation"
        case .transition:
            return "Active recovery and maintenance of basic fitness"
        }
    }
    
    func weeksForTerm(_ term: TrainingTerm) -> Int {
        switch (self, term) {
        case (.generalPreparation, .shortTerm): return 2
        case (.specificPreparation, .shortTerm): return 2
        case (.preCompetition, .shortTerm): return 2
        case (.competition, .shortTerm): return 1
        case (.transition, .shortTerm): return 1
            
        case (.generalPreparation, .mediumTerm): return 4
        case (.specificPreparation, .mediumTerm): return 4
        case (.preCompetition, .mediumTerm): return 4
        case (.competition, .mediumTerm): return 2
        case (.transition, .mediumTerm): return 2
            
        case (.generalPreparation, .longTerm): return 6
        case (.specificPreparation, .longTerm): return 6
        case (.preCompetition, .longTerm): return 6
        case (.competition, .longTerm): return 4
        case (.transition, .longTerm): return 2
        }
    }
}

struct Program: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let duration: Int // in weeks
    let currentWeek: Int?
    var isActive: Bool { currentWeek != nil }
}

struct Competition: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let location: String
    var isUpcoming: Bool {
        date > Date()
    }
}

struct Injury: Identifiable {
    let id = UUID()
    let type: String
    let date: Date
    let severity: Severity
    let status: Status
    let notes: String?
    
    enum Severity: String {
        case mild = "Mild"
        case moderate = "Moderate"
        case severe = "Severe"
    }
    
    enum Status: String {
        case active = "Active"
        case recovering = "Recovering"
        case resolved = "Resolved"
    }
}

struct UserStats {
    let workouts: Int
    let hours: Int
    let personalBests: Int
} 