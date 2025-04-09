import SwiftUI
import Charts

struct ChartView: View {
    let metric: TrainingMetric
    let timeFrame: TimeFrame
    @ObservedObject var dataManager: TrainingDataManager
    
    var body: some View {
        VStack {
            if #available(iOS 16.0, *) {
                // Use Swift Charts for iOS 16+
                ChartContent(metric: metric, timeFrame: timeFrame, dataManager: dataManager)
            } else {
                // Fallback for older iOS versions
                LegacyChartContent(metric: metric, timeFrame: timeFrame, dataManager: dataManager)
            }
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

@available(iOS 16.0, *)
struct ChartContent: View {
    let metric: TrainingMetric
    let timeFrame: TimeFrame
    @ObservedObject var dataManager: TrainingDataManager
    
    var body: some View {
        let sessions = dataManager.sessionsForMetric(metric, timeFrame: timeFrame)
        
        if sessions.isEmpty {
            EmptyChartView()
        } else {
            Chart {
                ForEach(sessions) { session in
                    switch metric {
                    case .distance:
                        if let distance = session.distance {
                            BarMark(
                                x: .value("Date", session.date),
                                y: .value("Distance", distance)
                            )
                            .foregroundStyle(Color.red.gradient)
                        }
                    case .time:
                        BarMark(
                            x: .value("Date", session.date),
                            y: .value("Duration", session.duration / 60) // Convert to minutes
                        )
                        .foregroundStyle(Color.red.gradient)
                    case .pace:
                        if let pace = session.pace {
                            LineMark(
                                x: .value("Date", session.date),
                                y: .value("Pace", pace)
                            )
                            .foregroundStyle(Color.red)
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                        }
                    case .elevation:
                        if let elevation = session.elevation {
                            BarMark(
                                x: .value("Date", session.date),
                                y: .value("Elevation", elevation)
                            )
                            .foregroundStyle(Color.red.gradient)
                        }
                    case .intensity:
                        BarMark(
                            x: .value("Date", session.date),
                            y: .value("Intensity", intensityValue(for: session.intensity))
                        )
                        .foregroundStyle(Color.red.gradient)
                    case .volume:
                        BarMark(
                            x: .value("Date", session.date),
                            y: .value("Volume", session.duration / 60) // Using duration as volume
                        )
                        .foregroundStyle(Color.red.gradient)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: timeFrame.strideBy)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: timeFrame.dateFormat)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(formatYAxisValue(doubleValue, for: metric))
                        }
                    }
                }
            }
            .frame(height: 250)
        }
    }
    
    private func intensityValue(for intensity: TrainingSession.IntensityLevel) -> Double {
        switch intensity {
        case .low:
            return 1.0
        case .moderate:
            return 2.0
        case .high:
            return 3.0
        }
    }
    
    private func formatYAxisValue(_ value: Double, for metric: TrainingMetric) -> String {
        switch metric {
        case .distance:
            return String(format: "%.1f", value)
        case .time:
            let hours = Int(value) / 60
            let minutes = Int(value) % 60
            return "\(hours)h \(minutes)m"
        case .pace:
            let minutes = Int(value)
            let seconds = Int((value - Double(minutes)) * 60)
            return String(format: "%d:%02d", minutes, seconds)
        case .elevation:
            return String(format: "%.0f", value)
        case .intensity:
            switch Int(value) {
            case 1: return "Low"
            case 2: return "Mod"
            case 3: return "High"
            default: return ""
            }
        case .volume:
            let hours = Int(value) / 60
            let minutes = Int(value) % 60
            return "\(hours)h \(minutes)m"
        }
    }
}

struct LegacyChartContent: View {
    let metric: TrainingMetric
    let timeFrame: TimeFrame
    @ObservedObject var dataManager: TrainingDataManager
    
