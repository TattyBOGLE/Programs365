import Foundation
import Combine

class TrainingDataManager: ObservableObject {
    @Published var sessions: [TrainingSession] = []
    private let saveKey = "training_sessions"
    
    init() {
        loadSessions()
    }
    
    // MARK: - Data Management
    
    func addSession(_ session: TrainingSession) {
        sessions.append(session)
        saveSessions()
    }
    
    func updateSession(_ session: TrainingSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }
    
    func deleteSession(at indexSet: IndexSet) {
        sessions.remove(atOffsets: indexSet)
        saveSessions()
    }
    
    func deleteSession(id: UUID) {
        sessions.removeAll { $0.id == id }
        saveSessions()
    }
    
    // MARK: - Data Filtering
    
    func sessionsForTimeFrame(_ timeFrame: TimeFrame) -> [TrainingSession] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeFrame {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .allTime:
            startDate = Date.distantPast
        }
        
        return sessions.filter { $0.date >= startDate && $0.date <= now }
    }
    
    func sessionsForMetric(_ metric: TrainingMetric, timeFrame: TimeFrame) -> [TrainingSession] {
        let filteredSessions = sessionsForTimeFrame(timeFrame)
        
        switch metric {
        case .distance:
            return filteredSessions.filter { $0.distance != nil }
        case .time:
            return filteredSessions
        case .pace:
            return filteredSessions.filter { $0.pace != nil }
        case .elevation:
            return filteredSessions.filter { $0.elevation != nil }
        case .intensity:
            return filteredSessions // Intensity is always non-nil
        case .volume:
            return filteredSessions
        }
    }
    
    // MARK: - Statistics
    
    func totalDistance(for timeFrame: TimeFrame) -> Double {
        sessionsForTimeFrame(timeFrame)
            .compactMap { $0.distance }
            .reduce(0, +)
    }
    
    func totalTime(for timeFrame: TimeFrame) -> TimeInterval {
        sessionsForTimeFrame(timeFrame)
            .map { $0.duration }
            .reduce(0, +)
    }
    
    func averagePace(for timeFrame: TimeFrame) -> Double? {
        let sessionsWithPace = sessionsForTimeFrame(timeFrame)
            .compactMap { $0.pace }
        
        guard !sessionsWithPace.isEmpty else { return nil }
        return sessionsWithPace.reduce(0, +) / Double(sessionsWithPace.count)
    }
    
    func totalElevation(for timeFrame: TimeFrame) -> Double {
        sessionsForTimeFrame(timeFrame)
            .compactMap { $0.elevation }
            .reduce(0, +)
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TrainingSession].self, from: data) {
            sessions = decoded
        }
    }
} 