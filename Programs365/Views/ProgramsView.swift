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
                        Task {
                            await generateProgram(week: week)
                        }
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
                            Text("Generating Program")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 8)
                                        .opacity(0.3)
                                        .foregroundColor(.gray)
                                        .cornerRadius(4)
                                    
                                    // Progress bar
                                    Rectangle()
                                        .frame(width: min(CGFloat(chatGPTService.progress) * geometry.size.width, geometry.size.width), height: 8)
                                        .foregroundColor(.red)
                                        .cornerRadius(4)
                                    
                                    // Triple Jump Animation
                                    HStack(spacing: 0) {
                                        // Phase 1: Hop
                                        Image(systemName: "figure.jumprope")
                                            .font(.system(size: 40))
                                            .foregroundColor(.red)
                                            .rotationEffect(.degrees(chatGPTService.progress < 0.33 ? 0 : -15))
                                            .offset(y: chatGPTService.progress < 0.33 ? -30 : 0)
                                            .opacity(chatGPTService.progress < 0.33 ? 1 : 0)
                                        
                                        // Phase 2: Step
                                        Image(systemName: "figure.step.training")
                                            .font(.system(size: 40))
                                            .foregroundColor(.red)
                                            .rotationEffect(.degrees(chatGPTService.progress >= 0.33 && chatGPTService.progress < 0.66 ? -15 : 0))
                                            .offset(y: chatGPTService.progress >= 0.33 && chatGPTService.progress < 0.66 ? -25 : 0)
                                            .opacity(chatGPTService.progress >= 0.33 && chatGPTService.progress < 0.66 ? 1 : 0)
                                        
                                        // Phase 3: Jump
                                        Image(systemName: "figure.gymnastics")
                                            .font(.system(size: 40))
                                            .foregroundColor(.red)
                                            .rotationEffect(.degrees(chatGPTService.progress >= 0.66 ? -30 : 0))
                                            .offset(y: chatGPTService.progress >= 0.66 ? -35 : 0)
                                            .opacity(chatGPTService.progress >= 0.66 ? 1 : 0)
                                    }
                                    .offset(x: min(CGFloat(chatGPTService.progress) * (geometry.size.width - 40), geometry.size.width - 40))
                                }
                            }
                            .frame(height: 100)
                            .padding(.horizontal, 40)
                            
                            // Progress text with phase indication
                            Text("\(Int(chatGPTService.progress * 100))% - \(getPhaseText(progress: chatGPTService.progress))")
                                .font(.headline)
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Color.black)
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
                                    Task {
                                        await generateProgram(week: week)
                                    }
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
            Task {
                await generateProgram(week: week)
            }
            isRetrying = false
        }
    }
    
    private func generateProgram(week: Int) async {
        print("WeeksList: Starting program generation for week \(week)")
        isLoading = true
        error = nil
        
        let prompt = """
        Generate a detailed training program for \(ageGroup) \(event) athletes for \(term) Term, \(period) Period, Week \(week).
        
        Format each day exactly as shown in this template:
        
        MONDAY
        Focus: Approach Run and Hop Phase Technique
        
        Warm-Up (15-20 minutes):
        • Easy jog: 800m
        • Dynamic stretches: 10 minutes
        • Mobility exercises: 5 minutes
        • Triple jump specific drills: 5 minutes
        
        Technical Work (30-40 minutes):
        • Approach run practice: 6-8 runs at 75% speed
        • Hop phase drills: 3 sets of 4 reps
        • Single leg bounds: 3 sets of 30m
        • Landing mechanics work: 4 sets of 6 reps
        
        Strength/Power Development (20-25 minutes):
        • Box jumps: 4 sets of 6 reps
        • Single leg press: 3 sets of 8 each leg
        • Core stability circuit: 3 rounds
        
        Cool-Down (10-15 minutes):
        • Light jog: 400m
        • Static stretches: 8-10 minutes
        • Recovery walk: 5 minutes
        
        TUESDAY
        Focus: Step Phase Development and Strength
        
        Warm-Up (15-20 minutes):
        • Easy jog: 800m
        • Dynamic stretches: 10 minutes
        • Coordination drills: 5 minutes
        • Step phase specific drills: 5 minutes
        
        Technical Work (30-40 minutes):
        • Step phase technique drills: 4 sets of 6 reps
        • Rhythm bounds: 4 sets of 30m
        • Connection drills (hop to step): 3 sets of 4 reps
        • Technical positioning work: 4 sets
        
        Strength/Power Development (20-25 minutes):
        • Split squats: 3 sets of 8 each leg
        • Plyometric lunges: 3 sets of 6 each leg
        • Medicine ball exercises: 3 sets of 8 reps
        
        Cool-Down (10-15 minutes):
        • Light jog: 400m
        • Static stretches: 8-10 minutes
        • Recovery walk: 5 minutes
        
        WEDNESDAY
        Focus: Jump Phase and Full Technique
        
        Warm-Up (15-20 minutes):
        • Easy jog: 800m
        • Dynamic stretches: 10 minutes
        • Jump-specific mobility: 5 minutes
        • Coordination drills: 5 minutes
        
        Technical Work (30-40 minutes):
        • Jump phase drills: 4 sets of 6 reps
        • Full approach runs: 4-6 runs at 80% speed
        • Full triple jump practice: 3-4 attempts
        • Landing pit work: 3 sets of 6 reps
        
        Strength/Power Development (20-25 minutes):
        • Depth jumps: 3 sets of 6 reps
        • Reactive strength exercises: 4 sets
        • Core and hip stability work: 3 rounds
        
        Cool-Down (10-15 minutes):
        • Light jog: 400m
        • Static stretches: 8-10 minutes
        • Recovery walk: 5 minutes
        
        THURSDAY
        Focus: Speed and Power Development
        
        Warm-Up (15-20 minutes):
        • Easy jog: 800m
        • Dynamic stretches: 10 minutes
        • Sprint drills: 5 minutes
        • Acceleration work: 5 minutes
        
        Technical Work (30-40 minutes):
        • Sprint technique: 6x30m at 90% speed
        • Horizontal bounds: 4 sets of 30m
        • Power skips: 3 sets of 30m
        • Speed bounds: 4 sets of 20m
        
        Strength/Power Development (20-25 minutes):
        • Power cleans: 4 sets of 4 reps
        • Jump squats: 3 sets of 6 reps
        • Explosive step-ups: 3 sets each leg
        
        Cool-Down (10-15 minutes):
        • Light jog: 400m
        • Static stretches: 8-10 minutes
        • Recovery walk: 5 minutes
        
        FRIDAY
        Focus: Technical Refinement and Light Power
        
        Warm-Up (15-20 minutes):
        • Easy jog: 800m
        • Dynamic stretches: 10 minutes
        • Technical drills: 5 minutes
        • Phase-specific mobility: 5 minutes
        
        Technical Work (30-40 minutes):
        • Short approach triple jumps: 6-8 attempts
        • Phase isolation work: 3 sets each phase
        • Technical corrections: 4-6 attempts
        • Run-through practice: 4 attempts
        
        Strength/Power Development (15-20 minutes):
        • Light plyometrics: 3 sets
        • Balance work: 3 sets each leg
        • Core stability: 2 rounds
        
        Cool-Down (10-15 minutes):
        • Light jog: 400m
        • Static stretches: 8-10 minutes
        • Recovery walk: 5 minutes
        
        SATURDAY
        Focus: Competition Practice or Light Technical Work
        
        Warm-Up (15-20 minutes):
        • Easy jog: 800m
        • Competition warm-up routine: 10 minutes
        • Light drills: 5 minutes
        • Mental preparation: 5 minutes
        
        Technical Work (20-30 minutes):
        • Competition run-through: 3-4 attempts
        • Light technical work: 2-3 sets
        • Approach run practice: 4-5 runs
        
        Cool-Down (10-15 minutes):
        • Light jog: 400m
        • Static stretches: 8-10 minutes
        • Recovery walk: 5 minutes
        
        SUNDAY
        Focus: Recovery and Active Rest
        
        Recovery Session (45-60 minutes):
        • Light walking or cycling: 20-30 minutes
        • Mobility work: 15-20 minutes
        • Stretching routine: 15-20 minutes
        • Light core work (optional): 10 minutes
        
        Guidelines:
        • Keep workouts appropriate for \(ageGroup) athletes
        • Include specific numbers for sets, reps, and intensities
        • Vary exercises throughout the week
        • Ensure proper progression and recovery
        • Include options for different fitness levels
        • Focus on \(event)-specific technique and conditioning
        • Adapt training volume based on age group
        • Include proper warm-up and cool-down protocols
        • Emphasize injury prevention exercises
        """
        
        print("WeeksList: Generated prompt with length: \(prompt.count)")
        print("WeeksList: Selected options - Age: \(ageGroup), Event: \(event), Term: \(term), Period: \(period)")
        
        do {
            print("WeeksList: Calling ChatGPT service")
            let response = try await chatGPTService.generateWorkoutPlan(prompt: prompt)
            print("WeeksList: Received response from ChatGPT service")
            
            await MainActor.run {
                print("WeeksList: Updating UI on main thread")
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
                        Task {
                            await generateProgram(week: week)
                        }
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
    
    private func getPhaseText(progress: Double) -> String {
        if progress < 0.33 {
            return "Hop Phase"
        } else if progress < 0.66 {
            return "Step Phase"
        } else {
            return "Jump Phase"
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