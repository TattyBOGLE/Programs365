import SwiftUI
import UIKit

// MARK: - Views
struct AgeGroupCard: View {
    let ageGroup: AgeGroup
    let eventCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
            Text(ageGroup.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
            
                Text("\(eventCount) Available Events")
                .font(.subheadline)
                    .foregroundColor(.secondary)
            
            Spacer()
            
            HStack {
                Text("View Events")
                .font(.subheadline)
                        .fontWeight(.medium)
                .foregroundColor(.red)
            
                Image(systemName: "chevron.right")
                        .font(.caption)
                    .foregroundColor(.red)
            }
        }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected ? Color.red.opacity(0.1) : Color(UIColor.systemGray6))
        .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.red : Color.clear, lineWidth: 2)
            )
        }
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
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.red.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ProgramContentView: View {
    let content: AttributedString
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {  // Reduced spacing between sections
                ForEach(Array(content.characters.split(separator: "\n").enumerated()), id: \.0) { index, line in
                    let lineStr = String(line)
                    
                    // Break down the complex condition into simpler parts
                    let isMonday = lineStr.contains("MONDAY")
                    let isTuesday = lineStr.contains("TUESDAY")
                    let isWednesday = lineStr.contains("WEDNESDAY")
                    let isThursday = lineStr.contains("THURSDAY")
                    let isFriday = lineStr.contains("FRIDAY")
                    let isSaturday = lineStr.contains("SATURDAY")
                    let isSunday = lineStr.contains("SUNDAY")
                    let isDayHeader = isMonday || isTuesday || isWednesday || isThursday || isFriday || isSaturday || isSunday
                    
                    if isDayHeader {
                        // Day headers
                        Text(lineStr)
                                .font(.title2)
                                .fontWeight(.bold)
                    .foregroundColor(.red)
                            .padding(.top, 16)
                    } else if lineStr.hasPrefix("Focus:") {
                        // Focus subheading
                        Text(lineStr)
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 4)  // Reduced space after focus
                    } else if lineStr.hasSuffix("minutes):") || lineStr.hasSuffix("minutes)") {
                        // Section headers (Warm-Up, Technical Work, etc.)
                        Text(lineStr)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    } else {
                        // Regular content
                        Text(lineStr)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .textSelection(.enabled)
        }
    }
}

