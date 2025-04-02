import Foundation
import Network
import RegexBuilder

@globalActor actor ChatGPTActor {
    static let shared = ChatGPTActor()
}

enum ChatGPTError: LocalizedError {
    case networkError(String)
    case invalidURL
    case invalidResponse
    case authenticationError(String)
    case rateLimitError(String)
    case serverError(String)
    case httpError(Int)
    case serializationError(Error)
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .rateLimitError(let message):
            return "Rate Limit Error: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .serializationError(let error):
            return "Serialization Error: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection available. Please check your connection and try again."
        }
    }
}

@MainActor
final class ChatGPTService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let wifiMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private let cellularMonitor = NWPathMonitor(requiredInterfaceType: .cellular)
    private let anyMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var cache: [String: String] = [:]
    @Published private(set) var isOffline = false
    @Published private(set) var networkStatus: NWPath.Status = .requiresConnection
    @Published private(set) var hasWiFi = false
    @Published private(set) var hasCellular = false
    @Published var progress: Double = 0
    private var isMonitoring = false
    
    init(apiKey: String) {
        self.apiKey = apiKey
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        guard !isMonitoring else { return }
        
        wifiMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.hasWiFi = path.status == .satisfied
                print("WiFi Status: \(path.status)")
            }
        }
        
        cellularMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.hasCellular = path.status == .satisfied
                print("Cellular Status: \(path.status)")
            }
        }
        
        anyMonitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            Task { @MainActor in
                await self.updateNetworkStatus(path)
            }
        }
        
        wifiMonitor.start(queue: queue)
        cellularMonitor.start(queue: queue)
        anyMonitor.start(queue: queue)
        isMonitoring = true
    }
    
    @MainActor
    private func updateNetworkStatus(_ path: NWPath) {
        self.networkStatus = path.status
        self.isOffline = path.status != .satisfied
        
        print("Overall Network Status: \(path.status)")
        print("Available Interfaces: WiFi=\(self.hasWiFi), Cellular=\(self.hasCellular)")
        
        if path.status == .satisfied {
            print("Network connection is available")
        } else {
            print("Network connection is lost - Status: \(path.status)")
        }
    }
    
    private func checkNetworkConnection() -> Bool {
        // First check if we have any network interface available
        if hasWiFi || hasCellular {
            return true
        }
        
        // If no interface is available, perform a connection test
        let semaphore = DispatchSemaphore(value: 0)
        var hasConnection = false
        
        // Try multiple endpoints in case one is down
        let endpoints = [
            "https://www.apple.com",
            "https://www.google.com",
            "https://api.openai.com"
        ]
        
        for endpoint in endpoints {
            guard let url = URL(string: endpoint) else { continue }
            
            let checkConnection = URLSession.shared.dataTask(with: url) { _, response, _ in
                if let httpResponse = response as? HTTPURLResponse {
                    hasConnection = (200...299).contains(httpResponse.statusCode)
                    if hasConnection {
                        semaphore.signal()
                    }
                }
            }
            
            checkConnection.resume()
            if semaphore.wait(timeout: .now() + 3) == .success {
                return true
            }
        }
        
        return false
    }
    
    private func formatResponse(_ response: String) -> AttributedString {
        var result = AttributedString()
        
        let sections = response.components(separatedBy: "\n\n")
        for section in sections {
            if section.hasPrefix("5.") { // Safety section
                // Create a warning box effect
                var warningBox = AttributedString("\n⚠️ SAFETY CONSIDERATIONS ⚠️\n")
                warningBox.foregroundColor = .red
                warningBox.font = .system(.title2, design: .default, weight: .bold)
                
                // Add a top border
                var topBorder = AttributedString("\n▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\n")
                topBorder.foregroundColor = .red
                
                result += topBorder + warningBox
                
                // Rest of the safety content with special formatting
                let content = section.split(separator: "\n").dropFirst().joined(separator: "\n")
                var contentStr = AttributedString("\n" + content + "\n")
                
                // Format subheadings in safety section
                if let regex = try? NSRegularExpression(pattern: "[A-Za-z -]+:", options: []) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            let attributedRange = lowerBound..<upperBound
                            contentStr[attributedRange].font = .system(.body, design: .default, weight: .bold)
                            contentStr[attributedRange].foregroundColor = .red
                        }
                    }
                }
                
                // Format bullet points with warning symbols
                if let regex = try? NSRegularExpression(pattern: "^[ ]*[•*-].*$", options: [.anchorsMatchLines]) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            var line = String(content[range])
                            let indent = line.prefix(while: { $0 == " " }).count
                            
                            // Replace bullet with warning symbol
                            if line.contains("*") {
                                line = line.replacingOccurrences(of: "*", with: "⚠️")
                            } else if line.contains("-") {
                                line = line.replacingOccurrences(of: "-", with: "⚠️")
                            } else if line.contains("•") {
                                line = line.replacingOccurrences(of: "•", with: "⚠️")
                            }
                            
                            // Ensure consistent indentation
                            let totalPadding = max(indent, 4) // Minimum 4 spaces of indentation
                            
                            let wrappedContent = line.replacingOccurrences(
                                of: "\n",
                                with: "\n" + String(repeating: " ", count: totalPadding)
                            )
                            let attributedRange = lowerBound..<upperBound
                            contentStr.replaceSubrange(attributedRange, with: AttributedString(wrappedContent))
                        }
                    }
                }
                
                result += contentStr
                
                // Add a bottom border
                var bottomBorder = AttributedString("\n▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁\n\n")
                bottomBorder.foregroundColor = .red
                result += bottomBorder
                
            } else if section.hasPrefix("1.") || section.hasPrefix("2.") || section.hasPrefix("3.") || 
                      section.hasPrefix("4.") {
                // Main section headers (red and bold)
                var header = AttributedString(section.split(separator: "\n")[0])
                header.foregroundColor = .red
                header.font = .system(.title2, design: .default, weight: .bold)
                result += header + "\n"
                
                // Rest of the section content
                let content = section.split(separator: "\n").dropFirst().joined(separator: "\n")
                var contentStr = AttributedString("\n" + content + "\n")
                
                // Format subheadings
                if let regex = try? NSRegularExpression(pattern: "[A-Za-z -]+:", options: []) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            let attributedRange = lowerBound..<upperBound
                            contentStr[attributedRange].font = .system(.body, design: .default, weight: .bold)
                        }
                    }
                }
                
                // Format bullet points and ensure alignment
                if let regex = try? NSRegularExpression(pattern: "^[ ]*[•*-].*$", options: [.anchorsMatchLines]) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            let line = String(content[range])
                            let indent = line.prefix(while: { $0 == " " }).count
                            
                            // Ensure consistent indentation
                            let totalPadding = max(indent, 4) // Minimum 4 spaces of indentation
                            
                            let wrappedContent = line.replacingOccurrences(
                                of: "\n",
                                with: "\n" + String(repeating: " ", count: totalPadding)
                            )
                            let attributedRange = lowerBound..<upperBound
                            contentStr.replaceSubrange(attributedRange, with: AttributedString(wrappedContent))
                        }
                    }
                }
                
                // Add extra spacing between sections
                result += contentStr + "\n\n"
                
                // Add horizontal line between sections
                var separator = AttributedString("\n―――――――――――――――――――――――――――\n\n")
                separator.foregroundColor = .gray
                result += separator
            }
        }
        
        return result
    }
    
    @MainActor
    private func updateProgress(_ value: Double) {
        self.progress = min(max(value, 0), 1)
    }
    
    func generateWorkoutPlan(prompt: String, retryCount: Int = 0) async throws -> AttributedString {
        print("ChatGPTService: Starting workout plan generation")
        
        // Check cache first
        let cacheKey = "\(prompt)"
        if let cachedResponse = cache[cacheKey] {
            print("ChatGPTService: Returning cached response")
            return formatResponse(cachedResponse)
        }
        
        // Reset progress
        updateProgress(0)
        print("ChatGPTService: Progress reset to 0")
        
        // Start progress updates
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if let progress = await self?.progress {
                    self?.updateProgress(progress + 0.05)
                }
            }
        }
        
        defer {
            progressTimer.invalidate()
            Task { @MainActor in
                updateProgress(1.0)
            }
        }
        
        // Check network status
        if isOffline {
            print("ChatGPTService: Network appears to be offline")
            print("ChatGPTService: WiFi available: \(hasWiFi)")
            print("ChatGPTService: Cellular available: \(hasCellular)")
            
            if !checkNetworkConnection() {
                print("ChatGPTService: No network connection available")
                throw ChatGPTError.noInternetConnection
            }
        }
        
        print("ChatGPTService: Network is available, preparing API request")
        
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        print("ChatGPTService: Headers prepared with API key length: \(apiKey.count)")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": """
                You are a professional track and field coach.
                Format your response exactly as shown in the template.
                Use proper bullet points (•) and consistent indentation.
                Include specific numbers for all sets, reps, and intensities.
                Separate days with clear headers using an en dash (–).
                Keep workouts appropriate for the specified age group and event.
                """],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000,
            "presence_penalty": 0.0,
            "frequency_penalty": 0.0
        ]
        
        print("ChatGPTService: Request body prepared with prompt length: \(prompt.count)")
        
        let response = try await performRequest(with: body, headers: headers, prompt: prompt, retryCount: retryCount)
        print("ChatGPTService: Response received, length: \(response.count)")
        cache[cacheKey] = response
        return formatResponse(response)
    }
    
    private func performRequest(with body: [String: Any], headers: [String: String], prompt: String, retryCount: Int) async throws -> String {
        guard let url = URL(string: baseURL) else {
            print("ChatGPTService: Invalid URL")
            throw ChatGPTError.invalidURL
        }
        
        print("ChatGPTService: Checking network connection")
        // Check network status before making request
        if !checkNetworkConnection() {
            print("ChatGPTService: No network connection available")
            throw ChatGPTError.noInternetConnection
        }
        
        print("ChatGPTService: Network connection confirmed")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = 30 // Increased timeout
        request.cachePolicy = .returnCacheDataElseLoad
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("ChatGPTService: Request body serialized successfully")
        } catch {
            print("ChatGPTService: Serialization error: \(error)")
            throw ChatGPTError.serializationError(error)
        }
        
        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30 // Increased timeout
            config.timeoutIntervalForResource = 60 // Increased resource timeout
            config.waitsForConnectivity = true
            config.allowsCellularAccess = true
            config.allowsExpensiveNetworkAccess = true
            config.allowsConstrainedNetworkAccess = true
            config.requestCachePolicy = .returnCacheDataElseLoad
            
            // Add retry logic for network errors
            var currentRetry = 0
            let maxRetries = 3
            let retryDelay: UInt64 = 1_000_000_000 // 1 second
            
            while currentRetry < maxRetries {
                do {
                    let session = URLSession(configuration: config)
                    let (data, response) = try await session.data(for: request)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw ChatGPTError.invalidResponse
                    }
                    
                    print("Response status code: \(httpResponse.statusCode)")
                    
                    switch httpResponse.statusCode {
                    case 200...299:
                        struct ChatGPTResponse: Codable {
                            let choices: [Choice]
                            struct Choice: Codable {
                                let message: Message
                                struct Message: Codable {
                                    let content: String
                                }
                            }
                        }
                        
                        let decoder = JSONDecoder()
                        let chatGPTResponse = try decoder.decode(ChatGPTResponse.self, from: data)
                        return chatGPTResponse.choices.first?.message.content ?? "No response generated"
                        
                    case 401:
                        throw ChatGPTError.authenticationError("Invalid API key")
                    case 429:
                        if retryCount < 3 {
                            try await Task.sleep(nanoseconds: retryDelay)
                            return try await generateWorkoutPlan(prompt: prompt, retryCount: retryCount + 1).description
                        }
                        throw ChatGPTError.rateLimitError("Too many requests. Please wait a moment and try again.")
                    case 500...599:
                        if retryCount < 3 {
                            try await Task.sleep(nanoseconds: retryDelay)
                            return try await generateWorkoutPlan(prompt: prompt, retryCount: retryCount + 1).description
                        }
                        throw ChatGPTError.serverError("Server error. Please try again in a few moments.")
                    default:
                        throw ChatGPTError.httpError(httpResponse.statusCode)
                    }
                } catch let error as ChatGPTError {
                    print("ChatGPT error: \(error.localizedDescription)")
                    throw error
                } catch {
                    print("Network error (attempt \(currentRetry + 1)/\(maxRetries)): \(error.localizedDescription)")
                    currentRetry += 1
                    
                    if currentRetry < maxRetries {
                        try await Task.sleep(nanoseconds: retryDelay)
                        continue
                    }
                    
                    if error.localizedDescription.contains("timed out") {
                        throw ChatGPTError.networkError("Request timed out. Please check your connection and try again.")
                    }
                    throw ChatGPTError.networkError("Connection error: \(error.localizedDescription)")
                }
            }
            
            throw ChatGPTError.networkError("Failed to connect after \(maxRetries) attempts")
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func extractAge(from prompt: String) -> String {
        // Simple extraction of age group from prompt
        if prompt.contains("U12") { return "U12" }
        if prompt.contains("U14") { return "U14" }
        if prompt.contains("U16") { return "U16" }
        if prompt.contains("U18") { return "U18" }
        if prompt.contains("U20") { return "U20" }
        return "Senior"
    }
    
    private func extractEvent(from prompt: String) -> String {
        // Simple extraction of event from prompt
        if prompt.contains("Sprints") { return "Sprints" }
        if prompt.contains("Middle Distance") { return "Middle Distance" }
        if prompt.contains("Long Distance") { return "Long Distance" }
        if prompt.contains("Hurdles") { return "Hurdles" }
        if prompt.contains("Jumps") { return "Jumps" }
        if prompt.contains("Throws") { return "Throws" }
        return "General Training"
    }
    
    private func extractWeek(from prompt: String) -> String {
        // Extract week number from prompt
        if let range = prompt.range(of: "Week \\d+", options: .regularExpression) {
            return String(prompt[range])
        }
        return "Week 1"
    }
    
    func getInjuryPrevention(for injury: Injury) async throws -> String {
        // Simulated response
        return """
        Prevention Tips for \(injury.type):
        
        1. Regular stretching routine
        2. Proper warm-up exercises
        3. Strengthening exercises
        4. Recovery protocols
        
        Consult with a healthcare professional for personalized advice.
        """
    }
    
    deinit {
        wifiMonitor.cancel()
        cellularMonitor.cancel()
        anyMonitor.cancel()
        isMonitoring = false
    }
} 