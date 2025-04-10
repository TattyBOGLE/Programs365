import SwiftUI
import Foundation
import UIKit

// MARK: - Views
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
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct EventCard: View {
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
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                
            Text(event.category)
                .font(.subheadline)
                .foregroundColor(.red)
            }
            
            Text(event.rawValue)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Text("Select Term")
                    .foregroundColor(.red)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
        }
        .frame(height: 180)
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
        .background(Color.gray.opacity(0.1))
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
    
    @State private var selectedWeek: Int?
    @State private var showingProgramSheet = false
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var generatedProgram: String = ""
    
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
            if let week = selectedWeek {
                ProgramSheetView(
                    ageGroup: AgeGroup(rawValue: ageGroup) ?? .senior,
                    event: TrackEvent(rawValue: event) ?? .sprints100m,
                    term: TrainingTerm(rawValue: term) ?? .preCompetition
                )
            }
        }
    }
    
    private func generateProgram(for week: Int) async {
        isLoading = true
        do {
            let prompt = """
                Generate a detailed \(event) training program for \(ageGroup) athletes.
                Term: \(term)
                Period: \(period)
                Week: \(week)
                
                Please provide a structured weekly program with:
                - Specific workouts for each day
                - Rest and recovery recommendations
                - Technical focus points
                - Key performance indicators
                """
            
            let response = try await chatGPTService.generateResponse(prompt: prompt)
            await MainActor.run {
                generatedProgram = response
                isLoading = false
                showingProgramSheet = true
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
                Text("Generate Program")
                    .foregroundColor(.blue)
                                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                            }
                        }
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
    @ObservedObject private var programManager = SavedProgramManager.shared
    @State private var selectedAgeGroup: AgeGroup?
    @State private var selectedEvent: TrackEvent?
    @State private var selectedTerm: TrainingTerm?
    @State private var selectedPeriod: TrainingPeriod?
    @State private var generatedProgram: String?
    @State private var programTitle: String = ""
    @State private var error: String?
    @State private var isLoading = false
    @State private var showingEventSelection = false
    @State private var showingTermSelection = false
    @State private var showingProgramSheet = false
    @State private var selectedGender: Gender = .male
    
    enum Gender: String, CaseIterable {
        case male = "Male"
        case female = "Female"
    }
    
    var filteredEvents: [TrackEvent] {
        guard let ageGroup = selectedAgeGroup else { return [] }
        
        let ageGroupEvents = ageGroup.allowedEvents
        
        return ageGroupEvents.filter { event in
            if selectedGender == .male {
                return !event.isFemaleOnly
            } else {
                return !event.isMaleOnly
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Offline indicator
                        if chatGPTService.isOffline {
                            HStack {
                                Image(systemName: "wifi.slash")
                                    .foregroundColor(.red)
                                Text("Offline Mode - Using Predefined Templates")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Hero Banner
                        ZStack(alignment: .bottomLeading) {
                            Image("England Athletics")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Training Programs".localized)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Customized programs for your athletic goals".localized)
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                        }
                        
                        // Gender Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Gender")
                                .font(.headline)
                                    .foregroundColor(.white)
                                .padding(.horizontal)
                                
                            HStack(spacing: 0) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                Button(action: {
                                        withAnimation {
                                            selectedGender = gender
                                        }
                                    }) {
                                        Text(gender.rawValue)
                                            .font(.headline)
                                            .foregroundColor(selectedGender == gender ? .white : .gray)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(selectedGender == gender ? Color.red : Color.gray.opacity(0.2))
                                    }
                                }
                            }
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 16)
                        
                        // Featured Categories Title
                        Text("Featured Categories")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Age Groups Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(AgeGroup.allCases) { ageGroup in
                            Button(action: {
                                    selectedAgeGroup = ageGroup
                            }) {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(ageGroup.rawValue)
                                            .font(.title)
                                            .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        
                                        Text("\(filteredEventsForAgeGroup(ageGroup).count) Available Events")
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
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Programs")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedAgeGroup) { ageGroup in
                EventSelectionView(ageGroup: ageGroup, selectedEvent: $selectedEvent, selectedGender: selectedGender)
            }
        }
    }
    
    private func filteredEventsForAgeGroup(_ ageGroup: AgeGroup) -> [TrackEvent] {
        let ageGroupEvents = ageGroup.allowedEvents
        
        return ageGroupEvents.filter { event in
            if selectedGender == .male {
                return !event.isFemaleOnly
            } else {
                return !event.isMaleOnly
            }
        }
    }
    
    private func saveProgram() {
        guard let ageGroup = selectedAgeGroup,
              let event = selectedEvent,
              let term = selectedTerm,
              let period = selectedPeriod,
              let programContent = generatedProgram else { return }
        
        let category = SavedProgram.ProgramCategory(rawValue: event.category) ?? .custom
        let savedProgram = SavedProgram(
            id: UUID(),
            name: programTitle.isEmpty ? "\(ageGroup.rawValue) \(event.rawValue) Program" : programTitle,
            description: "\(ageGroup.rawValue) \(event.rawValue) - \(term.rawValue) - \(period.rawValue)",
            category: category,
            weeks: [programContent],
            dateCreated: Date()
        )
        
        // Save the program
        SavedProgramManager.shared.saveProgram(savedProgram)
    }
    
    private func generateProgram() {
        isLoading = true
        error = nil
        generatedProgram = nil
        
        guard let ageGroup = selectedAgeGroup,
              let event = selectedEvent,
              let term = selectedTerm,
              let period = selectedPeriod else {
            error = "Please select all required options"
            isLoading = false
            return
        }
        
        Task {
            do {
        let prompt = """
                Generate a detailed training program for:
                Age Group: \(ageGroup.rawValue)
                Event: \(event.rawValue)
                Term: \(term.rawValue)
                Period: \(period.rawValue)
                
                Include:
                1. Weekly schedule
                2. Specific drills and exercises
                3. Intensity levels
                4. Recovery protocols
                5. Progressions
                """
                
                let response = try await chatGPTService.generateResponse(prompt: prompt)
                await MainActor.run {
                    generatedProgram = response
                    isLoading = false
                    showingProgramSheet = true
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct EventSelectionView: View {
    let ageGroup: AgeGroup
    @Binding var selectedEvent: TrackEvent?
    let selectedGender: ProgramsView.Gender
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
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(ageGroup.rawValue) Events")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Select your event for \(selectedGender.rawValue) athletes")
                                .font(.title3)
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
                                EventCard(event: event)
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
    @State private var selectedDuration: TermDuration?
    
    enum TermDuration: String, CaseIterable {
        case short = "Short Term"
        case medium = "Medium Term"
        case long = "Long Term"
        
        var description: String {
            switch self {
            case .short:
                return "4-6 weeks of focused training for immediate performance improvements or specific competitions"
            case .medium:
                return "8-12 weeks of progressive training to build strength and technique"
            case .long:
                return "16+ weeks of comprehensive training for major competitions or season preparation"
            }
        }
        
        var terms: [TrainingTerm] {
            switch self {
            case .short:
                return [.preCompetition, .competition]
            case .medium:
                return [.summer, .winter]
            case .long:
                return TrainingTerm.allCases
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.rawValue)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Select your training term duration")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    if let duration = selectedDuration {
                        // Show terms for selected duration
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(duration.terms, id: \.self) { term in
                                Button(action: {
                                    selectedTerm = term
                                    dismiss()
                                }) {
                                    TermCard(term: term)
                                }
                            }
                        }
                        .padding()
                    } else {
                        // Show duration options
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(TermDuration.allCases, id: \.self) { duration in
                                Button(action: {
                                    withAnimation {
                                        selectedDuration = duration
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
                                            Text("Select Terms")
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
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { 
                        if let _ = selectedDuration {
                            selectedDuration = nil
                        } else {
                            dismiss()
                        }
                    }) {
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
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.rawValue)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(term.rawValue) - Select your training period")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Periods Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(TrainingPeriod.allCases) { period in
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
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.rawValue)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(term.rawValue)
                                .font(.title3)
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
                        // Background Image
                        Image("wheelchair.hero")  // Using a wheelchair hero image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Title and Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Paralympic Athletes")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Elite training programs for para-athletes")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Age Groups Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                        ForEach(["U17", "U20", "Senior"], id: \.self) { age in
                            Button(action: { selectedAgeGroup = age }) {
                                ParaAgeGroupCard(title: age, description: getAgeDescription(age))
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
            .navigationBarItems(
                leading: selectedAgeGroup != nil ? backButton : nil,
                trailing: Button("Done") { dismiss() }
                    .foregroundColor(.white)
            )
        }
    }
    
    private var backButton: some View {
        Button(action: navigateBack) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
        }
    }
    
    private func navigateBack() {
        withAnimation {
            if selectedPeriod != nil {
                selectedPeriod = nil
            } else if selectedTerm != nil {
                selectedTerm = nil
            } else if selectedClassification != nil {
                selectedClassification = nil
            } else if selectedEvent != nil {
                selectedEvent = nil
            } else if selectedAgeGroup != nil {
                selectedAgeGroup = nil
            }
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
        return "Paralympic Athletes"
    }
    
    private func getAgeDescription(_ age: String) -> String {
        switch age {
        case "U17":
            return "Youth development programs for emerging para-athletes"
        case "U20":
            return "Advanced training for junior para-athletes"
        case "Senior":
            return "Elite programs for senior para-athletes"
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

struct SavedProgramsView: View {
    @ObservedObject private var savedProgramManager = SavedProgramManager.shared
    @State private var selectedFilter: ProgramFilter = .all
    @State private var showingFilterSheet = false
    @State private var searchText = ""
    @State private var selectedProgram: SavedProgram?
    @State private var showingDetail = false
    
    var filteredPrograms: [SavedProgram] {
        savedProgramManager.savedPrograms.filter { program in
            let matchesFilter = selectedFilter == .all || program.category.rawValue == selectedFilter.rawValue
            let matchesSearch = searchText.isEmpty || 
                program.name.localizedCaseInsensitiveContains(searchText) ||
                program.description.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Filter buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: selectedFilter == .all) {
                            selectedFilter = .all
                        }
                        
                        ForEach(ProgramFilter.allCases.filter { $0 != .all }, id: \.self) { filter in
                            FilterButton(title: filter.rawValue, isSelected: selectedFilter == filter) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                if filteredPrograms.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No saved programs found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredPrograms) { program in
                            SavedProgramRow(program: program)
                                .onTapGesture {
                                    selectedProgram = program
                                    showingDetail = true
                                }
                        }
                        .onDelete { indexSet in
                            let programsToDelete = indexSet.map { filteredPrograms[$0] }
                            for program in programsToDelete {
                                savedProgramManager.deleteProgram(program)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Saved Programs")
            .sheet(isPresented: $showingDetail) {
                if let program = selectedProgram {
                    SavedProgramDetailView(program: program)
                }
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
        }
    }
}

// MARK: - Saved Program Row
struct SavedProgramRow: View {
    let program: SavedProgram
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(program.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(program.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
            Text(program.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Label(program.dateCreated.formatted(date: .abbreviated, time: .shortened),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Label("\(program.weeks.count) weeks",
                      systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Saved Program Detail View
struct SavedProgramDetailView: View {
    let program: SavedProgram
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @ObservedObject private var savedProgramManager = SavedProgramManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Program header
                    programHeader
                    
                    // Program details
                    programDetails
                    
                    // Program content
                    programContent
                }
                .padding()
            }
            .navigationTitle("Program Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingShareSheet = true }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Delete Program", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    savedProgramManager.deleteProgram(program)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this program? This action cannot be undone.")
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [program.description])
            }
        }
    }
    
    private var programHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(program.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(program.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var programDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRow(title: "Category", value: program.category.rawValue)
            DetailRow(title: "Created", value: program.dateCreated.formatted())
            DetailRow(title: "Duration", value: "\(program.weeks.count) weeks")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var programContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Program Content")
                .font(.headline)
            
            ForEach(program.weeks.indices, id: \.self) { index in
                let week = program.weeks[index]
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week \(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(week)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.rawValue)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(term.rawValue) - \(period.rawValue)")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Weeks Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(1...period.weeksForTerm(term), id: \.self) { week in
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
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.rawValue)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(term.rawValue) - \(period.rawValue)")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Weeks \(weeks.map { String($0) }.joined(separator: ", "))")
                                .font(.title3)
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
                
                let response = try await chatGPTService.generateProgram(prompt: prompt)
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

#Preview {
    ProgramsView()
} 