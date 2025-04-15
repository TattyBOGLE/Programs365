import Foundation
import SwiftUI

// MARK: - Age Groups
public enum AgeGroup: String, Codable, CaseIterable, Identifiable {
    case u12 = "U12"
    case u14 = "U14"
    case u16 = "U16"
    case u18 = "U18"
    case u20 = "U20"
    case senior = "SENIOR"
    
    public var id: String { rawValue }
    
    public var allowedEvents: [TrackEvent] {
        switch self {
        case .u12:
            return [
                .sprints75m, .sprints150m,
                .middleDistance800m,
                .longJump, .highJump,
                .shotPut
            ]
        case .u14:
            return [
                .sprints75m, .sprints150m, .sprints200m,
                .middleDistance800m, .middleDistance1500m,
                .hurdles100m,
                .relay4x100m,
                .longJump, .tripleJump, .highJump,
                .shotPut, .discus, .javelin
            ]
        case .u16:
            return [
                .sprints100m, .sprints200m, .sprints300m,
                .middleDistance800m, .middleDistance1500m,
                .longDistance3000m,
                .hurdles100m, .hurdles110m, .hurdles400m,
                .relay4x100m, .relay4x400m,
                .longJump, .tripleJump, .highJump, .poleVault,
                .shotPut, .discus, .javelin, .hammer
            ]
        case .u18:
            return [
                .sprints100m, .sprints200m, .sprints400m,
                .middleDistance800m, .middleDistance1500m,
                .longDistance3000m, .longDistance5000m,
                .hurdles100m, .hurdles110m, .hurdles400m,
                .relay4x100m, .relay4x400m,
                .longJump, .tripleJump, .highJump, .poleVault,
                .shotPut, .discus, .javelin, .hammer,
                .heptathlon
            ]
        case .u20, .senior:
            return TrackEvent.allCases
        }
    }
}

// MARK: - Track Events
public enum TrackEvent: String, Codable, CaseIterable, Identifiable {
    // Sprints
    case sprints75m = "75m"
    case sprints100m = "100m"
    case sprints150m = "150m"
    case sprints200m = "200m"
    case sprints300m = "300m"
    case sprints400m = "400m"
    
    // Middle Distance
    case middleDistance800m = "800m"
    case middleDistance1500m = "1500m"
    
    // Long Distance
    case longDistance3000m = "3000m"
    case longDistance5000m = "5000m"
    
    // Hurdles
    case hurdles100m = "100m Hurdles"
    case hurdles110m = "110m Hurdles"
    case hurdles400m = "400m Hurdles"
    
    // Relays
    case relay4x100m = "4x100m Relay"
    case relay4x400m = "4x400m Relay"
    
    // Jumps
    case longJump = "Long Jump"
    case tripleJump = "Triple Jump"
    case highJump = "High Jump"
    case poleVault = "Pole Vault"
    
    // Throws
    case shotPut = "Shot Put"
    case discus = "Discus"
    case javelin = "Javelin"
    case hammer = "Hammer"
    
    // Combined Events
    case decathlon = "Decathlon"
    case heptathlon = "Heptathlon"
    
    public var id: String { rawValue }
    
    public var category: String {
        switch self {
        case .sprints75m, .sprints100m, .sprints150m, .sprints200m, .sprints300m, .sprints400m:
            return "Sprints"
        case .middleDistance800m, .middleDistance1500m:
            return "Middle Distance"
        case .longDistance3000m, .longDistance5000m:
            return "Long Distance"
        case .hurdles100m, .hurdles110m, .hurdles400m:
            return "Hurdles"
        case .relay4x100m, .relay4x400m:
            return "Relays"
        case .longJump, .tripleJump, .highJump, .poleVault:
            return "Jumps"
        case .shotPut, .discus, .javelin, .hammer:
            return "Throws"
        case .decathlon, .heptathlon:
            return "Combined"
        }
    }
    
    public var isMaleOnly: Bool {
        switch self {
        case .hurdles110m, .decathlon:
            return true
        default:
            return false
        }
    }
    
    public var isFemaleOnly: Bool {
        switch self {
        case .hurdles100m, .heptathlon:
            return true
        default:
            return false
        }
    }
}

// MARK: - Training Periods
public enum TrainingPeriod: String, Codable, CaseIterable, Identifiable {
    case general = "General"
    case specific = "Specific"
    case preCompetition = "Pre-Competition"
    case competition = "Competition"
    case transition = "Transition"
    
    public var id: String { rawValue }
    
    var description: String {
        switch self {
        case .general:
            return "Building foundational fitness and strength"
        case .specific:
            return "Event-specific training and technique work"
        case .preCompetition:
            return "Fine-tuning and competition preparation"
        case .competition:
            return "Peak performance and competition focus"
        case .transition:
            return "Active recovery and maintenance"
        }
    }
    
    var numberOfWeeks: Int {
        switch self {
        case .general:
            return 12
        case .specific:
            return 8
        case .preCompetition:
            return 6
        case .competition:
            return 4
        case .transition:
            return 4
        }
    }
    
    func weeksForTerm(_ term: TrainingTerm) -> Int {
        switch (self, term) {
        case (.general, _):
            return 12
        case (.specific, _):
            return 8
        case (.preCompetition, _):
            return 6
        case (.competition, _):
            return 4
        case (.transition, _):
            return 4
        }
    }
}

// MARK: - Program Filter
public enum ProgramFilter: String, CaseIterable {
    case all = "All"
    case sprints = "Sprints"
    case middleDistance = "Middle Distance"
    case longDistance = "Long Distance"
    case hurdles = "Hurdles"
    case relays = "Relays"
    case jumps = "Jumps"
    case throwing = "Throws"
    case combined = "Combined"
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
    let eventCategory: String
    
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

// Shared enums and models
enum TimeFrame: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"
}

enum TrainingMetric: String, CaseIterable {
    case distance = "Distance"
    case time = "Time"
    case intensity = "Intensity"
    case volume = "Volume"
    case pace = "Pace"
    case elevation = "Elevation"
} 