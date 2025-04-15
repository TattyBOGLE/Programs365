import Foundation

enum AppConfig {
    enum API {
        // OpenAI API Key
        static let chatGPTApiKey = "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"
    }
    
    enum URLs {
        static let baseURL = "https://api.openai.com/v1"
        static let chatCompletionsEndpoint = "/chat/completions"
    }
    
    enum Cache {
        static let maxCacheAge: TimeInterval = 24 * 60 * 60 // 24 hours
        static let maxCacheSize = 100 // Maximum number of cached responses
    }
    
    enum Network {
        static let timeoutInterval: TimeInterval = 30
        static let retryAttempts = 3
        static let retryDelay: TimeInterval = 1.0
    }
    
    enum Models {
        static let defaultModel = "gpt-4-turbo-preview"
        static let fallbackModel = "gpt-3.5-turbo"
    }
} 