struct WeeksList: View {
    let period: String
    let term: String
    let ageGroup: String
    let event: String
    let chatGPTService: ChatGPTService
    @StateObject private var enhancedProgramService = EnhancedProgramService(chatGPTService: ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey))
    @ObservedObject private var programManager = SavedProgramManager.shared
    
    @State private var selectedWeek: Int?
    @State private var showingProgramSheet = false
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var generatedProgram: String = ""
    @State private var selectedEvent: TrackEvent?
    @State private var selectedAgeGroup: AgeGroup?
    @State private var selectedTerm: TrainingTerm?
    @State private var selectedPeriod: TrainingPeriod?
    @State private var selectedGender: Gender = .male
    @State private var showingSaveDialog = false
    @State private var programTitle = ""
    @State private var programNotes = ""
    @State private var showingSaveSuccess = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                ForEach(1...12, id: \.self) { week in
                    Button(action: {
                        selectedWeek = week
                        Task {
                            await generateProgram(for: week)
                        }
                    }) {
                        WeekCard(week: week)
                    }
                }
            }
            .padding()
            
            if isLoading {
                LoadingView()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showingProgramSheet) {
            if !generatedProgram.isEmpty {
                EnhancedProgramDisplayView(program: generatedProgram)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                programTitle = "\(event) Week \(selectedWeek ?? 0) Program"
                                showingSaveDialog = true
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showingSaveDialog) {
            SaveProgramView(
                programName: $programTitle,
                selectedCategory: .constant(SavedProgram.ProgramCategory(rawValue: event) ?? .custom),
                onSave: {
                    let savedProgram = SavedProgram(
                        name: programTitle,
                        description: "\(ageGroup) - \(term) - \(period) - Week \(selectedWeek ?? 0)",
                        category: SavedProgram.ProgramCategory(rawValue: event) ?? .custom,
                        weeks: [generatedProgram],
                        dateCreated: Date()
                    )
                    programManager.saveProgram(savedProgram)
                    showingSaveDialog = false
                    showingSaveSuccess = true
                    
                    // Dismiss success message after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingSaveSuccess = false
                    }
                }
            )
        }
        .overlay {
            if showingSaveSuccess {
                SaveSuccessView()
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut, value: showingSaveSuccess)
            }
        }
        .onAppear {
            // Initialize the selected values from the passed parameters
            selectedEvent = TrackEvent(rawValue: event)
            selectedAgeGroup = AgeGroup(rawValue: ageGroup)
            selectedTerm = TrainingTerm(rawValue: term)
            selectedPeriod = TrainingPeriod(rawValue: period)
        }
    }
    
    private func generateProgram(for week: Int) async {
        isLoading = true
        do {
            if let event = selectedEvent {
                // Use enhanced program generation
                let parameters = EnhancedProgramParameters(
                    ageGroup: selectedAgeGroup ?? .u16,
                    event: event,
                    term: .shortTerm,
                    period: selectedPeriod ?? .specific,
                    gender: selectedGender
                )
                let program = try await enhancedProgramService.generateProgram(
                    parameters: parameters,
                    week: week
                )
                await MainActor.run {
                    generatedProgram = program
                    isLoading = false
                    showingProgramSheet = true
                }
            } else {
                // Use existing program generation
                let eventStr = selectedEvent?.rawValue ?? "General"
                let ageGroupStr = selectedAgeGroup?.rawValue ?? "U16"
                let termStr = selectedTerm?.rawValue ?? "Short term"
                let periodStr = selectedPeriod?.rawValue ?? "General"
                
                let prompt = """
                Generate a detailed training program for:
                Event: \(eventStr)
                Age Group: \(ageGroupStr)
                Term: \(termStr)
                Period: \(periodStr)
                Week: \(week)
                
                Please provide a structured weekly program with:
                - Specific workouts for each day (use MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY as day headers)
                - Rest and recovery recommendations
                - Technical focus points
                - Key performance indicators
                
                Format each day's section with the day name in all caps as a header, followed by the workout details.
                """
                
                let response = try await chatGPTService.generateResponse(prompt: prompt)
                await MainActor.run {
                    generatedProgram = response
                    isLoading = false
                    showingProgramSheet = true
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
                showError = true
            }
        }
    }
}

struct WeekCard: View {
    let week: Int
    
