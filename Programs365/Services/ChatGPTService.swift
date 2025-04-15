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
public final class ChatGPTService: ObservableObject {
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
        isMonitoring = true
        
        wifiMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.hasWiFi = path.status == .satisfied
                self?.updateNetworkStatus()
            }
        }
        
        cellularMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.hasCellular = path.status == .satisfied
                self?.updateNetworkStatus()
            }
        }
        
        anyMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.networkStatus = path.status
                self?.updateNetworkStatus()
            }
        }
        
        wifiMonitor.start(queue: queue)
        cellularMonitor.start(queue: queue)
        anyMonitor.start(queue: queue)
    }
    
    @MainActor
    private func updateNetworkStatus() {
        isOffline = !hasWiFi && !hasCellular
    }
    
    private func loadOfflineTemplates() {
        // Load offline templates from a local file or bundle
        // This is a placeholder - implement actual template loading
        offlineProgramTemplates = [
            "general": "Offline training program template",
            "sprints": "Offline sprint training template",
            "jumps": "Offline jumps training template",
            "throws": "Offline throws training template"
        ]
    }
    
    private func generateOfflineResponse(prompt: String) -> String {
        // Generate a basic offline response based on the prompt
        let event = extractEvent(from: prompt)
        return offlineProgramTemplates[event.lowercased()] ?? offlineProgramTemplates["general"] ?? "Offline program template not available"
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
    
    func generateWorkoutPlan(prompt: String, retryCount: Int = 0) async throws -> AttributedString {
        // Check if API key is available
        guard !apiKey.isEmpty else {
            print("ERROR: No API key available")
            return formatResponse(generateOfflineResponse(prompt: prompt))
        }
        
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
                
                // Day header - Make it bold and red
                var header = AttributedString(lines[0])
                header.foregroundColor = .red
                header.font = .system(.title, design: .default).weight(.bold)
                result += header + "\n\n"
                
                // Focus line
                if let focusLine = lines.first(where: { $0.hasPrefix("Focus:") }) {
                    print("ChatGPTService: Found Focus line: \(focusLine)")
                    var focus = AttributedString(focusLine)
                    focus.foregroundColor = .white
                    focus.font = .system(.headline, design: .default).weight(.medium)
                    result += focus + "\n"
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
    
    private func extractEvent(from prompt: String) -> String {
        // Look for event in the prompt
        if prompt.contains("sprint") {
            return "sprints"
        } else if prompt.contains("middle") || prompt.contains("800") || prompt.contains("1500") {
            return "middleDistance"
        } else if prompt.contains("long") || prompt.contains("5000") || prompt.contains("10000") {
            return "longDistance"
        }
        return "general"
    }
    
    private func extractAge(from prompt: String) -> String {
        // Look for age group in the prompt
        if prompt.contains("U12") || prompt.contains("U13") || prompt.contains("U14") {
            return "U14"
        } else if prompt.contains("U15") || prompt.contains("U16") || prompt.contains("U17") {
            return "U17"
        } else if prompt.contains("U18") || prompt.contains("U19") || prompt.contains("U20") {
            return "U20"
        }
        return "senior"
    }
    
    private func extractTerm(from prompt: String) -> String {
        // Look for term in the prompt
        if prompt.contains("Pre-Competition") {
            return "Pre-Competition"
        } else if prompt.contains("Competition") {
            return "Competition"
        } else if prompt.contains("Off-Season") {
            return "Off-Season"
        }
        return "General"
    }
    
    private func extractPeriod(from prompt: String) -> String {
        // Look for period in the prompt
        if prompt.contains("General") {
            return "General"
        } else if prompt.contains("Specific") {
            return "Specific"
        } else if prompt.contains("Competition") {
            return "Competition"
        }
        return "General"
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
    
    deinit {
        wifiMonitor.cancel()
        cellularMonitor.cancel()
        anyMonitor.cancel()
        isMonitoring = false
    }
} 