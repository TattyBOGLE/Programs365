import Foundation

enum Config {
    // MARK: - API Configuration
    enum API {
        static var chatGPTApiKey: String {
            guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
                fatalError("""
                    OpenAI API Key not found!
                    Please set your API key in Xcode:
                    1. Edit Scheme > Run > Arguments > Environment Variables
                    2. Add OPENAI_API_KEY with your API key
                    Or set it in the environment before running the app
                    """)
            }
            return key
        }
        
        static let baseURL = "https://api.openai.com/v1/chat/completions"
        static let model = "gpt-3.5-turbo"
        static let organization = "" // Optional: Your OpenAI organization ID
    }
    
    // MARK: - App Settings
    static let maxRetries = 3
    static let retryDelay: UInt64 = 1_000_000_000 // 1 second in nanoseconds
    
    // MARK: - Network Settings
    static let timeoutInterval: TimeInterval = 30
    static let resourceTimeout: TimeInterval = 60
    
    // MARK: - Cache Settings
    static let maxCacheAge: TimeInterval = 3600 // 1 hour
    static let maxCacheSize = 50 // Maximum number of cached responses
    
    // MARK: - UI Settings
    static let defaultProgressUpdateInterval: TimeInterval = 0.1
    
    // MARK: - Training Program Settings
    static let supportedAgeGroups = ["U12", "U14", "U16", "U18", "U20", "Senior"]
    static let supportedEvents = [
        "Sprints",
        "Middle Distance",
        "Long Distance",
        "Hurdles",
        "Jumps",
        "Throws",
        "Cross Country",
        "Recovery"
    ]
    
    static let trainingPeriods = [
        "Short Term": 4,  // 4 weeks
        "Medium Term": 8,  // 8 weeks
        "Long Term": 12   // 12 weeks
    ]
} 