    var body: some View {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Week \(week)")
                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack {
                                Text("View Program")
                    .foregroundColor(.blue)
                Spacer()
                                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                            }
                        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
                        .padding(20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct WeekIdentifier: Identifiable {
    let week: Int
    var id: Int { week }
}

struct ProgramsView: View {
    @StateObject private var chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
    @StateObject private var enhancedProgramService: EnhancedProgramService
    @StateObject private var programManager = SavedProgramManager.shared
    @State private var selectedAgeGroup: AgeGroup?
    @State private var selectedEvent: TrackEvent?
    @State private var selectedTerm: TrainingTerm?
    @State private var selectedPeriod: TrainingPeriod?
    @State private var selectedGender: Gender = .male
    @State private var generatedProgram: String?
    @State private var showingSaveDialog = false
    @State private var programTitle = ""
    @State private var selectedCategory: String?
    @State private var searchText = ""
    @State private var showingEventSelection = false
    @State private var showingTermSelection = false
    @State private var showingProgramSheet = false
    
    let initialCategory: String?
    
    init(initialCategory: String? = nil) {
        self.initialCategory = initialCategory
        let chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
        _enhancedProgramService = StateObject(wrappedValue: EnhancedProgramService(chatGPTService: chatGPTService))
    }
    
    var body: some View {
            NavigationView {
                ScrollView {
                VStack(spacing: 24) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Hero Section
                    heroSection
                    
                    // Quick Access Section
                    quickAccessSection
                    
                    // Age Groups Section
                    ageGroupsSection
                    
                    // Saved Programs Section
                    savedProgramsSection
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingEventSelection) {
                if let ageGroup = selectedAgeGroup {
                    EventsView(ageGroup: ageGroup, initialCategory: initialCategory)
                }
            }
            .sheet(isPresented: $showingTermSelection) {
                if let event = selectedEvent {
                    TermSelectionView(event: event, selectedTerm: $selectedTerm)
                }
            }
        }
    }
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(getHeroTitle())
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Customized programs for your athletic goals")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Access")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    QuickAccessCard(
                        title: "Track Events",
                        icon: "figure.run",
                        color: .red
                    ) {
                        // Navigate to track events
                    }
                    
                    QuickAccessCard(
                        title: "Field Events",
                        icon: "figure.disc.sports",
                        color: .blue
                    ) {
                        // Navigate to field events
                    }
                    
                    QuickAccessCard(
                        title: "Para Athletics",
                        icon: "figure.roll",
                        color: .green
                    ) {
                        // Navigate to para athletics
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var ageGroupsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Age Groups")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(AgeGroup.allCases, id: \.self) { ageGroup in
                            Button(action: {
                        selectedAgeGroup = ageGroup
                        showingEventSelection = true
                    }) {
                        AgeGroupCard(
                            ageGroup: ageGroup,
                            eventCount: getEventCount(for: ageGroup),
                            isSelected: selectedAgeGroup == ageGroup
                        ) {
                            selectedAgeGroup = ageGroup
                            showingEventSelection = true
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var savedProgramsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Saved Programs")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink(destination: SavedProgramsView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            if programManager.savedPrograms.isEmpty {
                emptyStateView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(programManager.savedPrograms.prefix(3)) { program in
                            SavedProgramPreviewCard(program: program)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No saved programs yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Start by creating a new training program")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
                    .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func getEventCount(for ageGroup: AgeGroup) -> Int {
        return ageGroup.allowedEvents.count
    }
    
    private func getHeroTitle() -> String {
        if let category = initialCategory {
            return category
        }
        return "Training Programs"
    }
}

// MARK: - Quick Access Card
struct QuickAccessCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(width: 100, height: 100)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
    }
}

// MARK: - Saved Program Preview Card
struct SavedProgramPreviewCard: View {
    let program: SavedProgram
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(program.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(program.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(program.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label(program.dateCreated.formatted(date: .abbreviated, time: .shortened),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(program.weeks.count) weeks",
                      systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct EventsView: View {
    let ageGroup: AgeGroup
    let initialCategory: String?
    @State private var selectedGender: Gender = .male
    @State private var selectedEvent: TrackEvent?
    @State private var showingTermSelection = false
    
    var filteredEvents: [TrackEvent] {
        let events = ageGroup.allowedEvents.filter { event in
            if selectedGender == .male {
                return !event.isFemaleOnly
            } else {
                return !event.isMaleOnly
            }
        }
        
        if let category = initialCategory {
            switch category {
            case "Track Events":
                return events.filter { ["Sprints", "Middle Distance", "Long Distance", "Hurdles", "Relays"].contains($0.category) }
            case "Field Events":
                return events.filter { ["Jumps", "Throws"].contains($0.category) }
            case "Para Athletics":
                return events.filter { $0.category == "Para" }
            default:
                return events
            }
        }
        return events
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Gender Selection
                Picker("Gender", selection: $selectedGender) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Events Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredEvents, id: \.self) { event in
                        Button(action: {
                            selectedEvent = event
                            showingTermSelection = true
                        }) {
                            TrackEventCard(event: event)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("\(ageGroup.rawValue) Events")
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingTermSelection) {
            if let event = selectedEvent {
                TermsView(event: event, ageGroup: ageGroup)
            }
        }
    }
}

struct TermsView: View {
    let event: TrackEvent
    let ageGroup: AgeGroup
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTerm: TrainingTerm?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("track")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event.rawValue)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Select your training term")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Terms Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(TrainingTerm.allCases, id: \.rawValue) { term in
                            Button(action: {
                                selectedTerm = term
                            }) {
                                TermCard(term: term)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarItems(leading: Button("Back") { dismiss() })
            .sheet(item: $selectedTerm) { term in
                NavigationView {
                    PeriodsView(event: event, ageGroup: ageGroup, term: term)
                }
            }
        }
    }
}

struct PeriodsView: View {
    let event: TrackEvent
    let ageGroup: AgeGroup
    let term: TrainingTerm
    @StateObject private var chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(TrainingPeriod.allCases, id: \.self) { period in
                    NavigationLink(destination: WeeksList(
                        period: period.rawValue,
                        term: term.rawValue,
                        ageGroup: ageGroup.rawValue,
                        event: event.rawValue,
                        chatGPTService: chatGPTService
                    )) {
                        PeriodCard(period: period, term: term)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("\(term.rawValue) Periods")
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct TrackEventCard: View {
    let event: TrackEvent
    
    private var categoryIcon: String {
        switch event.category {
        case "Field Events":
            return "sportscourt.fill"
        case "Sprints":
            return "figure.run"
        case "Middle Distance":
            return "figure.run.circle"
        case "Long Distance":
            return "figure.hiking"
        case "Hurdles":
            return "figure.step.training"
        case "Relays":
            return "person.3.fill"
        default:
            return "figure.run"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
                Text(event.category)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            Text(event.rawValue)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
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

struct EventSelectionView: View {
    let ageGroup: AgeGroup
    @Binding var selectedEvent: TrackEvent?
    let selectedGender: Gender
    @Environment(\.dismiss) private var dismiss
    
    private var filteredEvents: [TrackEvent] {
        ageGroup.allowedEvents.filter { event in
            if selectedGender == .male {
                return !event.isFemaleOnly
            } else {
                return !event.isMaleOnly
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Specialized training programs for para-athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Events Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredEvents, id: \.self) { event in
                            Button(action: {
                                selectedEvent = event
                                dismiss()
                            }) {
                                TrackEventCard(event: event)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct TermSelectionView: View {
    let event: TrackEvent
    @Binding var selectedTerm: TrainingTerm?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Select Training Term")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(TrainingTerm.allCases, id: \.self) { term in
                            Button(action: {
                                selectedTerm = term
                                dismiss()
                            }) {
                                TermCard(term: term)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct PeriodSelectionView: View {
    let event: TrackEvent
    let term: TrainingTerm
    @Binding var selectedPeriod: TrainingPeriod?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Specialized training programs for para-athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Periods Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(TrainingPeriod.allCases, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                                dismiss()
                            }) {
                                PeriodCard(period: period, term: term)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct ProgramSheetView: View {
    let ageGroup: AgeGroup
    let event: TrackEvent
    let term: TrainingTerm
    @State private var selectedPeriod: TrainingPeriod?
    @State private var selectedWeeks: [Int]?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Specialized training programs for para-athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Periods Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(TrainingPeriod.allCases, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                            }) {
                                PeriodCard(period: period, term: term)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(item: $selectedPeriod) { period in
                WeeksSelectionView(
                    ageGroup: ageGroup,
                    event: event,
                    term: term,
                    period: period,
                    selectedWeeks: $selectedWeeks
                )
            }
            .sheet(isPresented: Binding(
                get: { selectedWeeks != nil },
                set: { if !$0 { selectedWeeks = nil } }
            )) {
                if let weeks = selectedWeeks {
                    ProgramDetailView(
                        ageGroup: ageGroup,
                        event: event,
                        term: term,
                        period: selectedPeriod!,
                        weeks: weeks
                    )
                }
            }
        }
    }
}

struct SaveProgramView: View {
    @Binding var programName: String
    @Binding var selectedCategory: SavedProgram.ProgramCategory
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Program Details")) {
                    TextField("Program Name", text: $programName)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(SavedProgram.ProgramCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Save Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(programName.isEmpty)
                }
            }
        }
    }
}

struct LoadingView: View {
    @State private var progress: Double = 0
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Athlete Animation
            ZStack {
                // Track/Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 280, height: 8)
                
                // Animated Athlete
                HStack(spacing: 0) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 40))
                .foregroundColor(.red)
                        .offset(x: animationOffset)
                }
            }
            .frame(width: 280)
            
            // Progress Bar
            VStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red)
                        .frame(width: 280 * progress, height: 8)
                }
                .frame(width: 280)
                
                Text("Generating your program...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            // Start the animations
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                animationOffset = 240
            }
            
            withAnimation(Animation.easeInOut(duration: 2)) {
                progress = 1.0
            }
        }
    }
}

struct ParaAthletesView: View {
    let chatGPTService: ChatGPTService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAgeGroup: String?
    @State private var selectedEvent: TrackEvent?
    @State private var selectedClassification: String?
    @State private var selectedTerm: TrainingTerm?
    @State private var selectedPeriod: TrainingPeriod?
    @State private var selectedWeek: Int?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if selectedAgeGroup == nil {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Select Age Group")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Age Groups Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(["U18", "U20", "Senior"], id: \.self) { age in
                            Button(action: { selectedAgeGroup = age }) {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(age)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text(getAgeDescription(for: age))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                    
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
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .padding()
                } else if selectedEvent == nil {
                    // Events Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(getParaEvents(), id: \.self) { event in
                            Button(action: { selectedEvent = event }) {
                                ParaEventCard(event: event)
                            }
                        }
                    }
                    .padding()
                } else if selectedClassification == nil {
                    // Classifications Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(getClassifications(for: selectedEvent!), id: \.self) { classification in
                            Button(action: { selectedClassification = classification }) {
                                ParaClassificationCard(classification: classification)
                            }
                        }
                    }
                    .padding()
                } else if selectedTerm == nil {
                    // Terms Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(TrainingTerm.allCases) { term in
                            Button(action: { selectedTerm = term }) {
                                TermCard(term: term)
                            }
                        }
                    }
                    .padding()
                } else if selectedPeriod == nil {
                    // Periods Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(TrainingPeriod.allCases) { period in
                            Button(action: { selectedPeriod = period }) {
                                PeriodCard(period: period, term: selectedTerm!)
                            }
                        }
                    }
                    .padding()
                } else {
                    // Weeks List
                    WeeksList(
                        period: selectedPeriod!.rawValue,
                        term: selectedTerm!.rawValue,
                        ageGroup: selectedAgeGroup!,
                        event: selectedEvent!.rawValue,
                        chatGPTService: chatGPTService
                    )
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle(getNavigationTitle())
            .navigationBarItems(leading: Button(action: handleBack) {
            Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            })
        }
    }
    
    private func handleBack() {
        if selectedWeek != nil {
            selectedWeek = nil
        } else if selectedPeriod != nil {
                selectedPeriod = nil
            } else if selectedTerm != nil {
                selectedTerm = nil
            } else if selectedClassification != nil {
                selectedClassification = nil
            } else if selectedEvent != nil {
                selectedEvent = nil
            } else if selectedAgeGroup != nil {
                selectedAgeGroup = nil
        } else {
            dismiss()
        }
    }
    
    private func getNavigationTitle() -> String {
        if let period = selectedPeriod {
            return period.rawValue
        } else if let term = selectedTerm {
            return term.rawValue
        } else if let classification = selectedClassification {
            return "Class \(classification)"
        } else if let event = selectedEvent {
            return event.rawValue
        } else if let age = selectedAgeGroup {
            return "\(age) Events"
        }
        return "Para Athletics"
    }
    
    private func getAgeDescription(for age: String) -> String {
        switch age {
        case "U18":
            return "Athletes aged 16 or 17 on December 31 of the competition year"
        case "U20":
            return "Athletes aged 18 or 19 on December 31 of the competition year"
        case "Senior":
            return "Athletes aged 14+ for senior-level Para athletics events"
        default:
            return ""
        }
    }
    
    private func getParaEvents() -> [TrackEvent] {
        // Return relevant track events
        [.sprints100m, .sprints200m, .sprints400m, .middleDistance800m]
    }
    
    private func getClassifications(for event: TrackEvent) -> [String] {
        switch event {
        case .sprints100m, .sprints200m, .sprints400m:
            return ["T30", "T31", "T32", "T33", "T34", "T51", "T52", "T53", "T54", "T71", "T72", "T11", "T12", "T13", "T40"]
        case .middleDistance800m:
            return ["T53", "T54", "T11", "T12", "T13", "T40"]
        default:
            return []
        }
    }
}

struct ParaAgeGroupCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ParaEventCard: View {
    let event: TrackEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.rawValue)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(event.category)
                .font(.subheadline)
                .foregroundColor(.blue)
            
