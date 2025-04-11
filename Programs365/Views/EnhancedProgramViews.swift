import SwiftUI

// MARK: - Enhanced Program Parameter Selection View
struct EnhancedProgramParametersView: View {
    @Binding var parameters: EnhancedProgramParameters
    @Environment(\.dismiss) private var dismiss
    @State private var showingWarmUpProtocol = false
    @State private var showingInjuryPrevention = false
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Parameters
                Section(header: Text("Basic Parameters")) {
                    Picker("Age Group", selection: $parameters.ageGroup) {
                        ForEach(AgeGroup.allCases) { ageGroup in
                            Text(ageGroup.rawValue).tag(ageGroup)
                        }
                    }
                    
                    Picker("Event", selection: $parameters.event) {
                        ForEach(parameters.ageGroup.allowedEvents) { event in
                            Text(event.rawValue).tag(event)
                        }
                    }
                    
                    Picker("Gender", selection: $parameters.gender) {
                        ForEach(Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }
                
                // Training Context
                Section(header: Text("Training Context")) {
                    Picker("Term", selection: $parameters.term) {
                        ForEach(TrainingTerm.allCases) { term in
                            Text(term.rawValue).tag(term)
                        }
                    }
                    
                    Picker("Period", selection: $parameters.period) {
                        ForEach(TrainingPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    
                    Picker("Periodization Model", selection: $parameters.periodizationModel) {
                        ForEach(PeriodizationModel.allCases) { model in
                            Text(model.rawValue)
                                .tag(model)
                        }
                    }
                    
                    Picker("Load Management", selection: $parameters.loadManagement) {
                        ForEach(LoadManagementType.allCases) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                }
                
                // Event-Specific Protocols
                Section(header: Text("Event-Specific Protocols")) {
                    Button(action: { showingWarmUpProtocol = true }) {
                        HStack {
                            Image(systemName: "flame")
                                .foregroundColor(.red)
                            Text("View Warm-Up Protocol")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: { showingInjuryPrevention = true }) {
                        HStack {
                            Image(systemName: "bandage")
                                .foregroundColor(.blue)
                            Text("View Injury Prevention")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Environmental Factors
                Section(header: Text("Environmental Factors")) {
                    Picker("Training Environment", selection: $parameters.environment) {
                        ForEach(TrainingEnvironment.allCases) { env in
                            Text(env.rawValue).tag(env)
                        }
                    }
                    
                    Picker("Weather Conditions", selection: $parameters.weather) {
                        ForEach(WeatherCondition.allCases) { weather in
                            Text(weather.rawValue).tag(weather)
                        }
                    }
                }
                
                // Facility Limitations
                Section(header: Text("Facility Limitations")) {
                    FacilityLimitationsView(limitations: $parameters.facilityLimitations)
                }
                
                // Female Athlete Considerations
                if parameters.gender == .female {
                    Section(header: Text("Female Athlete Considerations")) {
                        Picker("Menstrual Phase", selection: $parameters.menstrualPhase.toUnwrapped(defaultValue: .unknown)) {
                            ForEach(MenstrualPhase.allCases) { phase in
                                Text(phase.rawValue).tag(phase)
                            }
                        }
                    }
                }
                
                // Training History
                Section(header: Text("Training History")) {
                    Stepper("Years of Training: \(parameters.trainingHistory)",
                           value: $parameters.trainingHistory,
                           in: 0...20)
                }
            }
            .navigationTitle("Program Parameters")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
            .sheet(isPresented: $showingWarmUpProtocol) {
                WarmUpProtocolView(event: parameters.event, period: parameters.period)
            }
            .sheet(isPresented: $showingInjuryPrevention) {
                EventInjuryPreventionView(event: parameters.event)
            }
        }
    }
}

// MARK: - Facility Limitations View
private struct FacilityLimitationsView: View {
    @Binding var limitations: [FacilityLimitation]
    
    var body: some View {
        ForEach(FacilityLimitation.allCases) { limitation in
            Toggle(limitation.rawValue, isOn: Binding(
                get: { limitations.contains(limitation) },
                set: { isSelected in
                    if isSelected {
                        limitations.append(limitation)
                    } else {
                        limitations.removeAll { $0 == limitation }
                    }
                }
            ))
        }
    }
}

// MARK: - Enhanced Program Display View
struct EnhancedProgramDisplayView: View {
    let program: String
    
    var body: some View {
        ScrollView {
            Text(formatProgram(program))
                .font(.body)
                .padding()
        }
    }
    
    private func formatProgram(_ program: String) -> AttributedString {
        var attributedString = AttributedString(program)
        
        // Define the days of the week
        let days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
        
        // Format each day header
        for day in days {
            if let range = attributedString.range(of: day) {
                attributedString[range].font = .title2.bold()
                attributedString[range].foregroundColor = .red
            }
        }
        
        return attributedString
    }
}

// MARK: - Warm-Up Protocol Management View
struct WarmUpProtocolView: View {
    let event: TrackEvent
    let period: TrainingPeriod
    @State private var components: [WarmUpComponent] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Event-Specific Warm-Up")) {
                    ForEach(components.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(components[index].name)
                                .font(.headline)
                            Text("\(components[index].duration) minutes")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Focus: \(components[index].focus)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            
                            ForEach(components[index].exercises, id: \.self) { exercise in
                                Text("• \(exercise)")
                                    .font(.body)
                                    .padding(.leading)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Warm-Up Protocol")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .onAppear {
                loadWarmUpComponents()
            }
        }
    }
    
    private func loadWarmUpComponents() {
        // Load event-specific warm-up components
        switch event.category {
        case "Sprints":
            components = [
                WarmUpComponent(
                    name: "General Warm-Up",
                    duration: 10,
                    exercises: [
                        "Light jogging",
                        "Dynamic stretching",
                        "Mobility drills"
                    ],
                    focus: "Increase body temperature and mobility"
                ),
                WarmUpComponent(
                    name: "Sprint-Specific Drills",
                    duration: 15,
                    exercises: [
                        "A-skips",
                        "B-skips",
                        "High knees",
                        "Straight leg bounds"
                    ],
                    focus: "Sprint mechanics and coordination"
                ),
                WarmUpComponent(
                    name: "Acceleration Development",
                    duration: 10,
                    exercises: [
                        "Push-up starts",
                        "2-point starts",
                        "3-point starts",
                        "Block starts (if applicable)"
                    ],
                    focus: "Start technique and acceleration"
                )
            ]
            
        case "Jumps":
            components = [
                WarmUpComponent(
                    name: "General Preparation",
                    duration: 10,
                    exercises: [
                        "Light jogging",
                        "Dynamic stretching",
                        "Ankle mobility work"
                    ],
                    focus: "Joint mobility and muscle activation"
                ),
                WarmUpComponent(
                    name: "Plyometric Preparation",
                    duration: 12,
                    exercises: [
                        "Ankle hops",
                        "Split jumps",
                        "Box jumps (low height)",
                        "Bounding"
                    ],
                    focus: "Jump-specific power development"
                ),
                WarmUpComponent(
                    name: "Technical Preparation",
                    duration: 15,
                    exercises: [
                        "Run-up practice",
                        "Take-off drills",
                        "Landing practice",
                        "Short approach jumps"
                    ],
                    focus: "Event-specific technique"
                )
            ]
            
        case "Throws":
            components = [
                WarmUpComponent(
                    name: "General Mobility",
                    duration: 12,
                    exercises: [
                        "Light jogging",
                        "Dynamic stretching",
                        "Shoulder mobility work",
                        "Medicine ball exercises"
                    ],
                    focus: "Upper body mobility and activation"
                ),
                WarmUpComponent(
                    name: "Throwing Preparation",
                    duration: 15,
                    exercises: [
                        "Standing throws",
                        "Power position work",
                        "Technical drills",
                        "Light implement throws"
                    ],
                    focus: "Throwing technique and power"
                )
            ]
            
        default:
            components = [
                WarmUpComponent(
                    name: "General Warm-Up",
                    duration: 15,
                    exercises: [
                        "Light jogging",
                        "Dynamic stretching",
                        "Event-specific mobility work"
                    ],
                    focus: "Basic preparation"
                )
            ]
        }
    }
}

// MARK: - Injury Prevention View
struct EventInjuryPreventionView: View {
    let event: TrackEvent
    @State private var preventionGuidelines: [InjuryPreventionGuideline] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Event-Specific Injury Prevention")) {
                    ForEach(preventionGuidelines) { guideline in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(guideline.title)
                                .font(.headline)
                            Text(guideline.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(guideline.exercises, id: \.self) { exercise in
                                Text("• \(exercise)")
                                    .font(.body)
                                    .padding(.leading)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Injury Prevention")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .onAppear {
                loadPreventionGuidelines()
            }
        }
    }
    
    private func loadPreventionGuidelines() {
        // Load event-specific injury prevention guidelines
        switch event.category {
        case "Sprints":
            preventionGuidelines = [
                InjuryPreventionGuideline(
                    title: "Hamstring Injury Prevention",
                    description: "Focus on hamstring strength and flexibility",
                    exercises: [
                        "Nordic hamstring curls",
                        "Single-leg deadlifts",
                        "Hip bridges",
                        "Dynamic stretching"
                    ]
                ),
                InjuryPreventionGuideline(
                    title: "Ankle Stability",
                    description: "Improve ankle stability and proprioception",
                    exercises: [
                        "Single-leg balance",
                        "Ankle mobility drills",
                        "Calf raises",
                        "Lateral bounds"
                    ]
                )
            ]
        case "Middle Distance", "Long Distance":
            preventionGuidelines = [
                InjuryPreventionGuideline(
                    title: "Shin Splint Prevention",
                    description: "Reduce impact stress on lower legs",
                    exercises: [
                        "Calf raises",
                        "Toe raises",
                        "Foam rolling",
                        "Foot strengthening"
                    ]
                ),
                InjuryPreventionGuideline(
                    title: "Knee Stability",
                    description: "Strengthen knee stabilizers",
                    exercises: [
                        "Single-leg squats",
                        "Lunges",
                        "Step-ups",
                        "Hip strengthening"
                    ]
                )
            ]
        default:
            preventionGuidelines = [
                InjuryPreventionGuideline(
                    title: "General Injury Prevention",
                    description: "Basic injury prevention guidelines",
                    exercises: [
                        "Dynamic stretching",
                        "Core strengthening",
                        "Balance exercises",
                        "Mobility work"
                    ]
                )
            ]
        }
    }
}

// MARK: - Injury Prevention Guideline Model
struct InjuryPreventionGuideline: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let exercises: [String]
}

// MARK: - Helper Extensions
extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T> {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

// MARK: - Preview Providers
struct WarmUpProtocolView_Previews: PreviewProvider {
    static var previews: some View {
        WarmUpProtocolView(event: .sprints100m, period: .specific)
    }
}

struct EventInjuryPreventionView_Previews: PreviewProvider {
    static var previews: some View {
        EventInjuryPreventionView(event: .sprints100m)
    }
}

#Preview {
    EnhancedProgramParametersView(parameters: .constant(EnhancedProgramParameters(
        ageGroup: .u16,
        event: .sprints100m,
        term: .shortTerm,
        period: .specific,
        gender: .male
    )))
} 