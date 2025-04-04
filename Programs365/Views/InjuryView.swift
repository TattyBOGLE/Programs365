import SwiftUI

struct InjuryLogCard: View {
    let injury: Injury
    @State private var showingRehabProgram = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: injury.date)
    }
    
    var statusColor: Color {
        switch injury.status {
        case .active: return .red
        case .recovering: return .orange
        case .resolved: return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(injury.type)
                    .font(.headline)
                Spacer()
                Text(injury.status.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .cornerRadius(8)
            }
            
            Text("Reported: \(formattedDate)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Label("Severity", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                Text(injury.severity.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let notes = injury.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            if injury.status != .resolved {
                Button(action: { showingRehabProgram = true }) {
                    HStack {
                        Image(systemName: "figure.run")
                        Text("View Rehab Program")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
        .sheet(isPresented: $showingRehabProgram) {
            RehabProgramView(injury: injury)
        }
    }
}

struct InjuryView: View {
    @State private var selectedCategory: String?
    @State private var showingLogInjury = false
    @State private var showingPrevention = false
    @State private var showingMore = false
    @State private var selectedInjury: Injury?
    @State private var injuries: [Injury] = [
        // Sprint Injuries
        Injury(
            type: "Hamstring Strain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 28))!,
            severity: .moderate,
            status: .active,
            notes: "Occurred during 100m sprint training",
            eventCategory: "Sprints"
        ),
        Injury(
            type: "Calf Strain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 15))!,
            severity: .mild,
            status: .recovering,
            notes: "During 200m sprint session",
            eventCategory: "Sprints"
        ),
        
        // Middle Distance Injuries
        Injury(
            type: "Knee Pain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 5))!,
            severity: .mild,
            status: .resolved,
            notes: "Overuse injury from 800m training",
            eventCategory: "Middle Distance"
        ),
        Injury(
            type: "Shin Splints",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 20))!,
            severity: .moderate,
            status: .active,
            notes: "Developed during 1500m preparation",
            eventCategory: "Middle Distance"
        ),
        
        // Hurdles Injuries
        Injury(
            type: "Hip Flexor Strain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 10))!,
            severity: .moderate,
            status: .active,
            notes: "During hurdle technique training",
            eventCategory: "Hurdles"
        ),
        
        // Jumps Injuries
        Injury(
            type: "Ankle Sprain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 15))!,
            severity: .mild,
            status: .recovering,
            notes: "Landing during long jump practice",
            eventCategory: "Jumps"
        ),
        Injury(
            type: "Back Strain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 25))!,
            severity: .moderate,
            status: .resolved,
            notes: "During high jump takeoff",
            eventCategory: "Jumps"
        ),
        
        // Throws Injuries
        Injury(
            type: "Shoulder Strain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 5))!,
            severity: .moderate,
            status: .active,
            notes: "During shot put training",
            eventCategory: "Throws"
        ),
        
        // Cross Country Injuries
        Injury(
            type: "IT Band Syndrome",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 28))!,
            severity: .moderate,
            status: .recovering,
            notes: "Developed during cross country training",
            eventCategory: "Cross Country"
        )
    ]
    
    private let categories = ["Sprints", "Middle Distance", "Hurdles", "Jumps", "Throws", "Cross Country", "Recovery"]
    
    var filteredInjuries: [Injury] {
        if let category = selectedCategory {
            return injuries.filter { $0.eventCategory == category }
        }
        return injuries
    }
    
    var activeInjuries: [Injury] {
        filteredInjuries.filter { $0.status == .active }
    }
    
    var historyInjuries: [Injury] {
        filteredInjuries.filter { $0.status != .active }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack {
                        // Hero banner background image
                        Image("hero-banner")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.7),
                                        Color.black.opacity(0.4)
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        // Headings
                        VStack(spacing: 16) {
                            Text("Injury Tracking")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                            
                            Text("Monitor and Prevent Injuries")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(height: 300)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Event Categories Carousel
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        Button(action: {
                                            withAnimation {
                                                selectedCategory = selectedCategory == category ? nil : category
                                            }
                                        }) {
                                            VStack(spacing: 8) {
                                                Text(category)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                                                
                                                Text("\(injuries.filter { $0.eventCategory == category }.count) Injuries")
                                                    .font(.caption)
                                                    .foregroundColor(selectedCategory == category ? .white.opacity(0.8) : .gray.opacity(0.6))
                                            }
                                            .frame(width: 120)
                                            .padding(.vertical, 12)
                                            .background(
                                                selectedCategory == category ?
                                                Color.red.opacity(0.8) :
                                                Color(white: 0.15)
                                            )
                                            .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Quick Actions
                            HStack {
                                Button(action: { showingLogInjury = true }) {
                                    VStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title)
                                        Text("Log Injury")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                }
                                
                                Button(action: { showingPrevention = true }) {
                                    VStack {
                                        Image(systemName: "waveform.path.ecg")
                                            .font(.title)
                                        Text("Prevention")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(white: 0.15))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Active Injuries
                            if !activeInjuries.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Active Injuries")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(activeInjuries) { injury in
                                        InjuryLogCard(injury: injury)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // History
                            if !historyInjuries.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Injury History")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(historyInjuries) { injury in
                                        InjuryLogCard(injury: injury)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // More Button
                            Button(action: { showingMore = true }) {
                                HStack {
                                    Text("More")
                                        .font(.headline)
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(white: 0.15))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingLogInjury) {
                LogInjuryView(injuries: $injuries)
            }
            .sheet(isPresented: $showingPrevention) {
                InjuryPreventionView(injury: selectedInjury)
            }
            .sheet(isPresented: $showingMore) {
                MoreView()
            }
        }
    }
}

struct LogInjuryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var injuries: [Injury]
    
    @State private var injuryType = ""
    @State private var eventCategory = ""
    @State private var severity: Injury.Severity = .mild
    @State private var status: Injury.Status = .active
    @State private var notes = ""
    @State private var date = Date()
    
    private let categories = ["Sprints", "Middle Distance", "Hurdles", "Jumps", "Throws", "Cross Country", "Recovery"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Injury Details")) {
                    TextField("Injury Type", text: $injuryType)
                    
                    Picker("Event Category", selection: $eventCategory) {
                        Text("Select Category").tag("")
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Picker("Severity", selection: $severity) {
                        ForEach([Injury.Severity.mild, .moderate, .severe], id: \.self) { severity in
                            Text(severity.rawValue).tag(severity)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach([Injury.Status.active, .recovering, .resolved], id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log New Injury")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newInjury = Injury(
                            type: injuryType,
                            date: date,
                            severity: severity,
                            status: status,
                            notes: notes,
                            eventCategory: eventCategory
                        )
                        injuries.append(newInjury)
                        dismiss()
                    }
                    .disabled(injuryType.isEmpty || eventCategory.isEmpty)
                }
            }
        }
    }
}

