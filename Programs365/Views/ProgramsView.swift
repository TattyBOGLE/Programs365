import SwiftUI

struct AgeGroupCard: View {
    let ageGroup: AgeGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(ageGroup.rawValue)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("\(ageGroup.allowedEvents.count) Available Events")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            HStack {
                Text("View Events")
                    .foregroundColor(.red)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
        }
        .frame(height: 160)
        .padding(20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct EventCard: View {
    let event: TrackEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.category)
                .font(.subheadline)
                .foregroundColor(.red)
            
            Text(event.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Text("Select Term")
                    .foregroundColor(.red)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
        }
        .frame(height: 160)
        .padding(20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct TermCard: View {
    let term: TrainingTerm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(term.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(term.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Spacer()
            
            HStack {
                Text("View Periods")
                    .foregroundColor(.red)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
        }
        .frame(height: 200)
        .padding(20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct PeriodCard: View {
    let period: TrainingPeriod
    let term: TrainingTerm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(period.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(period.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(period.weeksForTerm(term)) Weeks")
                .font(.headline)
                .foregroundColor(.red)
            
            Spacer()
            
            HStack {
                Text("View Weeks")
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
        }
        .frame(height: 200)
        .padding(20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.red.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct WeeksList: View {
    let period: TrainingPeriod
    let term: TrainingTerm
    let ageGroup: AgeGroup
    let event: TrackEvent
    @StateObject private var chatGPTService = ChatGPTService(apiKey: Config.API.chatGPTApiKey)
    @State private var selectedWeek: Int?
    @State private var programContent: AttributedString = AttributedString("")
    @State private var isLoading = false
    @State private var error: String?
    @State private var retryCount = 0
    @State private var isRetrying = false
    @State private var hasAttemptedReconnection = false
    @State private var showingSheet = false
    
    var totalWeeks: Int {
        period.weeksForTerm(term)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("\(event.rawValue) Program")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("\(ageGroup.rawValue) • \(term.rawValue) • \(period.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("\(totalWeeks) Weeks")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            .padding(.horizontal)
            
            // Weeks Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(1...totalWeeks, id: \.self) { week in
                    Button(action: {
                        selectedWeek = week
                        showingSheet = true
                        generateProgram(week: week)
                    }) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Week \(week)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack {
                                Text("View Program")
                                    .foregroundColor(.red)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(height: 160)
                        .padding(20)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(16)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingSheet) {
            NavigationView {
                ScrollView {
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.red)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 4)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                    
                                    // Progress bar
                                    Rectangle()
                                        .frame(width: min(CGFloat(chatGPTService.progress) * geometry.size.width, geometry.size.width), height: 4)
                                        .foregroundColor(.red)
                                    
                                    // Running man
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 30))
                                        .foregroundColor(.red)
                                        .offset(x: min(CGFloat(chatGPTService.progress) * (geometry.size.width - 30), geometry.size.width - 30), y: -20)
                                }
                            }
                            .frame(height: 40)
                            .padding(.horizontal, 40)
                            
                            // Percentage text
                            Text("\(Int(chatGPTService.progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if let error = error {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                if let week = selectedWeek {
                                    generateProgram(week: week)
                                }
                            }) {
                                Text("Try Again")
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    } else {
                        Text(programContent)
                            .padding()
                            .textSelection(.enabled)
                    }
                }
                .navigationTitle("Week \(selectedWeek ?? 1) Program")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingSheet = false
                        }
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    private func retryGeneration(week: Int) {
        isRetrying = true
        retryCount += 1
        hasAttemptedReconnection = false
        
        // Add a small delay before retrying to prevent rapid retries
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            generateProgram(week: week)
            isRetrying = false
        }
    }
    
    private func generateProgram(week: Int) {
        print("WeeksList: Starting program generation for week \(week)")
        isLoading = true
        error = nil
        
        Task {
            do {
                print("WeeksList: Preparing to generate workout plan...")
                // If we previously had a network error, wait a moment before trying again
                if hasAttemptedReconnection {
                    print("WeeksList: Had previous connection attempt, waiting 2 seconds...")
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                }
                
                let prompt = """
                Generate a training program for Week \(week) of \(totalWeeks):
                Age Group: \(ageGroup.rawValue)
                Event: \(event.rawValue)
                Term: \(term.rawValue)
                Period: \(period.rawValue)
                
                Follow this exact format with appropriate content for \(event.rawValue):
                
                1. WARM-UP (15-20 minutes)
                - Light Jogging:
                  * 400m at 60% effort
                - Dynamic Stretches:
                  * [3-4 specific stretches with sets/reps]
                - Event-Specific Drills:
                  * [3-4 drills with details]
                
                2. MAIN SESSION (45-60 minutes)
                Primary Exercises:
                - [Exercise name]:
                  * Sets: [number]
                  * Reps/Distance: [specify]
                  * Rest: [seconds]
                  * Intensity: [percentage]
                
                Technical Focus:
                - [2-3 specific technique points]
                
                3. COOL-DOWN (10-15 minutes)
                - Recovery Jog:
                  * [distance and intensity]
                - Static Stretches:
                  * [4-5 stretches with duration]
                
                4. RECOVERY GUIDELINES
                Nutrition:
                - [specific post-workout nutrition]
                - [hydration requirements]
                
                5. SAFETY NOTES
                - [age-appropriate guidelines]
                - [specific precautions]
                """
                
                print("WeeksList: Sending request to ChatGPT service...")
                let response = try await chatGPTService.generateWorkoutPlan(prompt: prompt)
                print("WeeksList: Received response from ChatGPT service")
                DispatchQueue.main.async {
                    print("WeeksList: Updating UI with response")
                    self.programContent = response
                    self.isLoading = false
                    self.retryCount = 0
                    self.hasAttemptedReconnection = false
                }
            } catch let error as ChatGPTError {
                print("WeeksList: ChatGPT Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    
                    if case .networkError(_) = error, !hasAttemptedReconnection {
                        print("WeeksList: Network error detected, will attempt reconnection")
                        hasAttemptedReconnection = true
                        // Try again after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            generateProgram(week: week)
                        }
                    }
                }
            } catch {
                print("WeeksList: Unexpected error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.error = "An unexpected error occurred: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

struct WeekIdentifier: Identifiable {
    let week: Int
    var id: Int { week }
}

struct ProgramsView: View {
    @State private var selectedAgeGroup: AgeGroup?
    @State private var selectedEvent: TrackEvent?
    @State private var selectedTerm: TrainingTerm?
    @State private var selectedPeriod: TrainingPeriod?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if selectedPeriod != nil && selectedTerm != nil && selectedEvent != nil && selectedAgeGroup != nil {
                    // Show weeks list in full width
                    WeeksList(
                        period: selectedPeriod!,
                        term: selectedTerm!,
                        ageGroup: selectedAgeGroup!,
                        event: selectedEvent!
                    )
                } else {
                    // Show grid for other views
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        if selectedAgeGroup == nil {
                            // Show age groups
                            ForEach(AgeGroup.allCases) { ageGroup in
                                Button(action: { selectedAgeGroup = ageGroup }) {
                                    AgeGroupCard(ageGroup: ageGroup)
                                }
                            }
                        } else if selectedEvent == nil {
                            // Show events for selected age group
                            ForEach(selectedAgeGroup!.allowedEvents) { event in
                                Button(action: { selectedEvent = event }) {
                                    EventCard(event: event)
                                }
                            }
                        } else if selectedTerm == nil {
                            // Show training terms
                            ForEach(TrainingTerm.allCases) { term in
                                Button(action: { selectedTerm = term }) {
                                    TermCard(term: term)
                                }
                            }
                        } else {
                            // Show training periods
                            ForEach(TrainingPeriod.allCases) { period in
                                Button(action: { 
                                    withAnimation {
                                        selectedPeriod = period
                                    }
                                }) {
                                    PeriodCard(period: period, term: selectedTerm!)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarItems(leading: backButton)
            .background(Color.black)
        }
    }
    
    private var navigationTitle: String {
        if let ageGroup = selectedAgeGroup {
            if let event = selectedEvent {
                if let term = selectedTerm {
                    if let period = selectedPeriod {
                        return "\(period.rawValue)"
                    }
                    return "\(term.rawValue)"
                }
                return event.rawValue
            }
            return "\(ageGroup.rawValue) Events"
        }
        return "Programs"
    }
    
    private var backButton: some View {
        Button(action: navigateBack) {
            Image(systemName: "chevron.left")
                .foregroundColor(.red)
        }
        .opacity(selectedAgeGroup == nil ? 0 : 1)
    }
    
    private func navigateBack() {
        withAnimation {
            if selectedPeriod != nil {
                selectedPeriod = nil
            } else if selectedTerm != nil {
                selectedTerm = nil
            } else if selectedEvent != nil {
                selectedEvent = nil
            } else if selectedAgeGroup != nil {
                selectedAgeGroup = nil
            }
        }
    }
}

#Preview {
    ProgramsView()
} 