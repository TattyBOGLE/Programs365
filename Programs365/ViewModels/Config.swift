import Foundation

enum AppConfig {
    // MARK: - API Configuration
    enum API {
        static var chatGPTApiKey: String {
            // First try to get from environment (development)
            if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                print("DEBUG: Using API key from environment")
                return key
            }
            
            // Then try to get from local config file
            if let key = LocalConfig.apiKey {
                print("DEBUG: Using API key from local config")
                return key
            }
            
            // Fall back to hardcoded key (production)
            // IMPORTANT: This is a fallback and should be replaced with your actual key
            // before building for production
            let productionKey = "YOUR_OPENAI_API_KEY_HERE"
            
            // For security, only print the length of the key
            print("DEBUG: Using production API key with length:", productionKey.count)
            return productionKey
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
