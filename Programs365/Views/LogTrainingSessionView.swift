import SwiftUI

struct LogTrainingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dataManager: TrainingDataManager
    
    @State private var activityType: TrainingSession.ActivityType = .running
    @State private var date = Date()
    @State private var hours: Int = 0
    @State private var minutes: Int = 30
    @State private var seconds: Int = 0
    @State private var distance: String = ""
    @State private var pace: String = ""
    @State private var elevation: String = ""
    @State private var intensity: TrainingSession.IntensityLevel = .moderate
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    Picker("Activity Type", selection: $activityType) {
                        ForEach(TrainingSession.ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Picker("Hours", selection: $hours) {
                            ForEach(0...23, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 70)
                        
                        Picker("Minutes", selection: $minutes) {
                            ForEach(0...59, id: \.self) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 70)
                        
                        Picker("Seconds", selection: $seconds) {
                            ForEach(0...59, id: \.self) { second in
                                Text("\(second)s").tag(second)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 70)
                    }
                }
                
                Section(header: Text("Performance Metrics")) {
                    HStack {
                        Text("Distance (km)")
                        Spacer()
                        TextField("0.0", text: $distance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Pace (min/km)")
                        Spacer()
                        TextField("0:00", text: $pace)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Elevation (m)")
                        Spacer()
                        TextField("0", text: $elevation)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section(header: Text("Intensity")) {
                    Picker("Intensity Level", selection: $intensity) {
                        ForEach(TrainingSession.IntensityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Training")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white),
                trailing: Button("Save") {
                    saveSession()
                }
                .foregroundColor(.white)
            )
        }
    }
    
    private func saveSession() {
        // Calculate total duration in seconds
        let totalDuration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        
        // Create a new training session
        let session = TrainingSession(
            date: date,
            type: activityType,
            duration: totalDuration,
            distance: Double(distance),
            pace: parsePace(pace),
            elevation: Double(elevation),
            notes: notes.isEmpty ? nil : notes,
            intensity: intensity
        )
        
        // Add the session to the data manager
        dataManager.addSession(session)
        
        // Dismiss the view
        dismiss()
    }
    
    private func parsePace(_ paceString: String) -> Double? {
        // Handle formats like "5:30" (minutes:seconds)
        let components = paceString.split(separator: ":")
        guard components.count == 2,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]) else {
            return nil
        }
        
        return minutes + seconds / 60.0
    }
} 