struct InjuryPreventionView: View {
    @Environment(\.dismiss) private var dismiss
    let injury: Injury?
    @StateObject private var chatGPTService = ChatGPTService(apiKey: Config.API.chatGPTApiKey)
    @State private var preventionProgram: AttributedString = AttributedString("")
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text(preventionProgram)
                            .padding()
                    }
                }
            }
            .navigationTitle("Prevention Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await generatePreventionProgram()
            }
        }
    }
    
    private func generatePreventionProgram() async {
        isLoading = true
        error = nil
        
        let prompt = """
        Generate a detailed 4-week injury prevention program for \(injury?.type ?? "general injury prevention").
        
        Format the program as follows:
        
        WEEK 1
        **MONDAY**
        • Warm-up exercises (10 minutes)
        • Strengthening exercises (3 sets, 12 reps each)
        • Mobility work (10 minutes)
        • Cool-down stretches (10 minutes)
        
        **TUESDAY**
        [Same format as Monday with different exercises]
        
        **WEDNESDAY**
        [Same format as Monday with different exercises]
        
        **THURSDAY**
        [Same format as Monday with different exercises]
        
        **FRIDAY**
        [Same format as Monday with different exercises]
        
        **SATURDAY**
        [Same format as Monday with different exercises]
        
        **SUNDAY**
        Focus: Recovery and Active Rest
        
        WEEK 2
        [Same format as Week 1 with progressed exercises]
        
        WEEK 3
        [Same format as Week 2 with progressed exercises]
        
        WEEK 4
        [Same format as Week 3 with progressed exercises]
        
        Include:
        • Specific exercise names and descriptions
        • Sets, reps, and durations
        • Rest periods between exercises
        • Progression guidelines
        • Warning signs to watch for
        • Recovery recommendations
        """
        
        do {
            preventionProgram = try await chatGPTService.generateWorkoutPlan(prompt: prompt)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct RehabProgramView: View {
    @Environment(\.dismiss) private var dismiss
    let injury: Injury
    @StateObject private var chatGPTService = ChatGPTService(apiKey: Config.API.chatGPTApiKey)
    @State private var rehabProgram: AttributedString = AttributedString("")
    @State private var isLoading = false
    @State private var error: String?
    @State private var selectedWeek = 1
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Week Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(1...4, id: \.self) { week in
                                Button(action: { selectedWeek = week }) {
                                    Text("Week \(week)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedWeek == week ? .white : .gray)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedWeek == week ?
                                            Color.blue.opacity(0.8) :
                                            Color(white: 0.15)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            // Program Content
                            Text(rehabProgram)
                                .padding()
                            
                            // Progress Tracking
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Progress Tracking")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                HStack {
                                    ForEach(1...4, id: \.self) { week in
                                        Circle()
                                            .fill(week <= selectedWeek ? Color.blue : Color.gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Rehabilitation Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await generateRehabProgram()
            }
        }
    }
    
    private func generateRehabProgram() async {
        isLoading = true
        error = nil
        
        let prompt = """
        Generate a detailed 4-week rehabilitation program for \(injury.type) in \(injury.eventCategory).
        
        Format the program as follows:
        
        WEEK 1
        **MONDAY**
        • Assessment and gentle mobility exercises (15 minutes)
        • Pain-free range of motion exercises (3 sets, 10 reps each)
        • Basic strengthening exercises (2 sets, 8 reps each)
        • Ice/heat therapy recommendations
        • Rest guidelines
        
        **TUESDAY**
        [Same format as Monday with different exercises]
        
        **WEDNESDAY**
        [Same format as Monday with different exercises]
        
        **THURSDAY**
        [Same format as Monday with different exercises]
        
        **FRIDAY**
        [Same format as Monday with different exercises]
        
        **SATURDAY**
        [Same format as Monday with different exercises]
        
        **SUNDAY**
        Focus: Recovery and Active Rest
        
        WEEK 2
        • Progress from Week 1 exercises
        • Add resistance bands or light weights
        • Increase sets and reps gradually
        • Include balance exercises
        
        WEEK 3
        • Further progression of exercises
        • Add sport-specific movements
        • Increase intensity gradually
        • Include proprioception training
        
        WEEK 4
        • Return to sport preparation
        • Full range of motion exercises
        • Sport-specific drills
        • Gradual return to training guidelines
        
        Include for each week:
        • Specific exercise names and descriptions
        • Sets, reps, and durations
        • Rest periods between exercises
        • Pain management guidelines
        • Warning signs to watch for
        • Recovery recommendations
        • Progress indicators
        """
        
        do {
            rehabProgram = try await chatGPTService.generateWorkoutPlan(prompt: prompt)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct MoreView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("More Options")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Text("Access additional features and settings")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Progress Section
                    NavigationLink(destination: ProgressView()) {
                        MoreOptionCard(
                            title: "Progress",
                            subtitle: "Track and view your training progress",
                            icon: "waveform.path.ecg",
                            iconColor: .blue
                        )
                    }
                    
                    // Nutrition Plans Section
                    NavigationLink(destination: NutritionPlansView()) {
                        MoreOptionCard(
                            title: "Nutrition Plans",
                            subtitle: "Elite athlete nutrition and meal plans",
                            icon: "fork.knife",
                            iconColor: .green
                        )
                    }
                    
                    // Injury Rehabilitation Section
                    NavigationLink(destination: InjuryRehabilitationView()) {
                        MoreOptionCard(
                            title: "Injury Rehabilitation",
                            subtitle: "Comprehensive recovery programs for injuries",
                            icon: "heart.fill",
                            iconColor: .pink
                        )
                    }
                    
                    // Injury Analysis Section
                    NavigationLink(destination: InjuryAnalysisView()) {
                        MoreOptionCard(
                            title: "Injury Analysis",
                            subtitle: "AI-assisted injury assessment tool",
                            icon: "camera.fill",
                            iconColor: .purple
                        )
                    }
                    
                    // Achievements Section
                    NavigationLink(destination: AchievementsView()) {
                        MoreOptionCard(
                            title: "Achievements",
                            subtitle: "View your medals and accomplishments",
                            icon: "medal.fill",
                            iconColor: .yellow
                        )
                    }
                    
                    // Settings Section
                    NavigationLink(destination: SettingsView()) {
                        MoreOptionCard(
                            title: "Settings",
                            subtitle: "App preferences and account settings",
                            icon: "gearshape.fill",
                            iconColor: .gray
                        )
                    }
                    
                    // Training History Section
                    NavigationLink(destination: TrainingHistoryView()) {
                        MoreOptionCard(
                            title: "Training History",
                            subtitle: "View past workouts and sessions",
                            icon: "calendar",
                            iconColor: .green
                        )
                    }
                    
                    // Sync Data Section
                    NavigationLink(destination: SyncDataView()) {
                        MoreOptionCard(
                            title: "Sync Data",
                            subtitle: "Synchronize with other fitness apps",
                            icon: "arrow.triangle.2.circlepath",
                            iconColor: .purple
                        )
                    }
                    
                    // Help & Support Section
                    NavigationLink(destination: HelpSupportView()) {
                        MoreOptionCard(
                            title: "Help & Support",
                            subtitle: "Get assistance and view tutorials",
                            icon: "questionmark.circle.fill",
                            iconColor: .orange
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
}

struct MoreOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Define enums at file level

struct ChartView: View {
    let metric: TrainingMetric
    let timeFrame: TimeFrame
    
    var body: some View {
        VStack {
            // Placeholder for actual chart implementation
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.red.opacity(0.5), .red.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .overlay(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 100))
                        path.addCurve(
                            to: CGPoint(x: 300, y: 50),
                            control1: CGPoint(x: 100, y: 150),
                            control2: CGPoint(x: 200, y: 0)
                        )
                    }
                    .stroke(Color.red, lineWidth: 2)
                )
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

// Progress View
struct ProgressView: View {
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var selectedMetric: TrainingMetric = .distance
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time Frame Selector
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Metrics Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TrainingMetric.allCases, id: \.self) { metric in
                            MetricButton(
                                title: metric.rawValue,
                                isSelected: metric == selectedMetric,
                                action: { selectedMetric = metric }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Progress Chart
                ChartView(metric: selectedMetric, timeFrame: selectedTimeFrame)
                    .frame(height: 250)
                    .padding()
                
                // Training Summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Training Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        SummaryCard(title: "Total Distance", value: "42.5 km", change: "+3.2 km")
                        SummaryCard(title: "Total Time", value: "5h 30m", change: "+45m")
                        SummaryCard(title: "Avg. Pace", value: "4:32/km", change: "-0:05")
                        SummaryCard(title: "Elevation", value: "350m", change: "+50m")
                    }
                }
                .padding()
                
                // Recent Activities
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activities")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ForEach(1...3, id: \.self) { _ in
                        ActivityCard()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Progress")
        .background(Color.black.ignoresSafeArea())
    }
}

struct MetricButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : Color(UIColor.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let change: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(change)
                .font(.caption)
                .foregroundColor(change.hasPrefix("+") ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.red)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "figure.run")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Track Session")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("10km • 45:30 • 4:33/km")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("1h ago")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct NutritionProgressRing: View {
    let value: Double
    let title: String
    let detail: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(Color.red, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(detail)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 80, height: 80)
        }
    }
}

struct NutritionPlansView: View {
    @State private var selectedMealTime: MealTime = .breakfast
    @State private var selectedDate = Date()
    @State private var selectedDietType: DietType = .performance
    
    enum MealTime: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snacks = "Snacks"
    }
    
    enum DietType: String, CaseIterable {
        case performance = "Performance"
        case recovery = "Recovery"
        case weightManagement = "Weight Management"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Diet Type Selector
                Picker("Diet Type", selection: $selectedDietType) {
                    ForEach(DietType.allCases, id: \.self) { dietType in
                        Text(dietType.rawValue).tag(dietType)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Date Selector
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding()
                
                // Meal Time Selector
                Picker("Meal Time", selection: $selectedMealTime) {
                    ForEach(MealTime.allCases, id: \.self) { mealTime in
                        Text(mealTime.rawValue).tag(mealTime)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Nutrition Summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 16) {
                        NutritionProgressRing(value: 0.7, title: "Calories", detail: "1750/2500")
                        NutritionProgressRing(value: 0.8, title: "Protein", detail: "120/150g")
                        NutritionProgressRing(value: 0.6, title: "Carbs", detail: "180/300g")
                        NutritionProgressRing(value: 0.5, title: "Fats", detail: "45/90g")
                    }
                }
                .padding()
                
                // Meal Plan
                VStack(alignment: .leading, spacing: 16) {
                    Text(selectedMealTime.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ForEach(getMeals(for: selectedMealTime), id: \.self) { meal in
                        MealCard(meal: meal)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Nutrition Plans")
        .background(Color.black.ignoresSafeArea())
    }
    
    private func getMeals(for mealTime: MealTime) -> [Meal] {
        switch mealTime {
        case .breakfast:
            return [
                Meal(
                    name: "Power Breakfast Bowl",
                    description: "Oatmeal with banana, honey, and mixed nuts",
                    calories: 450,
                    protein: 15,
                    carbs: 65,
                    fats: 18
                ),
                Meal(
                    name: "Protein Pancakes",
                    description: "Whole grain pancakes with protein powder and fresh berries",
                    calories: 380,
                    protein: 25,
                    carbs: 45,
                    fats: 12
                ),
                Meal(
                    name: "Greek Yogurt Parfait",
                    description: "Greek yogurt with granola, berries, and chia seeds",
                    calories: 320,
                    protein: 20,
                    carbs: 35,
                    fats: 10
                ),
                Meal(
                    name: "Breakfast Burrito",
                    description: "Whole wheat tortilla with eggs, black beans, and avocado",
                    calories: 420,
                    protein: 22,
                    carbs: 45,
                    fats: 15
                ),
                Meal(
                    name: "Smoothie Bowl",
                    description: "Acai bowl with protein powder, fruits, and coconut flakes",
                    calories: 350,
                    protein: 18,
                    carbs: 42,
                    fats: 12
                )
            ]
        case .lunch:
            return [
                Meal(
                    name: "Grilled Chicken Salad",
                    description: "Mixed greens with grilled chicken, cherry tomatoes, and balsamic dressing",
                    calories: 380,
                    protein: 35,
                    carbs: 15,
                    fats: 18
                ),
                Meal(
                    name: "Quinoa Buddha Bowl",
                    description: "Quinoa with roasted vegetables, chickpeas, and tahini sauce",
                    calories: 420,
                    protein: 18,
                    carbs: 55,
                    fats: 16
                ),
                Meal(
                    name: "Tuna Wrap",
                    description: "Whole wheat wrap with tuna, avocado, and mixed greens",
                    calories: 350,
                    protein: 28,
                    carbs: 35,
                    fats: 12
                ),
                Meal(
                    name: "Mediterranean Plate",
                    description: "Hummus, falafel, tabbouleh, and pita bread",
                    calories: 450,
                    protein: 15,
                    carbs: 65,
                    fats: 18
                ),
                Meal(
                    name: "Turkey Club Sandwich",
                    description: "Whole grain bread with turkey, bacon, lettuce, and tomato",
                    calories: 480,
                    protein: 32,
                    carbs: 45,
                    fats: 22
                )
            ]
        case .dinner:
            return [
                Meal(
                    name: "Salmon with Sweet Potato",
                    description: "Grilled salmon with roasted sweet potato and steamed broccoli",
                    calories: 450,
                    protein: 35,
                    carbs: 35,
                    fats: 22
                ),
                Meal(
                    name: "Beef Stir-Fry",
                    description: "Lean beef with mixed vegetables and brown rice",
                    calories: 480,
                    protein: 38,
                    carbs: 45,
                    fats: 18
                ),
                Meal(
                    name: "Vegetarian Pasta",
                    description: "Whole grain pasta with marinara sauce and vegetables",
                    calories: 420,
                    protein: 15,
                    carbs: 65,
                    fats: 12
                ),
                Meal(
                    name: "Chicken Curry",
                    description: "Chicken curry with brown rice and naan bread",
                    calories: 520,
                    protein: 32,
                    carbs: 55,
                    fats: 22
                ),
                Meal(
                    name: "Pork Tenderloin",
                    description: "Grilled pork tenderloin with roasted vegetables and quinoa",
                    calories: 450,
                    protein: 42,
                    carbs: 35,
                    fats: 18
                )
            ]
        case .snacks:
            return [
                Meal(
                    name: "Protein Smoothie",
                    description: "Protein powder, banana, spinach, and almond milk",
                    calories: 280,
                    protein: 25,
                    carbs: 32,
                    fats: 8
                ),
                Meal(
                    name: "Trail Mix",
                    description: "Mixed nuts, dried fruits, and dark chocolate",
                    calories: 320,
                    protein: 12,
                    carbs: 35,
                    fats: 18
                ),
                Meal(
                    name: "Greek Yogurt with Honey",
                    description: "Greek yogurt topped with honey and granola",
                    calories: 250,
                    protein: 18,
                    carbs: 28,
                    fats: 8
                ),
                Meal(
                    name: "Rice Cakes with Peanut Butter",
                    description: "Whole grain rice cakes with natural peanut butter",
                    calories: 280,
                    protein: 12,
                    carbs: 35,
                    fats: 12
                ),
                Meal(
                    name: "Fruit and Cheese Plate",
                    description: "Mixed fruits with low-fat cheese and nuts",
                    calories: 300,
                    protein: 15,
                    carbs: 35,
                    fats: 15
                )
            ]
        }
    }
}

struct Meal: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
}

struct MealCard: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.red)
                Text(meal.name)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(meal.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                NutrientTag(title: "\(meal.calories) kcal")
                NutrientTag(title: "\(meal.protein)g Protein")
                NutrientTag(title: "\(meal.carbs)g Carbs")
                NutrientTag(title: "\(meal.fats)g Fats")
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct NutrientTag: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.2))
            .cornerRadius(12)
    }
}

// Injury Rehabilitation View
struct InjuryRehabilitationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Rehabilitation Programs")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // Rehabilitation program content will go here
            }
        }
        .navigationTitle("Rehabilitation")
        .background(Color.black.ignoresSafeArea())
    }
}

