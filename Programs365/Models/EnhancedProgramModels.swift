import Foundation

// MARK: - Enhanced Program Models

// Periodization model for progressive overload
public enum PeriodizationModel: String, CaseIterable, Identifiable {
    case linear = "Linear"
    case undulating = "Undulating"
    case block = "Block"
    case wave = "Wave"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .linear:
            return "Gradual increase in intensity with consistent volume"
        case .undulating:
            return "Varied intensity and volume throughout the training cycle"
        case .block:
            return "Distinct blocks of training with specific focus areas"
        case .wave:
            return "Wave-like progression with micro-cycles of varying intensity"
        }
    }
}

// Training load management
public enum LoadManagementType: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case conservative = "Conservative"
    case aggressive = "Aggressive"
    case recovery = "Recovery"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .standard:
            return "Balanced progression with regular recovery"
        case .conservative:
            return "Cautious progression with frequent recovery"
        case .aggressive:
            return "Intensive progression with strategic recovery"
        case .recovery:
            return "Reduced volume with focus on recovery"
        }
    }
}

// Environmental context
public enum TrainingEnvironment: String, CaseIterable, Identifiable {
    case indoor = "Indoor"
    case outdoor = "Outdoor"
    case mixed = "Mixed"
    
    public var id: String { rawValue }
}

// Weather conditions
public enum WeatherCondition: String, CaseIterable, Identifiable {
    case ideal = "Ideal"
    case hot = "Hot"
    case cold = "Cold"
    case wet = "Wet"
    case windy = "Windy"
    
    public var id: String { rawValue }
}

// Facility limitations
public enum FacilityLimitation: String, CaseIterable, Identifiable {
    case none = "None"
    case limitedSpace = "Limited Space"
    case limitedEquipment = "Limited Equipment"
    case noTrack = "No Track"
    case noGym = "No Gym"
    
    public var id: String { rawValue }
}

// Female athlete considerations
public enum MenstrualPhase: String, CaseIterable, Identifiable {
    case follicular = "Follicular"
    case ovulatory = "Ovulatory"
    case luteal = "Luteal"
    case menstrual = "Menstrual"
    case unknown = "Unknown"
    
    public var id: String { rawValue }
}

// Enhanced program parameters
public struct EnhancedProgramParameters {
    var ageGroup: AgeGroup
    var event: TrackEvent
    var term: TrainingTerm
    var period: TrainingPeriod
    var gender: Gender
    var periodizationModel: PeriodizationModel
    var loadManagement: LoadManagementType
    var environment: TrainingEnvironment
    var weather: WeatherCondition
    var facilityLimitations: [FacilityLimitation]
    var menstrualPhase: MenstrualPhase?
    var previousInjuries: [String]
    var trainingHistory: Int // Years of training
    
    public init(
        ageGroup: AgeGroup,
        event: TrackEvent,
        term: TrainingTerm,
        period: TrainingPeriod,
        gender: Gender,
        periodizationModel: PeriodizationModel = .linear,
        loadManagement: LoadManagementType = .standard,
        environment: TrainingEnvironment = .outdoor,
        weather: WeatherCondition = .ideal,
        facilityLimitations: [FacilityLimitation] = [],
        menstrualPhase: MenstrualPhase? = nil,
        previousInjuries: [String] = [],
        trainingHistory: Int = 0
    ) {
        self.ageGroup = ageGroup
        self.event = event
        self.term = term
        self.period = period
        self.gender = gender
        self.periodizationModel = periodizationModel
        self.loadManagement = loadManagement
        self.environment = environment
        self.weather = weather
        self.facilityLimitations = facilityLimitations
        self.menstrualPhase = menstrualPhase
        self.previousInjuries = previousInjuries
        self.trainingHistory = trainingHistory
    }
}

// Event-specific warm-up protocols
public struct WarmUpProtocol {
    var event: TrackEvent
    var period: TrainingPeriod
    var components: [WarmUpComponent]
    
    public init(event: TrackEvent, period: TrainingPeriod, components: [WarmUpComponent]) {
        self.event = event
        self.period = period
        self.components = components
    }
}

// Warm-up components
public struct WarmUpComponent {
    var name: String
    var duration: Int // in minutes
    var exercises: [String]
    var focus: String
    
    public init(name: String, duration: Int, exercises: [String], focus: String) {
        self.name = name
        self.duration = duration
        self.exercises = exercises
        self.focus = focus
    }
}

// Event-specific injury prevention protocols
public struct InjuryPreventionProtocol {
    var event: TrackEvent
    var exercises: [InjuryPreventionExercise]
    
    public init(event: TrackEvent, exercises: [InjuryPreventionExercise]) {
        self.event = event
        self.exercises = exercises
    }
}

// Injury prevention exercises
public struct InjuryPreventionExercise {
    var name: String
    var sets: Int
    var reps: Int
    var focus: String
    var description: String
    
    public init(name: String, sets: Int, reps: Int, focus: String, description: String) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.focus = focus
        self.description = description
    }
}

// Session sequencing rules
public struct SessionSequencingRule {
    var event: TrackEvent
    var muscleGroups: [String]
    var recoveryTime: Int // in hours
    
    public init(event: TrackEvent, muscleGroups: [String], recoveryTime: Int) {
        self.event = event
        self.muscleGroups = muscleGroups
        self.recoveryTime = recoveryTime
    }
}

// Gender enum for consistency
public enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    
    public var id: String { rawValue }
} 