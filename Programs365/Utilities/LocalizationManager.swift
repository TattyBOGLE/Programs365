import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            updateLanguage()
        }
    }
    
    private init() {
        // Get the saved language or use the device language
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            self.currentLanguage = savedLanguage
        } else {
            // Get the device language code
            let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = languageCode
        }
        
        updateLanguage()
    }
    
    func updateLanguage() {
        // Set the language for the app
        if let languageCode = LanguageCode(rawValue: currentLanguage) {
            UserDefaults.standard.set([languageCode.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            // Post notification to reload views
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    // Available languages
    let availableLanguages: [LanguageCode] = [
        .english,
        .spanish,
        .french,
        .german,
        .chinese
    ]
    
    // Language codes enum
    enum LanguageCode: String, CaseIterable, Identifiable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case chinese = "zh"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .chinese: return "中文"
            }
        }
    }
}

// Extension to get localized string
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
} 