// Injury Analysis View
struct InjuryAnalysisView: View {
    @State private var selectedBodyPart: BodyPart = .knee
    @State private var painLevel: Double = 5
    @State private var symptoms: String = ""
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var analysisResult: AnalysisResult?
    @State private var isAnalyzing = false
    
    enum BodyPart: String, CaseIterable {
        case knee = "Knee"
        case ankle = "Ankle"
        case hip = "Hip"
        case back = "Back"
        case shoulder = "Shoulder"
        case elbow = "Elbow"
        case wrist = "Wrist"
        case neck = "Neck"
    }
    
    struct AnalysisResult {
        let severity: String
        let recommendation: String
        let treatment: String
        let recoveryTime: String
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Body Part Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Area of Concern")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(BodyPart.allCases, id: \.self) { bodyPart in
                                BodyPartButton(
                                    title: bodyPart.rawValue,
                                    isSelected: bodyPart == selectedBodyPart,
                                    action: { selectedBodyPart = bodyPart }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                // Pain Level Slider
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pain Level")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("1")
                            .foregroundColor(.gray)
                        Slider(value: $painLevel, in: 1...10, step: 1)
                            .accentColor(.red)
                        Text("10")
                            .foregroundColor(.gray)
                    }
                    
                    Text("Selected: \(Int(painLevel))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Symptoms Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Describe Symptoms")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextEditor(text: $symptoms)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Image Upload
                VStack(alignment: .leading, spacing: 12) {
                    Text("Visual Analysis")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { showingCamera = true }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(selectedImage == nil ? "Take Photo" : "Retake Photo")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Analysis Results
                if let result = analysisResult {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Analysis Results")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        ResultCard(title: "Severity", value: result.severity)
                        ResultCard(title: "Recommended Action", value: result.recommendation)
                        ResultCard(title: "Treatment Plan", value: result.treatment)
                        ResultCard(title: "Expected Recovery", value: result.recoveryTime)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Analyze Button
                Button(action: analyzeInjury) {
                    if isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Analyze Injury")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(symptoms.isEmpty)
            }
        }
        .navigationTitle("Injury Analysis")
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func analyzeInjury() {
        isAnalyzing = true
        
        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            analysisResult = AnalysisResult(
                severity: "Moderate",
                recommendation: "Consult with sports physician",
                treatment: "Rest, Ice, Compression, Elevation (RICE) protocol recommended",
                recoveryTime: "2-3 weeks with proper treatment"
            )
            isAnalyzing = false
        }
    }
}

struct BodyPartButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : Color(UIColor.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Settings View
struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Account")) {
                Text("Profile Settings")
                Text("Notifications")
                Text("Privacy")
            }
            
            Section(header: Text("App Settings")) {
                Text("Theme")
                Text("Language")
                Text("Units")
            }
            
            Section(header: Text("About")) {
                Text("Version")
                Text("Terms of Service")
                Text("Privacy Policy")
            }
        }
        .navigationTitle("Settings")
        .background(Color.black.ignoresSafeArea())
    }
}

// Training History View
struct TrainingHistoryView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Training History")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // Training history content will go here
            }
        }
        .navigationTitle("History")
        .background(Color.black.ignoresSafeArea())
    }
}

// Sync Data View
struct SyncDataView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Sync Your Data")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // Sync options will go here
            }
        }
        .navigationTitle("Sync Data")
        .background(Color.black.ignoresSafeArea())
    }
}

// Help & Support View
struct HelpSupportView: View {
    var body: some View {
        List {
            Section(header: Text("Help Center")) {
                Text("FAQs")
                Text("Contact Support")
                Text("Report an Issue")
            }
            
            Section(header: Text("Resources")) {
                Text("User Guide")
                Text("Video Tutorials")
                Text("Community Forum")
            }
        }
        .navigationTitle("Help & Support")
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    InjuryView()
} 