    var body: some View {
        let sessions = dataManager.sessionsForMetric(metric, timeFrame: timeFrame)
        
        if sessions.isEmpty {
            EmptyChartView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    // Background grid
                    VStack(spacing: geometry.size.height / 5) {
                        ForEach(0..<5) { _ in
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                    
                    // Data visualization
                    Path { path in
                        let points = sessions.enumerated().map { index, session -> CGPoint in
                            let x = CGFloat(index) / CGFloat(max(1, sessions.count - 1)) * geometry.size.width
                            let y: CGFloat
                            
                            switch metric {
                            case .distance:
                                if let distance = session.distance {
                                    let maxDistance = sessions.compactMap { $0.distance }.max() ?? 1
                                    y = geometry.size.height - (CGFloat(distance / maxDistance) * geometry.size.height)
                                } else {
                                    y = geometry.size.height / 2
                                }
                            case .time:
                                let maxDuration = sessions.map { $0.duration }.max() ?? 1
                                y = geometry.size.height - (CGFloat(session.duration / maxDuration) * geometry.size.height)
                            case .pace:
                                if let pace = session.pace {
                                    let maxPace = sessions.compactMap { $0.pace }.max() ?? 1
                                    y = geometry.size.height - (CGFloat(pace / maxPace) * geometry.size.height)
                                } else {
                                    y = geometry.size.height / 2
                                }
                            case .elevation:
                                if let elevation = session.elevation {
                                    let maxElevation = sessions.compactMap { $0.elevation }.max() ?? 1
                                    y = geometry.size.height - (CGFloat(elevation / maxElevation) * geometry.size.height)
                                } else {
                                    y = geometry.size.height / 2
                                }
                            case .intensity:
                                let intensityValue = intensityValue(for: session.intensity)
                                let maxIntensity = 3.0
                                y = geometry.size.height - (CGFloat(intensityValue / maxIntensity) * geometry.size.height)
                            case .volume:
                                let maxDuration = sessions.map { $0.duration }.max() ?? 1
                                y = geometry.size.height - (CGFloat(session.duration / maxDuration) * geometry.size.height)
                            }
                            
                            return CGPoint(x: x, y: y)
                        }
                        
                        path.move(to: points[0])
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(Color.red, lineWidth: 2)
                    
                    // Data points - using a different approach
                    DataPointsView(sessions: sessions, metric: metric, geometry: geometry)
                }
            }
            .frame(height: 250)
        }
    }
    
    private func intensityValue(for intensity: TrainingSession.IntensityLevel) -> Double {
        switch intensity {
        case .low:
            return 1.0
        case .moderate:
            return 2.0
        case .high:
            return 3.0
        }
    }
}

// Separate view for data points to avoid buildExpression issues
struct DataPointsView: View {
    let sessions: [TrainingSession]
    let metric: TrainingMetric
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            ForEach(0..<sessions.count, id: \.self) { index in
                let session = sessions[index]
                let x = CGFloat(index) / CGFloat(max(1, sessions.count - 1)) * geometry.size.width
                let y = calculateY(for: session, at: index)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
    }
    
    private func calculateY(for session: TrainingSession, at index: Int) -> CGFloat {
        switch metric {
        case .distance:
            if let distance = session.distance {
                let maxDistance = sessions.compactMap { $0.distance }.max() ?? 1
                return geometry.size.height - (CGFloat(distance / maxDistance) * geometry.size.height)
            } else {
                return geometry.size.height / 2
            }
        case .time:
            let maxDuration = sessions.map { $0.duration }.max() ?? 1
            return geometry.size.height - (CGFloat(session.duration / maxDuration) * geometry.size.height)
        case .pace:
            if let pace = session.pace {
                let maxPace = sessions.compactMap { $0.pace }.max() ?? 1
                return geometry.size.height - (CGFloat(pace / maxPace) * geometry.size.height)
            } else {
                return geometry.size.height / 2
            }
        case .elevation:
            if let elevation = session.elevation {
                let maxElevation = sessions.compactMap { $0.elevation }.max() ?? 1
                return geometry.size.height - (CGFloat(elevation / maxElevation) * geometry.size.height)
            } else {
                return geometry.size.height / 2
            }
        case .intensity:
            let intensityValue = intensityValue(for: session.intensity)
            let maxIntensity = 3.0
            return geometry.size.height - (CGFloat(intensityValue / maxIntensity) * geometry.size.height)
        case .volume:
            let maxDuration = sessions.map { $0.duration }.max() ?? 1
            return geometry.size.height - (CGFloat(session.duration / maxDuration) * geometry.size.height)
        }
    }
    
    private func intensityValue(for intensity: TrainingSession.IntensityLevel) -> Double {
        switch intensity {
        case .low:
            return 1.0
        case .moderate:
            return 2.0
        case .high:
            return 3.0
        }
    }
}

struct EmptyChartView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .padding()
            
            Text("No data available")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Add training sessions to see your progress")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 250)
    }
}

// Extension to help with date formatting
extension TimeFrame {
    var strideBy: Calendar.Component {
        switch self {
        case .week:
            return .day
        case .month:
            return .weekOfMonth
        case .year:
            return .month
        case .allTime:
            return .month
        }
    }
    
    var dateFormat: Date.FormatStyle {
        switch self {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.day()
        case .year:
            return .dateTime.month(.abbreviated)
        case .allTime:
            return .dateTime.month(.abbreviated).year()
        }
    }
} 