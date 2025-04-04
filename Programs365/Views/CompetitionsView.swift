import SwiftUI

struct CompetitionsView: View {
    @State private var selectedDate = Date()
    @State private var showingAddCompetition = false
    @State private var competitions: [Competition] = []
    @State private var newCompetitionName = ""
    @State private var newCompetitionDate = Date()
    @State private var newAthletes: [String] = []
    @State private var newAthleteName = ""
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
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
                            Text("Competitions")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                            
                            Text("Track and Field Events")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                        }
                        .padding(.bottom, 30)
                    }
                    .frame(height: 300)
                    
                    // Calendar and Competitions
                    ScrollView {
                        VStack(spacing: 20) {
                            // Calendar
                            VStack(spacing: 15) {
                                HStack {
                                    Button(action: previousMonth) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(monthFormatter.string(from: selectedDate))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Button(action: nextMonth) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Weekday headers
                                HStack {
                                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                        Text(day)
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                // Calendar grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                                    ForEach(daysInMonth(), id: \.self) { date in
                                        if let date = date {
                                            DayCell(
                                                date: date,
                                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                                hasCompetition: hasCompetition(on: date)
                                            )
                                            .onTapGesture {
                                                selectedDate = date
                                            }
                                        } else {
                                            Color.clear
                                                .aspectRatio(1, contentMode: .fill)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(white: 0.15)) // Slightly lighter black for calendar
                            .cornerRadius(15)
                            
                            // Competitions for selected date
                            if let competitionsForDate = competitionsForDate(selectedDate) {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Competitions for \(dateFormatter.string(from: selectedDate))")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ForEach(competitionsForDate) { competition in
                                        CompetitionCard(competition: competition)
                                    }
                                }
                                .padding()
                                .background(Color(white: 0.15)) // Slightly lighter black for cards
                                .cornerRadius(15)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: { showingAddCompetition = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            })
            .sheet(isPresented: $showingAddCompetition) {
                AddCompetitionView(
                    isPresented: $showingAddCompetition,
                    competitions: $competitions,
                    selectedDate: selectedDate
                )
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = DateInterval(start: startOfMonth(), end: endOfMonth())
        let days = calendar.generateDates(inside: interval, matching: DateComponents(hour: 0, minute: 0, second: 0))
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth())
        let leadingSpaces = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        return leadingSpaces + days.map { Optional($0) }
    }
    
    private func startOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        return calendar.date(from: components) ?? selectedDate
    }
    
    private func endOfMonth() -> Date {
        let components = DateComponents(month: 1, day: -1)
        return calendar.date(byAdding: components, to: startOfMonth()) ?? selectedDate
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func hasCompetition(on date: Date) -> Bool {
        competitions.contains { competition in
            calendar.isDate(competition.date, inSameDayAs: date)
        }
    }
    
    private func competitionsForDate(_ date: Date) -> [Competition]? {
        let competitionsForDate = competitions.filter { competition in
            calendar.isDate(competition.date, inSameDayAs: date)
        }
        return competitionsForDate.isEmpty ? nil : competitionsForDate
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasCompetition: Bool
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        Text(dateFormatter.string(from: date))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(textColor)
            .overlay(
                Circle()
                    .fill(hasCompetition ? Color.red : Color.clear)
                    .frame(width: 8, height: 8)
                    .offset(y: 12)
            )
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.white.opacity(0.3)
        }
        return Color.clear
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        }
        return .white.opacity(0.8)
    }
}

struct CompetitionCard: View {
    let competition: Competition
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(competition.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(dateFormatter.string(from: competition.date))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(competition.location)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.2)) // Slightly lighter black for individual cards
        .cornerRadius(10)
    }
}

struct AddCompetitionView: View {
    @Binding var isPresented: Bool
    @Binding var competitions: [Competition]
    let selectedDate: Date
    
    @State private var competitionTitle = ""
    @State private var competitionDate: Date
    @State private var competitionLocation = ""
    
    init(isPresented: Binding<Bool>, competitions: Binding<[Competition]>, selectedDate: Date) {
        _isPresented = isPresented
        _competitions = competitions
        self.selectedDate = selectedDate
        _competitionDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Competition Details")) {
                    TextField("Competition Title", text: $competitionTitle)
                    DatePicker("Date", selection: $competitionDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("Location", text: $competitionLocation)
                }
            }
            .navigationTitle("Add Competition")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveCompetition()
                }
                .disabled(competitionTitle.isEmpty || competitionLocation.isEmpty)
            )
        }
    }
    
    private func saveCompetition() {
        let competition = Competition(
            title: competitionTitle,
            date: competitionDate,
            location: competitionLocation
        )
        competitions.append(competition)
        isPresented = false
    }
}

extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

#Preview {
    CompetitionsView()
} 