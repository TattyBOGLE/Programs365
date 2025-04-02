import SwiftUI

struct InjuryLogCard: View {
    let injury: Injury
    
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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct InjuryView: View {
    @State private var injuries: [Injury] = [
        Injury(
            type: "Hamstring Strain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 28))!,
            severity: .moderate,
            status: .active,
            notes: "Occurred during sprint training"
        ),
        Injury(
            type: "Ankle Sprain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 2, day: 15))!,
            severity: .mild,
            status: .recovering,
            notes: "Rolled ankle during agility drills"
        ),
        Injury(
            type: "Knee Pain",
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 5))!,
            severity: .mild,
            status: .resolved,
            notes: "Overuse injury from increased mileage"
        )
    ]
    
    var activeInjuries: [Injury] {
        injuries.filter { $0.status == .active }
    }
    
    var historyInjuries: [Injury] {
        injuries.filter { $0.status != .active }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    HStack {
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                Text("Log Injury")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "waveform.path.ecg")
                                    .font(.title)
                                Text("Prevention")
                                    .font(.caption)
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Active Injuries
                    if !activeInjuries.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Active")
                                .font(.title2)
                                .fontWeight(.bold)
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
                            Text("History")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(historyInjuries) { injury in
                                InjuryLogCard(injury: injury)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Injury Tracking")
        }
    }
}

#Preview {
    InjuryView()
} 