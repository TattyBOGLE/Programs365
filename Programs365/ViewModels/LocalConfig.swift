import Foundation

/// This file is used to store local configuration values that should not be committed to Git.
/// Add this file to your .gitignore to keep your API keys private.
struct LocalConfig {
    private static let domain = "com.programs365"
    private static let apiKeyKey = "openai_api_key"
    
    /// Your OpenAI API key
    static var apiKey: String? {
        get {
            return UserDefaults.standard.string(forKey: apiKeyKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: apiKeyKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Set the API key
    static func setApiKey(_ key: String) {
        apiKey = key
        print("DEBUG: API key set with length: \(key.count)")
    }
    
    /// Clear the API key
    static func clearApiKey() {
        apiKey = nil
        UserDefaults.standard.synchronize()
    }
    
    /// Initialize with default API key if none exists
    static func initialize() {
        if apiKey == nil {
            // Set your API key here
            setApiKey("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")
        }
    }
} 