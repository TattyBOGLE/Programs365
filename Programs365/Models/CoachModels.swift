import Foundation

// MARK: - Coach Resource Model
public struct CoachResource: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let category: String
    public let url: URL
    public let dateAdded: Date
    
    public init(id: UUID = UUID(), title: String, description: String, category: String, url: URL, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.url = url
        self.dateAdded = dateAdded
    }
}

// MARK: - Video Model
public struct Video: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let url: URL
    public let duration: String
    public let dateAdded: Date
    
    public init(id: UUID = UUID(), title: String, description: String, url: URL, duration: String, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.duration = duration
        self.dateAdded = dateAdded
    }
}

// MARK: - Article Model
public struct Article: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let description: String
    public let content: String
    public let author: String
    public let dateAdded: Date
    
    public init(id: UUID = UUID(), title: String, description: String, content: String, author: String, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content
        self.author = author
        self.dateAdded = dateAdded
    }
}

// MARK: - Managers

public class CoachResourceManager: ObservableObject {
    public static let shared = CoachResourceManager()
    @Published public var resources: [CoachResource] = []
    
    private init() {
        // Load initial resources
        resources = [
            CoachResource(
                title: "Training Plans",
                description: "Comprehensive training plans for all events",
                category: "Training",
                url: URL(string: "https://example.com/training")!
            ),
            CoachResource(
                title: "Nutrition Guide",
                description: "Nutrition guidelines for athletes",
                category: "Nutrition",
                url: URL(string: "https://example.com/nutrition")!
            )
        ]
    }
}

public class VideoManager: ObservableObject {
    public static let shared = VideoManager()
    @Published public var videos: [Video] = []
    
    private init() {
        // Load initial videos
        videos = [
            Video(
                title: "Sprint Technique",
                description: "Learn proper sprinting technique",
                url: URL(string: "https://example.com/sprint")!,
                duration: "15:30"
            ),
            Video(
                title: "Jump Training",
                description: "Essential jump training exercises",
                url: URL(string: "https://example.com/jump")!,
                duration: "12:45"
            )
        ]
    }
}

public class ArticleManager: ObservableObject {
    public static let shared = ArticleManager()
    @Published public var articles: [Article] = []
    
    private init() {
        // Load initial articles
        articles = [
            Article(
                title: "Periodization in Training",
                description: "Understanding training periodization",
                content: "Periodization is a systematic approach to training...",
                author: "John Smith"
            ),
            Article(
                title: "Recovery Strategies",
                description: "Effective recovery techniques for athletes",
                content: "Proper recovery is essential for optimal performance...",
                author: "Jane Doe"
            )
        ]
    }
} 