            Spacer()
            
            HStack {
                Text("Select Classification")
                    .foregroundColor(.blue)
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 160)
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ParaClassificationCard: View {
    let classification: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Class \(classification)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(getClassificationDescription(classification))
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Spacer()
            
            HStack {
                Text("Select Term")
                    .foregroundColor(.blue)
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 160)
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func getClassificationDescription(_ classification: String) -> String {
        switch classification {
        case "T11", "T12", "T13":
            return "Visual Impairment Classifications"
        case "T30", "T31", "T32", "T33", "T34":
            return "Coordination Impairment (Cerebral Palsy)"
        case "T51", "T52", "T53", "T54":
            return "Wheelchair Racing Classifications"
        case "T71", "T72":
            return "Short Stature Classifications"
        case "T40":
            return "Frame Running Classification"
        default:
            return "Paralympic Classification"
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search programs", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct WeeksSelectionView: View {
    let ageGroup: AgeGroup
    let event: TrackEvent
    let term: TrainingTerm
    let period: TrainingPeriod
    @Binding var selectedWeeks: [Int]?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Specialized training programs for para-athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Weeks Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(1...period.numberOfWeeks, id: \.self) { week in
                            Button(action: {
                                selectedWeeks = [week]
                                dismiss()
                            }) {
                                WeekCard(week: week)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// MARK: - Program Detail View
struct ProgramDetailView: View {
    let ageGroup: AgeGroup
    let event: TrackEvent
    let term: TrainingTerm
    let period: TrainingPeriod
    let weeks: [Int]
    @StateObject private var chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
    @State private var program: String?
    @State private var isLoading = true
    @State private var error: Error?
    @State private var showingSaveDialog = false
    @State private var showingSaveSuccess = false
    @State private var programName = ""
    @State private var selectedCategory: SavedProgram.ProgramCategory = .custom
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Specialized training programs for para-athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            
                            Text("Error generating program")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(error.localizedDescription)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Try Again") {
                                generateProgram()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if let program = program {
                        Text(program)
                            .font(.body)
                            .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        showingSaveDialog = true
                    }
                }
            }
            .sheet(isPresented: $showingSaveDialog) {
                SaveProgramView(
                    programName: $programName,
                    selectedCategory: $selectedCategory,
                    onSave: {
                        let savedProgram = SavedProgram(
                            name: programName,
                            description: "\(ageGroup.rawValue) \(event.rawValue) - \(term.rawValue) - \(period.rawValue) - Weeks \(weeks.map { String($0) }.joined(separator: ", "))",
                            category: selectedCategory,
                            weeks: [program ?? ""],
                            dateCreated: Date()
                        )
                        SavedProgramManager.shared.saveProgram(savedProgram)
                        showingSaveDialog = false
                        showingSaveSuccess = true
                    }
                )
            }
            .overlay {
                if showingSaveSuccess {
                    SaveSuccessView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showingSaveSuccess = false
                                dismiss()
                            }
                        }
                }
            }
            .onAppear {
                generateProgram()
            }
        }
    }
    
