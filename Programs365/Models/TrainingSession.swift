import Foundation

struct TrainingSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var type: ActivityType
    var duration: TimeInterval
    var distance: Double? // in kilometers
    var pace: Double? // in minutes per kilometer
    var elevation: Double? // in meters
    var notes: String?
    var intensity: IntensityLevel
    
    enum ActivityType: String, Codable, CaseIterable {
        case running = "Running"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case strength = "Strength"
        case flexibility = "Flexibility"
        case recovery = "Recovery"
    }
    
    enum IntensityLevel: String, Codable, CaseIterable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
    }
    
    // Computed property for pace in minutes per kilometer
    var paceFormatted: String? {
        guard let pace = pace else { return nil }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Computed property for duration formatted as HH:MM:SS
    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Computed property for distance formatted with 1 decimal place
    var distanceFormatted: String? {
        guard let distance = distance else { return nil }
        return String(format: "%.1f km", distance)
    }
    
    // Computed property for elevation formatted with 0 decimal places
    var elevationFormatted: String? {
        guard let elevation = elevation else { return nil }
        return String(format: "%.0f m", elevation)
    }
} 