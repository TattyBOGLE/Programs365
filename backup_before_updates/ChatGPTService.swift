import Foundation
import Network
import RegexBuilder
import SwiftUI

@_exported import struct Foundation.UUID
@_exported import struct Foundation.Date

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
    private var offlineProgramTemplates: [String: String] = [:]
    @Published private(set) var isOffline = false
    @Published private(set) var networkStatus: NWPath.Status = .requiresConnection
    @Published private(set) var hasWiFi = false
    @Published private(set) var hasCellular = false
    @Published var progress: Double = 0
    private var isMonitoring = false
    
    init(apiKey: String) {
        print("DEBUG: ChatGPTService initialized with API key length:", apiKey.count)
        self.apiKey = apiKey
        setupNetworkMonitoring()
        loadOfflineTemplates()
    }
    
    private func setupNetworkMonitoring() {
        guard !isMonitoring else { return }
        
        wifiMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                await self?.updateWiFiStatus(path.status == .satisfied)
                print("WiFi Status: \(path.status)")
            }
        }
        
        cellularMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                await self?.updateCellularStatus(path.status == .satisfied)
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
    private func updateWiFiStatus(_ isAvailable: Bool) async {
        self.hasWiFi = isAvailable
    }
    
    @MainActor
    private func updateCellularStatus(_ isAvailable: Bool) async {
        self.hasCellular = isAvailable
    }
    
    @MainActor
    private func updateNetworkStatus(_ path: NWPath) async {
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
        print("ChatGPTService: Starting to format response of length: \(response.count)")
        print("ChatGPTService: Raw response: \(response)")
        var result = AttributedString()
        
        let sections = response.components(separatedBy: "\n\n")
        print("ChatGPTService: Found \(sections.count) sections to format")
        
        for (index, section) in sections.enumerated() {
            print("ChatGPTService: Processing section \(index + 1): \(section)")
            
            // Check if section starts with any day of the week
            let daysOfWeek = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
            if daysOfWeek.contains(where: { section.hasPrefix($0) }) {
                print("ChatGPTService: Found day section")
                let lines = section.split(separator: "\n")
                guard !lines.isEmpty else { continue }
                
                // Day header
                var header = AttributedString(lines[0])
                header.foregroundColor = Color.red
                header.font = Font.system(.title, design: .default).weight(.bold)
                result += header + "\n\n"
                
                // Focus line
                if let focusLine = lines.first(where: { $0.hasPrefix("Focus:") }) {
                    print("ChatGPTService: Found Focus line: \(focusLine)")
                    var focus = AttributedString(focusLine)
                    focus.foregroundColor = Color.white
                    focus.font = Font.system(.headline, design: .default).weight(.medium)
                    result += focus + "\n" // Single newline for reduced spacing
                }
                
                // Main content
                let content = lines.dropFirst(2).joined(separator: "\n")
                print("ChatGPTService: Processing main content of length: \(content.count)")
                var contentStr = AttributedString("\n" + content + "\n")
                
                // Format section headers (Warm-Up, Aerobic/Extensive Work, etc.)
                if let regex = try? NSRegularExpression(pattern: "^\\s*[A-Za-z/ ]+ \\([0-9- ]+.*\\)$", options: [.anchorsMatchLines]) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    print("ChatGPTService: Found \(matches.count) section headers")
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            let attributedRange = lowerBound..<upperBound
                            contentStr[attributedRange].foregroundColor = .red
                            contentStr[attributedRange].font = .system(.headline, design: .default, weight: .bold)
                        }
                    }
                }
                
                // Format exercise names and options
                if let regex = try? NSRegularExpression(pattern: "^\\s*[A-Za-z ]+:.*$", options: [.anchorsMatchLines]) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    print("ChatGPTService: Found \(matches.count) exercise names")
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            let attributedRange = lowerBound..<upperBound
                            contentStr[attributedRange].foregroundColor = .white
                            contentStr[attributedRange].font = .system(.body, design: .default, weight: .medium)
                        }
                    }
                }
                
                // Format exercise details
                if let regex = try? NSRegularExpression(pattern: "^\\s*[•\\-\\*]\\s*.*$", options: [.anchorsMatchLines]) {
                    let nsRange = NSRange(content.startIndex..<content.endIndex, in: content)
                    let matches = regex.matches(in: content, options: [], range: nsRange)
                    print("ChatGPTService: Found \(matches.count) exercise details")
                    for match in matches {
                        if let range = Range(match.range, in: content),
                           let lowerBound = AttributedString.Index(range.lowerBound, within: contentStr),
                           let upperBound = AttributedString.Index(range.upperBound, within: contentStr) {
                            let attributedRange = lowerBound..<upperBound
                            contentStr[attributedRange].foregroundColor = .gray
                            contentStr[attributedRange].font = .system(.body, design: .default)
                        }
                    }
                }
                
                result += contentStr + "\n\n"
            } else {
                print("ChatGPTService: Section \(index + 1) does not start with a day of the week")
                // Add non-day content with default formatting
                var contentStr = AttributedString(section)
                contentStr.foregroundColor = .white
                result += contentStr + "\n\n"
            }
        }
        
        print("ChatGPTService: Finished formatting response")
        print("ChatGPTService: Final formatted content length: \(result.characters.count)")
        return result
    }
    
    private func updateProgress(_ value: Double) async {
        await MainActor.run {
            self.progress = min(max(value, 0), 1)
        }
    }
    
    func generateWorkoutPlan(prompt: String, retryCount: Int = 0) async throws -> AttributedString {
        print("DEBUG: Starting to generate workout plan")
        print("DEBUG: Network status - WiFi: \(hasWiFi), Cellular: \(hasCellular), Offline: \(isOffline)")
        print("ChatGPTService: Starting workout plan generation")
        print("ChatGPTService: Using API key of length: \(apiKey.count)")
        print("ChatGPTService: Prompt length: \(prompt.count)")
        
        // Check cache first
        let cacheKey = "\(prompt)"
        if let cachedResponse = cache[cacheKey] {
            print("ChatGPTService: Returning cached response")
            return formatResponse(cachedResponse)
        }
        
        // Reset progress
        await MainActor.run {
            self.progress = 0
        }
        print("ChatGPTService: Progress reset to 0")
        
        // Create a Task for progress updates
        let progressTask = Task { @MainActor in
            while !Task.isCancelled {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                if self.progress < 0.95 {
                    self.progress += 0.05
                }
            }
        }
        
        defer {
            progressTask.cancel()
            Task { @MainActor in
                self.progress = 1.0
            }
        }
        
        // Check network status
        if isOffline {
            print("ChatGPTService: Network appears to be offline")
            print("ChatGPTService: WiFi available: \(hasWiFi)")
            print("ChatGPTService: Cellular available: \(hasCellular)")
            
            if !checkNetworkConnection() {
                print("ChatGPTService: No network connection available, using offline template")
                let offlineResponse = generateOfflineResponse(prompt: prompt)
                return formatResponse(offlineResponse)
            }
        }
        
        print("ChatGPTService: Network is available, preparing API request")
        
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        print("ChatGPTService: Headers prepared with API key length: \(apiKey.count)")
        
        let event = extractEvent(from: prompt)
        let systemPrompt = getEventSpecificSystemPrompt(for: event)
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
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
            if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                print("ChatGPTService: Request body: \(bodyString)")
            }
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
                    
                    print("ChatGPTService: Response status code: \(httpResponse.statusCode)")
                    
                    // Print raw response data for debugging
                    if let rawResponse = String(data: data, encoding: .utf8) {
                        print("ChatGPTService: Raw API response: \(rawResponse)")
                    }
                    
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
                        do {
                            let chatGPTResponse = try decoder.decode(ChatGPTResponse.self, from: data)
                            guard let content = chatGPTResponse.choices.first?.message.content else {
                                print("ChatGPTService: No content in response choices")
                                throw ChatGPTError.invalidResponse
                            }
                            print("ChatGPTService: Successfully decoded response with content length: \(content.count)")
                            return content
                        } catch {
                            print("ChatGPTService: Failed to decode response: \(error)")
                            throw ChatGPTError.invalidResponse
                        }
                        
                    case 401:
                        print("ChatGPTService: Authentication error")
                        throw ChatGPTError.authenticationError("Invalid API key")
                    case 429:
                        print("ChatGPTService: Rate limit error")
                        if retryCount < 3 {
                            try await Task.sleep(nanoseconds: retryDelay)
                            return try await generateWorkoutPlan(prompt: prompt, retryCount: retryCount + 1).description
                        }
                        throw ChatGPTError.rateLimitError("Too many requests. Please wait a moment and try again.")
                    case 500...599:
                        print("ChatGPTService: Server error")
                        if retryCount < 3 {
                            try await Task.sleep(nanoseconds: retryDelay)
                            return try await generateWorkoutPlan(prompt: prompt, retryCount: retryCount + 1).description
                        }
                        throw ChatGPTError.serverError("Server error. Please try again in a few moments.")
                    default:
                        print("ChatGPTService: Unexpected status code: \(httpResponse.statusCode)")
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
        // Extract specific event from prompt
        let events = [
            // Sprints
            "75m", "100m", "150m", "200m", "300m", "400m",
            // Middle Distance
            "800m", "1200m", "1500m", "3000m",
            // Hurdles
            "75m Hurdles", "80m Hurdles", "100m Hurdles", "110m Hurdles", "300m Hurdles", "400m Hurdles",
            // Jumps
            "Long Jump", "Triple Jump", "High Jump", "Pole Vault",
            // Throws
            "Shot Put", "Discus", "Javelin", "Hammer"
        ]
        
        for event in events {
            if prompt.contains(event) {
                return event
            }
        }
        
        // Fallback to broader categories if specific event not found
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
    
    private func getEventSpecificSystemPrompt(for event: String) -> String {
        // Base prompt that applies to all events
        var prompt = """
        You are a professional track and field coach specializing in \(event) training.
        Format your response exactly as shown in the template.
        Use proper bullet points (•) and consistent indentation.
        Include specific numbers for all sets, reps, and intensities.
        Separate days with clear headers using an en dash (–).
        Keep workouts appropriate for the specified age group and event.
        """
        
        // Add event-specific instructions
        switch event {
        case "100m", "200m", "300m", "400m", "75m", "150m":
            prompt += """
            
            For \(event) specifically:
            - Focus on explosive starts and acceleration
            - Include sprint mechanics drills
            - Emphasize proper arm action and leg drive
            - Include block starts and reaction time drills
            - Add plyometric exercises for power development
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            - For \(event), emphasize \(event == "100m" ? "maximal velocity" : event == "200m" ? "curve running" : event == "400m" ? "lactate tolerance" : "acceleration")
            """
            
        case "800m", "1200m", "1500m", "3000m":
            prompt += """
            
            For \(event) specifically:
            - Focus on aerobic and anaerobic conditioning
            - Include pace judgment and race strategy
            - Emphasize proper running form at different speeds
            - Include interval training with appropriate work/rest ratios
            - Add strength endurance exercises
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            - For \(event), emphasize \(event == "800m" ? "lactate tolerance" : event == "1500m" ? "aerobic power" : "aerobic endurance")
            """
            
        case "75m Hurdles", "80m Hurdles", "100m Hurdles", "110m Hurdles", "300m Hurdles", "400m Hurdles":
            prompt += """
            
            For \(event) specifically:
            - Focus on hurdle technique and rhythm
            - Include lead leg and trail leg drills
            - Emphasize proper hurdle clearance
            - Include approach run practice
            - Add plyometric exercises for power development
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            - For \(event), emphasize \(event.contains("300m") || event.contains("400m") ? "endurance" : "speed")
            """
            
        case "Long Jump":
            prompt += """
            
            For Long Jump specifically:
            - Focus on approach run and takeoff technique
            - Include takeoff drills and exercises
            - Emphasize proper landing mechanics
            - Include approach run practice
            - Add plyometric exercises for power development
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            """
            
        case "Triple Jump":
            prompt += """
            
            For Triple Jump specifically:
            - Focus on the three phases: hop, step, and jump
            - Include phase-specific drills and exercises
            - Emphasize proper landing mechanics
            - Include approach run practice
            - Add plyometric exercises for power development
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            """
            
        case "High Jump":
            prompt += """
            
            For High Jump specifically:
            - Focus on approach run and takeoff technique
            - Include bar clearance drills
            - Emphasize proper landing mechanics
            - Include approach run practice
            - Add plyometric exercises for power development
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            """
            
        case "Pole Vault":
            prompt += """
            
            For Pole Vault specifically:
            - Focus on approach run and plant technique
            - Include pole carry and plant drills
            - Emphasize proper swing-up and bar clearance
            - Include approach run practice
            - Add upper body and core strength exercises
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            """
            
        case "Shot Put", "Discus", "Javelin", "Hammer":
            prompt += """
            
            For \(event) specifically:
            - Focus on throwing technique and mechanics
            - Include specific throwing drills
            - Emphasize proper release and follow-through
            - Include approach/glide/spin practice
            - Add strength exercises for throwing power
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            """
            
        default:
            prompt += """
            
            For \(event) training:
            - Focus on event-specific technique and conditioning
            - Include appropriate drills and exercises
            - Emphasize proper form and mechanics
            - Include strength and power development
            - Add event-specific conditioning
            - Include core stability work
            - Adapt training volume based on age group
            - Include injury prevention exercises
            - Focus on technical mastery
            """
        }
        
        return prompt
    }
    
    @MainActor
    func generateProgram(prompt: String) async throws -> String {
        // Check if we have a cached response
        let cacheKey = "\(prompt)"
        if let cachedResponse = cache[cacheKey] {
            print("ChatGPTService: Returning cached response for program generation")
            return cachedResponse
        }
        
        // Check if we're offline
        if isOffline || !checkNetworkConnection() {
            print("ChatGPTService: Device is offline, using offline template for program generation")
            return generateOfflineResponse(prompt: prompt)
        }
        
        guard let url = URL(string: baseURL) else {
            throw ChatGPTError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a professional athletics coach specializing in training program development."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw ChatGPTError.serializationError(error)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatGPTError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // Cache the response
                    cache[cacheKey] = content
                    return content
                }
                throw ChatGPTError.invalidResponse
            case 401:
                throw ChatGPTError.authenticationError("Invalid API key")
            case 429:
                throw ChatGPTError.rateLimitError("Rate limit exceeded")
            case 500...599:
                throw ChatGPTError.serverError("OpenAI server error")
            default:
                throw ChatGPTError.httpError(httpResponse.statusCode)
            }
        } catch let error as ChatGPTError {
            throw error
        } catch {
            // If there's a network error, try to use offline template
            print("ChatGPTService: Network error during program generation, using offline template")
            return generateOfflineResponse(prompt: prompt)
        }
    }
    
    func generateResponse(prompt: String) async throws -> String {
        // Check if we have a cached response
        if let cachedResponse = cache[prompt] {
            print("ChatGPTService: Returning cached response for prompt")
            return cachedResponse
        }
        
        // Check if we're offline
        if isOffline {
            print("ChatGPTService: Device is offline, using offline template")
            return generateOfflineResponse(prompt: prompt)
        }
        
        // Try to generate a response from the API
        do {
            let response = try await generateProgram(prompt: prompt)
            
            // Cache the response
            cache[prompt] = response
            print("ChatGPTService: Cached new response for prompt")
            
            return response
        } catch {
            print("ChatGPTService: API request failed, using offline template")
            return generateOfflineResponse(prompt: prompt)
        }
    }
    
    private func loadOfflineTemplates() {
        // Load predefined templates for offline use
        offlineProgramTemplates = [
            "sprints": """
            WEEKLY TRAINING PROGRAM FOR SPRINTS
            
            MONDAY
            Focus: Speed and Power Development
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            • Light jogging
            
            Sprint Drills (20 minutes)
            • High knees
            • A-skips
            • B-skips
            • Arm drive exercises
            
            Sprint Work (30 minutes)
            • 4 x 30m accelerations
            • 4 x 60m sprints at 80% effort
            • 3 x 100m sprints at 90% effort
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            TUESDAY
            Focus: Strength and Power
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Strength Training (45 minutes)
            • Squats: 4 sets x 6 reps
            • Deadlifts: 4 sets x 5 reps
            • Box jumps: 3 sets x 8 reps
            • Medicine ball throws: 3 sets x 10 reps
            
            Core Work (15 minutes)
            • Planks: 3 x 30 seconds
            • Russian twists: 3 x 20 reps
            • Leg raises: 3 x 15 reps
            
            Cool-Down (15 minutes)
            • Light stretching
            
            WEDNESDAY
            Focus: Recovery and Technique
            
            Warm-Up (15 minutes)
            • Light jogging
            • Dynamic stretching
            
            Technique Work (30 minutes)
            • Block starts: 6-8 reps
            • Acceleration drills
            • Form running
            
            Light Conditioning (20 minutes)
            • Circuit training with bodyweight exercises
            
            Cool-Down (15 minutes)
            • Light stretching
            
            THURSDAY
            Focus: Speed Endurance
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Speed Endurance (40 minutes)
            • 6 x 150m at 85% effort with 3-minute recovery
            • 4 x 200m at 80% effort with 4-minute recovery
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            FRIDAY
            Focus: Strength and Power
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Plyometric Training (30 minutes)
            • Box jumps: 4 sets x 8 reps
            • Depth jumps: 3 sets x 6 reps
            • Bounding: 3 sets x 20m
            
            Upper Body Strength (30 minutes)
            • Bench press: 4 sets x 6 reps
            • Pull-ups: 3 sets x max reps
            • Medicine ball throws: 3 sets x 10 reps
            
            Cool-Down (15 minutes)
            • Light stretching
            
            SATURDAY
            Focus: Competition Simulation
            
            Warm-Up (20 minutes)
            • Dynamic stretching
            • Mobility exercises
            • Sprint drills
            
            Competition Simulation (40 minutes)
            • 3 x 100m at race pace with full recovery
            • 2 x 200m at race pace with full recovery
            
            Cool-Down (20 minutes)
            • Light jogging
            • Static stretching
            
            SUNDAY
            Focus: Active Recovery
            
            Light Activity (30-45 minutes)
            • Swimming, cycling, or light jogging
            
            Mobility Work (20 minutes)
            • Foam rolling
            • Dynamic stretching
            
            Recovery Focus
            • Hydration
            • Proper nutrition
            • Adequate sleep
            """,
            
            "middleDistance": """
            WEEKLY TRAINING PROGRAM FOR MIDDLE DISTANCE
            
            MONDAY
            Focus: Speed and Anaerobic Capacity
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            • Light jogging
            
            Speed Work (30 minutes)
            • 6 x 200m at 85% effort with 2-minute recovery
            • 4 x 400m at 80% effort with 3-minute recovery
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            TUESDAY
            Focus: Strength and Power
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Strength Training (45 minutes)
            • Squats: 4 sets x 8 reps
            • Deadlifts: 4 sets x 6 reps
            • Lunges: 3 sets x 12 reps each leg
            • Calf raises: 3 sets x 15 reps
            
            Core Work (15 minutes)
            • Planks: 3 x 45 seconds
            • Russian twists: 3 x 20 reps
            • Leg raises: 3 x 15 reps
            
            Cool-Down (15 minutes)
            • Light stretching
            
            WEDNESDAY
            Focus: Aerobic Base
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Aerobic Run (45-60 minutes)
            • Steady-state running at 70-75% effort
            • Focus on maintaining consistent pace
            
            Cool-Down (15 minutes)
            • Light stretching
            
            THURSDAY
            Focus: Threshold Training
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Threshold Work (40 minutes)
            • 3 x 1000m at threshold pace with 3-minute recovery
            • 4 x 800m at threshold pace with 2-minute recovery
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            FRIDAY
            Focus: Recovery and Technique
            
            Warm-Up (15 minutes)
            • Light jogging
            • Dynamic stretching
            
            Technique Work (30 minutes)
            • Form running drills
            • Stride length exercises
            • Cadence work
            
            Light Conditioning (20 minutes)
            • Circuit training with bodyweight exercises
            
            Cool-Down (15 minutes)
            • Light stretching
            
            SATURDAY
            Focus: Race Simulation
            
            Warm-Up (20 minutes)
            • Dynamic stretching
            • Mobility exercises
            • Light jogging
            
            Race Simulation (40 minutes)
            • 2 x 800m at race pace with full recovery
            • 1 x 1200m at race pace with full recovery
            
            Cool-Down (20 minutes)
            • Light jogging
            • Static stretching
            
            SUNDAY
            Focus: Active Recovery
            
            Light Activity (30-45 minutes)
            • Swimming, cycling, or light jogging
            
            Mobility Work (20 minutes)
            • Foam rolling
            • Dynamic stretching
            
            Recovery Focus
            • Hydration
            • Proper nutrition
            • Adequate sleep
            """,
            
            "longDistance": """
            WEEKLY TRAINING PROGRAM FOR LONG DISTANCE
            
            MONDAY
            Focus: Aerobic Base
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            • Light jogging
            
            Aerobic Run (60-75 minutes)
            • Steady-state running at 70-75% effort
            • Focus on maintaining consistent pace
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            TUESDAY
            Focus: Speed and Anaerobic Capacity
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Speed Work (40 minutes)
            • 8 x 400m at 85% effort with 2-minute recovery
            • 4 x 800m at 80% effort with 3-minute recovery
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            WEDNESDAY
            Focus: Recovery and Technique
            
            Warm-Up (15 minutes)
            • Light jogging
            • Dynamic stretching
            
            Technique Work (30 minutes)
            • Form running drills
            • Stride length exercises
            • Cadence work
            
            Light Conditioning (20 minutes)
            • Circuit training with bodyweight exercises
            
            Cool-Down (15 minutes)
            • Light stretching
            
            THURSDAY
            Focus: Threshold Training
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Threshold Work (50 minutes)
            • 4 x 1200m at threshold pace with 3-minute recovery
            • 2 x 1600m at threshold pace with 4-minute recovery
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            FRIDAY
            Focus: Strength and Power
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Strength Training (45 minutes)
            • Squats: 4 sets x 10 reps
            • Deadlifts: 4 sets x 8 reps
            • Lunges: 3 sets x 12 reps each leg
            • Calf raises: 3 sets x 15 reps
            
            Core Work (15 minutes)
            • Planks: 3 x 60 seconds
            • Russian twists: 3 x 20 reps
            • Leg raises: 3 x 15 reps
            
            Cool-Down (15 minutes)
            • Light stretching
            
            SATURDAY
            Focus: Long Run
            
            Warm-Up (15 minutes)
            • Dynamic stretching
            • Mobility exercises
            
            Long Run (90-120 minutes)
            • Steady-state running at 65-70% effort
            • Focus on building endurance
            
            Cool-Down (15 minutes)
            • Light jogging
            • Static stretching
            
            SUNDAY
            Focus: Active Recovery
            
            Light Activity (30-45 minutes)
            • Swimming, cycling, or light jogging
            
            Mobility Work (20 minutes)
            • Foam rolling
            • Dynamic stretching
            
            Recovery Focus
            • Hydration
            • Proper nutrition
            • Adequate sleep
            """
        ]
    }
    
    private func generateOfflineResponse(prompt: String) -> String {
        // Extract key information from the prompt
        let event = extractEvent(from: prompt)
        let ageGroup = extractAge(from: prompt)
        let term = extractTerm(from: prompt)
        let period = extractPeriod(from: prompt)
        
        // Get the appropriate template based on the event
        var template = offlineProgramTemplates["sprints"] ?? ""
        
        if event.lowercased().contains("middle") || event.lowercased().contains("800") || event.lowercased().contains("1500") {
            template = offlineProgramTemplates["middleDistance"] ?? ""
        } else if event.lowercased().contains("long") || event.lowercased().contains("5000") || event.lowercased().contains("10000") {
            template = offlineProgramTemplates["longDistance"] ?? ""
        }
        
        // Customize the template based on age group, term, and period
        var customizedTemplate = template
        
        // Add age group specific modifications
        if ageGroup.contains("U12") || ageGroup.contains("U14") {
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "4 sets x 6 reps", with: "3 sets x 8 reps")
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "4 x 100m", with: "3 x 80m")
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "6 x 200m", with: "4 x 150m")
        }
        
        // Add term specific modifications
        if term.contains("Pre-Competition") {
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "70-75% effort", with: "75-80% effort")
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "80% effort", with: "85% effort")
        } else if term.contains("Competition") {
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "70-75% effort", with: "80-85% effort")
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "80% effort", with: "90% effort")
        }
        
        // Add period specific modifications
        if period.contains("General") {
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "4 x 100m", with: "3 x 80m")
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "6 x 200m", with: "4 x 150m")
        } else if period.contains("Specific") {
            customizedTemplate = customizedTemplate.replacingOccurrences(of: "70-75% effort", with: "75-80% effort")
        }
        
        // Add a note that this is an offline-generated program
        customizedTemplate = "OFFLINE GENERATED PROGRAM\n\n" + customizedTemplate
        
        // Cache the offline response
        cache[prompt] = customizedTemplate
        
        return customizedTemplate
    }
    
    deinit {
        wifiMonitor.cancel()
        cellularMonitor.cancel()
        anyMonitor.cancel()
        isMonitoring = false
    }
} 