    private func generateProgram() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let prompt = """
                Generate a detailed training program for:
                Age Group: \(ageGroup.rawValue)
                Event: \(event.rawValue)
                Term: \(term.rawValue)
                Period: \(period.rawValue)
                Weeks: \(weeks.map { String($0) }.joined(separator: ", "))
                
                Please include:
                1. A weekly overview
                2. Daily training sessions with specific exercises, sets, reps, and rest periods
                3. Technical focus points
                4. Recovery and injury prevention guidelines
                """
                
                let response = try await chatGPTService.generateResponse(prompt: prompt)
                await MainActor.run {
                    program = response
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
}

struct SaveSuccessView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("Program Saved!")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(30)
        .background(Color.black.opacity(0.9))
        .cornerRadius(20)
    }
}

struct TrainingContextSelectionView: View {
    @StateObject private var chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
    @StateObject private var enhancedProgramService = EnhancedProgramService(chatGPTService: ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey))
    @State private var selectedAgeGroup: AgeGroup?
    @State private var selectedEvent: TrackEvent?
    @State private var selectedGender: Gender = .male
    @State private var selectedTermDuration: TermDuration?
    @State private var selectedTerm: TrainingTerm?
    @State private var selectedPeriod: TrainingPeriod?
    @State private var selectedWeek: Int?
    @State private var generatedProgram: String?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var showingProgramSheet = false
    
    enum TermDuration: String, CaseIterable {
        case short = "Short term"
        case medium = "Medium term"
        case long = "Long term"
        
        var description: String {
            switch self {
            case .short:
                return "4-6 weeks of focused training for immediate performance improvements"
            case .medium:
                return "8-12 weeks of progressive training to build strength and technique"
            case .long:
                return "16+ weeks of comprehensive training for major competitions"
            }
        }
        
        var term: TrainingTerm {
            switch self {
            case .short:
                return .shortTerm
            case .medium:
                return .mediumTerm
            case .long:
                return .longTerm
            }
        }
        
        var periods: [TrainingPeriod] {
            switch self {
            case .short:
                return [.specific, .competition]
            case .medium:
                return [.general, .specific, .competition]
            case .long:
                return TrainingPeriod.allCases
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("wheelchair")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Para Athletics")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Specialized training programs for para-athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Term Duration Selection
                    if selectedTermDuration == nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select Training Duration")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(TermDuration.allCases, id: \.self) { duration in
                                    Button(action: {
                                        withAnimation {
                                            selectedTermDuration = duration
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text(duration.rawValue)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            
                                            Text(duration.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(4)
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text("Select Periods")
                                                    .foregroundColor(.red)
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .frame(height: 200)
                                        .padding(20)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Period Selection
                    if let duration = selectedTermDuration, selectedPeriod == nil {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        selectedTermDuration = nil
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                }
                                
                                Text("Select Training Period")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(duration.periods, id: \.self) { period in
                                    Button(action: {
                                        withAnimation {
                                            selectedPeriod = period
                                        }
                                    }) {
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text(period.rawValue)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            
                                            Text(period.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(3)
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text("Select Weeks")
                                                    .foregroundColor(.red)
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .frame(height: 200)
                                        .padding(20)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Week Selection
                    if let period = selectedPeriod {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        selectedPeriod = nil
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                }
                                
                                Text("Select Week (\(period.rawValue))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(1...period.numberOfWeeks, id: \.self) { week in
                                    Button(action: {
                                        selectedWeek = week
                                        Task {
                                            await generateProgram(for: week)
                                        }
                                    }) {
                                        WeekCard(week: week)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    if isLoading {
                        LoadingView()
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? "An unknown error occurred")
            }
            .sheet(isPresented: $showingProgramSheet) {
                if let program = generatedProgram {
                    EnhancedProgramDisplayView(program: program)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Save") {
                                    // Save program logic here
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func generateProgram(for week: Int) async {
        isLoading = true
        do {
            if let event = selectedEvent {
                // Use enhanced program generation
                let parameters = EnhancedProgramParameters(
                    ageGroup: selectedAgeGroup ?? .u16,
                    event: event,
                    term: selectedTermDuration?.term ?? .shortTerm,
                    period: selectedPeriod ?? .specific,
                    gender: selectedGender
                )
                let program = try await enhancedProgramService.generateProgram(
                    parameters: parameters,
                    week: week
                )
                await MainActor.run {
                    generatedProgram = program
                    isLoading = false
                    showingProgramSheet = true
                }
            } else {
                // Use existing program generation
                let eventStr = selectedEvent?.rawValue ?? "General"
                let ageGroupStr = selectedAgeGroup?.rawValue ?? "U16"
                let termStr = selectedTermDuration?.rawValue ?? "Short term"
                let periodStr = selectedPeriod?.rawValue ?? "General"
                
                let prompt = """
                Generate a detailed training program for:
                Event: \(eventStr)
                Age Group: \(ageGroupStr)
                Term: \(termStr)
                Period: \(periodStr)
                Week: \(week)
                
                Please provide a structured weekly program with:
                - Specific workouts for each day (use MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY as day headers)
                - Rest and recovery recommendations
                - Technical focus points
                - Key performance indicators
                
                Format each day's section with the day name in all caps as a header, followed by the workout details.
                """
                
                let response = try await chatGPTService.generateResponse(prompt: prompt)
                await MainActor.run {
                    generatedProgram = response
                    isLoading = false
                    showingProgramSheet = true
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
                showError = true
            }
        }
    }
}

#Preview {
    ProgramsView()
} 