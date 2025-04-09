import Foundation

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