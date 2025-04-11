import SwiftUI
import WebKit

struct MoreViewNew: View {
    @State private var selectedTab = 0
    @State private var showingProfile = false
    @State private var showingSavedPrograms = false
    @State private var showingInjuryAnalysis = false
    @State private var showingInjury = false
    @State private var showingProgress = false
    @State private var showingNutritionPlans = false
    @State private var showingAchievements = false
    @State private var showingTrainingHistory = false
    @State private var showingSettings = false
    @State private var showingHelpSupport = false
    @State private var showingPowerOf10 = false
    @State private var showingCoachesCorner = false
    
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
                    
                    // Injury Analysis Section
                    NavigationLink(destination: InjuryAnalysisView()) {
                        MoreOptionCardNew(
                            title: "Injury Analysis".localized,
                            subtitle: "Analyze and track injuries".localized,
                            icon: "bandage.fill",
                            iconColor: .red
                        )
                    }
                    
                    // Injury Section
                    NavigationLink(destination: InjuryView()) {
                        MoreOptionCardNew(
                            title: "Injury".localized,
                            subtitle: "Manage and track injuries".localized,
                            icon: "cross.case.fill",
                            iconColor: .red
                        )
                    }
                    
                    // Profile Section
                    NavigationLink(destination: MoreProfileView()) {
                        MoreOptionCardNew(
                            title: "Profile".localized,
                            subtitle: "View and edit your profile".localized,
                            icon: "person.fill",
                            iconColor: .blue
                        )
                    }
                    
                    // Saved Programs Section
                    NavigationLink(destination: SavedProgramsView()) {
                        MoreOptionCardNew(
                            title: "Saved Programs".localized,
                            subtitle: "Access your saved training programs".localized,
                            icon: "folder.fill",
                            iconColor: .green
                        )
                    }
                    
                    // Coaches Corner Section
                    NavigationLink(destination: CoachesCornerView()) {
                        MoreOptionCardNew(
                            title: "Coaches Corner",
                            subtitle: "Resources and tools for coaches",
                            icon: "person.2.fill",
                            iconColor: .orange
                        )
                    }
                    
                    // Power of 10 Section
                    Button(action: {
                        showingPowerOf10 = true
                    }) {
                        MoreOptionCardNew(
                            title: "The Power of 10",
                            subtitle: "Access UK athletics rankings and statistics",
                            icon: "chart.bar.fill",
                            iconColor: .purple
                        )
                    }
                    
                    // Progress Section
                    NavigationLink(destination: MoreProgressView()) {
                        MoreOptionCardNew(
                            title: "Progress".localized,
                            subtitle: "Track your training progress".localized,
                            icon: "chart.line.uptrend.xyaxis",
                            iconColor: .purple
                        )
                    }
                    
                    // Nutrition Plans Section
                    NavigationLink(destination: MoreNutritionPlansView()) {
                        MoreOptionCardNew(
                            title: "Nutrition Plans".localized,
                            subtitle: "Get personalized nutrition advice".localized,
                            icon: "fork.knife",
                            iconColor: .orange
                        )
                    }
                    
                    // Training History Section
                    NavigationLink(destination: MoreTrainingHistoryView()) {
                        MoreOptionCardNew(
                            title: "Training History".localized,
                            subtitle: "View your past training sessions".localized,
                            icon: "clock.fill",
                            iconColor: .indigo
                        )
                    }
                    
                    // Settings Section
                    NavigationLink(destination: MoreSettingsView()) {
                        MoreOptionCardNew(
                            title: "Settings".localized,
                            subtitle: "Customize app settings".localized,
                            icon: "gear",
                            iconColor: .gray
                        )
                    }
                    
                    // Help & Support Section
                    NavigationLink(destination: MoreHelpSupportView()) {
                        MoreOptionCardNew(
                            title: "Help & Support".localized,
                            subtitle: "Get help and support".localized,
                            icon: "questionmark.circle.fill",
                            iconColor: .teal
                        )
                    }
                    
                    // Achievements Section
                    NavigationLink(destination: MoreAchievementsView()) {
                        MoreOptionCardNew(
                            title: "Achievements".localized,
                            subtitle: "Track your achievements".localized,
                            icon: "trophy.fill",
                            iconColor: .yellow
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black.ignoresSafeArea())
            .overlay {
                if showingPowerOf10 {
                    PowerOf10View()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
    }
}

struct MoreOptionCardNew: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.black)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// Enhanced placeholder views for navigation destinations
struct MoreProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "John Doe"
    @State private var age = "25"
    @State private var sport = "Track & Field"
    @State private var experience = "5 years"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                    TextField("Sport", text: $sport)
                    TextField("Experience", text: $experience)
                }
                
                Section(header: Text("Statistics")) {
                    HStack {
                        Text("Total Workouts")
                        Spacer()
                        Text("124")
                    }
                    
                    HStack {
                        Text("Achievements")
                        Spacer()
                        Text("12")
                    }
                    
                    HStack {
                        Text("Current Streak")
                        Spacer()
                        Text("7 days")
                    }
                }
                
                Section {
                    Button(action: {
                        // Save profile changes
                        dismiss()
                    }) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.black)
    }
}

struct MoreProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeFrame = "Month"
    @State private var selectedMetric = "Distance"
    
    let timeFrames = ["Week", "Month", "Year", "All Time"]
    let metrics = ["Distance", "Duration", "Intensity", "Calories"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Time frame picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(timeFrames, id: \.self) { timeFrame in
                        Text(timeFrame).tag(timeFrame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Metric picker
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(metrics, id: \.self) { metric in
                        Text(metric).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Progress chart
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .cornerRadius(10)
                    
                    VStack {
                        Text("Progress Chart")
                            .font(.headline)
                            .padding(.top)
                        
                        // Placeholder for chart
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(height: 200)
                            .padding()
                            .overlay(
                                Text("Chart showing \(selectedMetric) over \(selectedTimeFrame)")
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding()
                
                // Stats
                HStack(spacing: 20) {
                    StatCard(
                        title: "Total",
                        value: "\(Int.random(in: 100...500))",
                        icon: "chart.bar.fill",
                        color: .red
                    )
                    StatCard(
                        title: "Average",
                        value: "\(Int.random(in: 10...50))",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    )
                    StatCard(
                        title: "Best",
                        value: "\(Int.random(in: 50...100))",
                        icon: "trophy.fill",
                        color: .yellow
                    )
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.black)
    }
}

struct MoreNutritionPlansView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 0
    @State private var showingCustomizationSheet = false
    @State private var showingMealEditor = false
    @State private var selectedMeal: MealType?
    @State private var nutritionTargets = NutritionTargets()
    @State private var mealPlan = MealPlan()
    @State private var showingProgress = false
    @State private var dailyProgress = DailyProgress()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Plan Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Your Plan")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Picker("Nutrition Plan", selection: $selectedPlan) {
                            Text("Performance").tag(0)
                            Text("Recovery").tag(1)
                            Text("Weight Loss").tag(2)
                            Text("Muscle Gain").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedPlan) { oldValue, newValue in
                            updatePlanForSelection(newValue)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    
                    // Daily Targets
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Targets")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingCustomizationSheet = true
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            NutritionTargetCard(
                                title: "Calories",
                                value: nutritionTargets.calories,
                                unit: "kcal",
                                icon: "flame.fill",
                                color: .orange
                            )
                            
                            NutritionTargetCard(
                                title: "Protein",
                                value: nutritionTargets.protein,
                                unit: "g",
                                icon: "figure.walk",
                                color: .red
                            )
                            
                            NutritionTargetCard(
                                title: "Carbs",
                                value: nutritionTargets.carbs,
                                unit: "g",
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            NutritionTargetCard(
                                title: "Fat",
                                value: nutritionTargets.fat,
                                unit: "g",
                                icon: "drop.fill",
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Today's Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                showingProgress = true
                            }) {
                                Text("View Details")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        VStack(spacing: 16) {
                            ProgressBar(
                                title: "Calories",
                                current: dailyProgress.calories,
                                target: nutritionTargets.calories,
                                unit: "kcal",
                                color: .orange
                            )
                            
                            ProgressBar(
                                title: "Protein",
                                current: dailyProgress.protein,
                                target: nutritionTargets.protein,
                                unit: "g",
                                color: .red
                            )
                            
                            ProgressBar(
                                title: "Carbs",
                                current: dailyProgress.carbs,
                                target: nutritionTargets.carbs,
                                unit: "g",
                                color: .green
                            )
                            
                            ProgressBar(
                                title: "Fat",
                                current: dailyProgress.fat,
                                target: nutritionTargets.fat,
                                unit: "g",
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    
                    // Meal Plan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Meal Plan")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 16) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                NutritionMealCard(
                                    meal: mealPlan.meals[mealType] ?? NutritionMeal(name: "", calories: 0, protein: 0, carbs: 0, fat: 0),
                                    mealType: mealType,
                                    onTap: {
                                        selectedMeal = mealType
                                        showingMealEditor = true
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Save the current plan
                        saveCurrentPlan()
                    }) {
                        Text("Save")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingCustomizationSheet) {
                NutritionTargetsEditorView(
                    targets: $nutritionTargets,
                    onSave: { newTargets in
                        nutritionTargets = newTargets
                    }
                )
            }
            .sheet(isPresented: $showingMealEditor) {
                if let mealType = selectedMeal {
                    MealEditorView(
                        meal: Binding(
                            get: { mealPlan.meals[mealType] ?? NutritionMeal(name: "", calories: 0, protein: 0, carbs: 0, fat: 0) },
                            set: { newValue in
                                mealPlan.meals[mealType] = newValue
                            }
                        ),
                        mealType: mealType
                    )
                }
            }
            .sheet(isPresented: $showingProgress) {
                NutritionProgressView(
                    dailyProgress: dailyProgress,
                    targets: nutritionTargets
                )
            }
        }
    }
    
    private func updatePlanForSelection(_ selection: Int) {
        // Update nutrition targets based on selected plan
        switch selection {
        case 0: // Performance
            nutritionTargets = NutritionTargets(calories: 3000, protein: 180, carbs: 375, fat: 100)
        case 1: // Recovery
            nutritionTargets = NutritionTargets(calories: 2800, protein: 200, carbs: 350, fat: 93)
        case 2: // Weight Loss
            nutritionTargets = NutritionTargets(calories: 2200, protein: 165, carbs: 275, fat: 73)
        case 3: // Muscle Gain
            nutritionTargets = NutritionTargets(calories: 3200, protein: 200, carbs: 400, fat: 107)
        default:
            break
        }
        
        // Update meal plan with default meals for the selected plan
        updateMealPlanForSelection(selection)
    }
    
    private func updateMealPlanForSelection(_ selection: Int) {
        // Set default meals based on the selected plan
        switch selection {
        case 0: // Performance
            mealPlan = MealPlan(
                meals: [
                    .breakfast: NutritionMeal(name: "Oatmeal with Berries", calories: 450, protein: 15, carbs: 75, fat: 10),
                    .lunch: NutritionMeal(name: "Grilled Chicken Salad", calories: 550, protein: 40, carbs: 45, fat: 25),
                    .dinner: NutritionMeal(name: "Salmon with Rice", calories: 650, protein: 45, carbs: 65, fat: 30),
                    .snacks: NutritionMeal(name: "Protein Shake & Nuts", calories: 350, protein: 30, carbs: 25, fat: 15)
                ]
            )
        case 1: // Recovery
            mealPlan = MealPlan(
                meals: [
                    .breakfast: NutritionMeal(name: "Protein Pancakes", calories: 500, protein: 35, carbs: 60, fat: 15),
                    .lunch: NutritionMeal(name: "Turkey Wrap", calories: 600, protein: 45, carbs: 55, fat: 25),
                    .dinner: NutritionMeal(name: "Lean Beef with Sweet Potato", calories: 700, protein: 50, carbs: 70, fat: 30),
                    .snacks: NutritionMeal(name: "Greek Yogurt & Fruit", calories: 300, protein: 25, carbs: 30, fat: 10)
                ]
            )
        case 2: // Weight Loss
            mealPlan = MealPlan(
                meals: [
                    .breakfast: NutritionMeal(name: "Egg White Omelette", calories: 300, protein: 25, carbs: 10, fat: 15),
                    .lunch: NutritionMeal(name: "Tuna Salad", calories: 400, protein: 35, carbs: 20, fat: 20),
                    .dinner: NutritionMeal(name: "Grilled Fish with Vegetables", calories: 450, protein: 40, carbs: 25, fat: 20),
                    .snacks: NutritionMeal(name: "Protein Bar", calories: 200, protein: 20, carbs: 15, fat: 8)
                ]
            )
        case 3: // Muscle Gain
            mealPlan = MealPlan(
                meals: [
                    .breakfast: NutritionMeal(name: "Mass Gainer Shake", calories: 800, protein: 50, carbs: 100, fat: 20),
                    .lunch: NutritionMeal(name: "Chicken Rice Bowl", calories: 700, protein: 55, carbs: 80, fat: 25),
                    .dinner: NutritionMeal(name: "Steak with Potatoes", calories: 750, protein: 60, carbs: 70, fat: 30),
                    .snacks: NutritionMeal(name: "Peanut Butter Sandwich", calories: 450, protein: 20, carbs: 45, fat: 25)
                ]
            )
        default:
            break
        }
    }
    
    private func saveCurrentPlan() {
        // In a real app, this would save to a database or user defaults
        print("Saving nutrition plan: \(selectedPlan)")
        print("Targets: \(nutritionTargets)")
        print("Meal Plan: \(mealPlan)")
        
        // Show success message
        // In a real app, this would use a proper notification system
        print("Plan saved successfully!")
    }
}

// MARK: - Supporting Types and Views

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"
}

struct NutritionTargets {
    var calories: Int = 2500
    var protein: Int = 150
    var carbs: Int = 300
    var fat: Int = 80
}

struct NutritionMeal: Identifiable {
    let id = UUID()
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct MealPlan {
    var meals: [MealType: NutritionMeal] = [:]
}

struct DailyProgress {
    var calories: Int = 0
    var protein: Int = 0
    var carbs: Int = 0
    var fat: Int = 0
}

struct NutritionTargetCard: View {
    let title: String
    let value: Int
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(value)")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

struct ProgressBar: View {
    let title: String
    let current: Int
    let target: Int
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(current)/\(target) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(color)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
    }
}

struct NutritionMealCard: View {
    let meal: NutritionMeal
    let mealType: MealType
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealType.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(meal.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        NutritionLabel(value: meal.calories, unit: "kcal")
                        NutritionLabel(value: meal.protein, unit: "P")
                        NutritionLabel(value: meal.carbs, unit: "C")
                        NutritionLabel(value: meal.fat, unit: "F")
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

struct NutritionLabel: View {
    let value: Int
    let unit: String
    
    var body: some View {
        Text("\(value)\(unit)")
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
    }
}

// MARK: - Editor Views

struct NutritionTargetsEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var targets: NutritionTargets
    let onSave: (NutritionTargets) -> Void
    
    @State private var editedTargets: NutritionTargets
    
    init(targets: Binding<NutritionTargets>, onSave: @escaping (NutritionTargets) -> Void) {
        self._targets = targets
        self.onSave = onSave
        self._editedTargets = State(initialValue: targets.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Nutrition Targets")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $editedTargets.calories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("Protein", value: $editedTargets.protein, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("Carbs", value: $editedTargets.carbs, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("Fat", value: $editedTargets.fat, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                }
            }
            .navigationTitle("Edit Targets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(editedTargets)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MealEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var meal: NutritionMeal
    let mealType: MealType
    
    @State private var editedMeal: NutritionMeal
    
    init(meal: Binding<NutritionMeal>, mealType: MealType) {
        self._meal = meal
        self.mealType = mealType
        self._editedMeal = State(initialValue: meal.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Meal Details")) {
                    TextField("Meal Name", text: $editedMeal.name)
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $editedMeal.calories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("Protein", value: $editedMeal.protein, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("Carbs", value: $editedMeal.carbs, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("Fat", value: $editedMeal.fat, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                }
            }
            .navigationTitle("Edit \(mealType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        meal = editedMeal
                        dismiss()
                    }
                }
            }
        }
    }
}

struct NutritionProgressView: View {
    @Environment(\.dismiss) private var dismiss
    let dailyProgress: DailyProgress
    let targets: NutritionTargets
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today's Progress")) {
                    ProgressRow(
                        title: "Calories",
                        current: dailyProgress.calories,
                        target: targets.calories,
                        unit: "kcal",
                        color: .orange
                    )
                    
                    ProgressRow(
                        title: "Protein",
                        current: dailyProgress.protein,
                        target: targets.protein,
                        unit: "g",
                        color: .red
                    )
                    
                    ProgressRow(
                        title: "Carbs",
                        current: dailyProgress.carbs,
                        target: targets.carbs,
                        unit: "g",
                        color: .green
                    )
                    
                    ProgressRow(
                        title: "Fat",
                        current: dailyProgress.fat,
                        target: targets.fat,
                        unit: "g",
                        color: .blue
                    )
                }
                
                Section(header: Text("Tips")) {
                    Text("Track your meals throughout the day to see your progress.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Aim to stay within 10% of your target calories.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Protein is crucial for recovery and muscle maintenance.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Nutrition Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProgressRow: View {
    let title: String
    let current: Int
    let target: Int
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(current)/\(target) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(color)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
        .padding(.vertical, 8)
    }
}

struct MoreTrainingHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter = "All"
    
    let filters = ["All", "This Week", "This Month", "This Year"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Training history list
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(1...10, id: \.self) { _ in
                            TrainingSessionCard(
                                date: getRandomDate(),
                                type: getRandomTrainingType(),
                                duration: "\(Int.random(in: 30...120)) min",
                                intensity: "\(Int.random(in: 1...10))/10"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Training History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.black)
    }
    
    private func getRandomDate() -> String {
        let days = Int.random(in: 1...30)
        return "\(days) days ago"
    }
    
    private func getRandomTrainingType() -> String {
        let types = ["Running", "Strength", "Recovery", "Technique", "Endurance", "Speed"]
        return types.randomElement() ?? "Training"
    }
}

struct TrainingSessionCard: View {
    let date: String
    let type: String
    let duration: String
    let intensity: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(type)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.gray)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(duration)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Intensity")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(intensity)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct MoreSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var darkMode = true
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var showingLogoutAlert = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                AccountSection()
                
                NotificationSection(
                    pushNotifications: $pushNotifications,
                    emailNotifications: $emailNotifications
                )
                
                AppearanceSection(darkMode: $darkMode)
                
                LanguageSection(localizationManager: localizationManager)
                
                AboutSection()
                
                LogoutSection(showingLogoutAlert: $showingLogoutAlert)
            }
            .navigationTitle("Settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done".localized) {
                        dismiss()
                    }
                }
            }
            .alert("Log Out".localized, isPresented: $showingLogoutAlert) {
                Button("Cancel".localized, role: .cancel) { }
                Button("Log Out".localized, role: .destructive) {
                    // Logout action
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to log out?".localized)
            }
        }
    }
}

private struct AccountSection: View {
    var body: some View {
        Section(header: Text("Account".localized)) {
            Button("Change Password".localized) {
                // Change password action
            }
            .foregroundColor(.white)
            
            Button("Privacy Settings".localized) {
                // Privacy settings action
            }
            .foregroundColor(.white)
            
            Button("Terms of Service".localized) {
                // Terms of service action
            }
            .foregroundColor(.white)
            
            Button("Privacy Policy".localized) {
                // Privacy policy action
            }
            .foregroundColor(.white)
        }
    }
}

private struct NotificationSection: View {
    @Binding var pushNotifications: Bool
    @Binding var emailNotifications: Bool
    
    var body: some View {
        Section(header: Text("Notifications".localized)) {
            Toggle("Push Notifications".localized, isOn: $pushNotifications)
            Toggle("Email Notifications".localized, isOn: $emailNotifications)
        }
    }
}

private struct AppearanceSection: View {
    @Binding var darkMode: Bool
    
    var body: some View {
        Section(header: Text("Appearance".localized)) {
            Toggle("Dark Mode".localized, isOn: $darkMode)
        }
    }
}

private struct LanguageSection: View {
    @ObservedObject var localizationManager: LocalizationManager
    
    var body: some View {
        Section(header: Text("Language".localized)) {
            let languages = localizationManager.availableLanguages
            Picker("Language".localized, selection: $localizationManager.currentLanguage) {
                ForEach(languages) { language in
                    Text(language.displayName).tag(language.rawValue)
                }
            }
        }
    }
}

private struct AboutSection: View {
    var body: some View {
        Section(header: Text("About".localized)) {
            HStack {
                Text("Version".localized)
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.gray)
            }
            
            Button("Rate App".localized) {
                // Rate app action
            }
            
            Button("Share App".localized) {
                // Share app action
            }
            
            Button("Contact Us".localized) {
                // Contact us action
            }
        }
    }
}

private struct LogoutSection: View {
    @Binding var showingLogoutAlert: Bool
    
    var body: some View {
        Section {
            Button("Log Out".localized) {
                showingLogoutAlert = true
            }
            .foregroundColor(.red)
        }
    }
}

struct MoreHelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Getting Started", "Training", "Competitions", "Injuries", "Account"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for help", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
                .padding()
                
                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color.black.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Help articles
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(1...10, id: \.self) { _ in
                            HelpArticleCard(
                                title: getRandomHelpTitle(),
                                category: getRandomCategory(),
                                readTime: "\(Int.random(in: 1...5)) min read"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.black)
    }
    
    private func getRandomHelpTitle() -> String {
        let titles = [
            "How to create your first training program",
            "Understanding injury prevention",
            "Nutrition tips for athletes",
            "How to track your progress",
            "Preparing for competitions",
            "Recovery techniques",
            "Setting up your profile",
            "Using the injury analysis tool",
            "Understanding your achievements",
            "Managing your saved programs"
        ]
        return titles.randomElement() ?? "Help Article"
    }
    
    private func getRandomCategory() -> String {
        return categories.randomElement() ?? "All"
    }
}

struct HelpArticleCard: View {
    let title: String
    let category: String
    let readTime: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Text(category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.3))
                    .foregroundColor(.blue)
                    .cornerRadius(5)
                
                Spacer()
                
                Text(readTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct MoreAchievementsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Achievements Coming Soon".localized)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .padding()
            
            Text("Track your progress and earn achievements as you complete training programs.".localized)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationTitle("Achievements".localized)
    }
}

struct MoreViewNew_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoreViewNew()
        }
    }
}

struct PowerOf10View: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            // Web content
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("The Power of 10")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                
                // Web content
                WebView(url: URL(string: "https://www.thepowerof10.info")!)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .background(Color.black)
            .cornerRadius(20)
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct CoachesCornerView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let ukTopCoaches: [Coach] = [
        Coach(name: "Aston Moore MBE", specialty: "Multi-events", achievement: "Lifetime Achievement Award 2024", notableAthletes: "Katarina Johnson-Thompson"),
        Coach(name: "Trevor Painter", specialty: "Middle-distance", achievement: "High Performance Coach of the Year 2024", notableAthletes: "Keely Hodgkinson"),
        Coach(name: "Paul Moseley", specialty: "Para-athletics", achievement: "Great Coaching Moment 2024", notableAthletes: "Hannah Cockroft"),
        Coach(name: "Christian Malcolm", specialty: "Sprints", achievement: "Head Coach British Athletics Olympic Programme", notableAthletes: ""),
        Coach(name: "Steve Cram", specialty: "Middle-distance", achievement: "Former World Record Holder", notableAthletes: "Laura Muir"),
        Coach(name: "Laura Weightman", specialty: "Distance", achievement: "Former Olympian", notableAthletes: "Laura Muir"),
        Coach(name: "Jenny Archer MBE", specialty: "Wheelchair Racing", achievement: "Multiple Paralympic Medals", notableAthletes: "David Weir"),
        Coach(name: "Tony Jarrett", specialty: "Sprint Hurdles", achievement: "GB Sprint Hurdles Development Coach", notableAthletes: ""),
        Coach(name: "Malcolm Arnold OBE", specialty: "Hurdles", achievement: "Legendary Coach", notableAthletes: "Colin Jackson"),
        Coach(name: "Paula Dunn MBE", specialty: "Para-athletics", achievement: "Former Paralympic Head Coach", notableAthletes: ""),
        Coach(name: "Christine Harrison-Bloomfield", specialty: "Leadership", achievement: "UK Sport Female Leadership Program", notableAthletes: ""),
        Coach(name: "Shani Palmer", specialty: "Leadership", achievement: "UK Sport Female Leadership Program", notableAthletes: ""),
        Coach(name: "Coral Nourrice", specialty: "Leadership", achievement: "UK Sport Female Leadership Program", notableAthletes: ""),
        Coach(name: "John Anderson", specialty: "Multi-discipline", achievement: "TV Personality & Coach", notableAthletes: ""),
        Coach(name: "Jamie Bowie", specialty: "Track & Field", achievement: "Scottish Coach", notableAthletes: ""),
        Coach(name: "Jim Bradley", specialty: "Sprinting", achievement: "Renowned Coach", notableAthletes: ""),
        Coach(name: "Andy Coogan", specialty: "Middle-distance", achievement: "Author & Coach", notableAthletes: ""),
        Coach(name: "Bill Foster", specialty: "Endurance", achievement: "Loughborough University Coach", notableAthletes: ""),
        Coach(name: "Alex Currie", specialty: "Sprints & Hurdles", achievement: "Loughborough University Coach", notableAthletes: ""),
        Coach(name: "Matt Ashley", specialty: "High Jump", achievement: "Loughborough University Coach", notableAthletes: ""),
        Coach(name: "Grant Barker", specialty: "Sprints", achievement: "Experienced Coach", notableAthletes: ""),
        Coach(name: "John Davies", specialty: "Sprints", achievement: "Experienced Coach", notableAthletes: ""),
        Coach(name: "Ashley Bryant", specialty: "Multi-events", achievement: "Loughborough University Coach", notableAthletes: ""),
        Coach(name: "Andy Carrott", specialty: "Sprints", achievement: "Former Olympian", notableAthletes: ""),
        Coach(name: "Ailsa Wallace", specialty: "High Jump", achievement: "Oxford University Coach", notableAthletes: ""),
        Coach(name: "Kay Reynolds", specialty: "Sprints & Hurdles", achievement: "Oxford University Coach", notableAthletes: ""),
        Coach(name: "Richard Kilty", specialty: "Sprints", achievement: "Former World Champion", notableAthletes: "Louie Hinchliffe"),
        Coach(name: "Keith Hunter", specialty: "Jumps & Speed", achievement: "European Gold & Para World Bronze Coach", notableAthletes: "European Gold Medalist, Para World Bronze Champion"),
        Coach(name: "Clare Buckle", specialty: "Para Jumps", achievement: "GB Para Jumps Coach", notableAthletes: ""),
        Coach(name: "Leon Baptiste", specialty: "Sprints & Relays", achievement: "Commonwealth Games Gold", notableAthletes: ""),
        Coach(name: "Ryan Freckleton", specialty: "Sprints", achievement: "GB Junior & Senior Coach", notableAthletes: ""),
        Coach(name: "Stefano Cugnetto", specialty: "400m & Relays", achievement: "GB Squad Coach", notableAthletes: ""),
        Coach(name: "Paul Wilson", specialty: "Javelin", achievement: "GB Lead Coach", notableAthletes: ""),
        Coach(name: "Alison O'Riordan", specialty: "Throws", achievement: "GB Para & Able-bodied Coach", notableAthletes: ""),
        Coach(name: "Mike Holmes", specialty: "Combined Events", achievement: "GB Coach", notableAthletes: ""),
        Coach(name: "Zane Duquemin", specialty: "Discus & Shot Put", achievement: "GB Coach", notableAthletes: ""),
        Coach(name: "Tom Craggs", specialty: "Endurance", achievement: "British Endurance Coach", notableAthletes: ""),
        Coach(name: "Charlotte Fisher", specialty: "Marathon", achievement: "GB Marathon Coach", notableAthletes: ""),
        Coach(name: "Andy Bibby", specialty: "Para Endurance", achievement: "National Level Coach", notableAthletes: ""),
        Coach(name: "Jim Edwards", specialty: "Seated Throws", achievement: "GB Specialist Coach", notableAthletes: ""),
        Coach(name: "David Turner", specialty: "Para Throws", achievement: "Former National Coach", notableAthletes: ""),
        Coach(name: "Sam Ruddock", specialty: "Throws", achievement: "Former GB Para Athlete", notableAthletes: ""),
        Coach(name: "Ian Thompson", specialty: "Wheelchair Racing", achievement: "Former GB Coach", notableAthletes: ""),
        Coach(name: "Tanni Grey-Thompson", specialty: "Wheelchair Racing", achievement: "Paralympic Champion", notableAthletes: ""),
        Coach(name: "Benke Blomkvist", specialty: "Sprints & Hurdles", achievement: "Former UKA Coach", notableAthletes: ""),
        Coach(name: "Steve Fudge", specialty: "Sprints", achievement: "Former GB Coach", notableAthletes: ""),
        // New coaches
        Coach(name: "Aston Moore", specialty: "Jumps", achievement: "GB Lead Jumps Coach", notableAthletes: ""),
        Coach(name: "Fuzz Ahmed", specialty: "High Jump", achievement: "GB High Jump Coach", notableAthletes: ""),
        Coach(name: "Scott Simpson", specialty: "Pole Vault", achievement: "GB Pole Vault Coach", notableAthletes: ""),
        Coach(name: "Keith Hunter", specialty: "Jumps & Speed", achievement: "GB Jumps & Speed Coach", notableAthletes: "European Gold Medalist, Para World Champion"),
        Coach(name: "Femi Akinsanya", specialty: "Triple Jump", achievement: "Director of Athletics at Loughborough University", notableAthletes: "Phillips Idowu, Laura Sugar"),
        Coach(name: "Guy Spencer", specialty: "Long & Triple Jump", achievement: "UK-based Horizontal Jumps Coach", notableAthletes: ""),
        Coach(name: "Keith Fleming", specialty: "Long Jump", achievement: "Former GB International", notableAthletes: "Commonwealth Games Gold & Silver Medalists"),
        Coach(name: "Kevin Reeve", specialty: "Horizontal Jumps", achievement: "UKA Level 4 Coach", notableAthletes: "Long Jump Coach at Birchfield Harriers")
    ]
    
    private var heroGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var heroTitleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coaches Corner")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
            
            Text("Resources and tools for coaches")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
    }
    
    private var heroBannerView: some View {
        ZStack(alignment: .bottomLeading) {
            Image("track_hero_banner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                .overlay(heroGradient)
            
            heroTitleView
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    heroBannerView
                    
                    // Content Sections
                    VStack(spacing: 20) {
                        coachesSection
                        featuredResourcesSection
                    }
                    .padding(.top)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black)
        }
    }
    
    private var coachesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("UK Top Coaches")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Recognized for excellence in athletics coaching")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(ukTopCoaches) { coach in
                    CoachCard(coach: coach)
                }
            }
        }
        .padding()
    }
    
    private var featuredResourcesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Resources")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Essential tools and guides for coaches")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ResourceCard(
                        title: "Coaching Fundamentals",
                        description: "Learn the essential principles of athletic coaching and development strategies.",
                        type: "Guide",
                        icon: "book.fill"
                    )
                    
                    ResourceCard(
                        title: "Training Program Builder",
                        description: "Create customized training programs for different age groups and skill levels.",
                        type: "Tool",
                        icon: "square.stack.3d.up.fill"
                    )
                    
                    ResourceCard(
                        title: "Performance Analysis",
                        description: "Advanced techniques for analyzing athlete performance and providing feedback.",
                        type: "Workshop",
                        icon: "chart.bar.fill"
                    )
                    
                    ResourceCard(
                        title: "Injury Prevention",
                        description: "Guidelines for preventing common athletic injuries and promoting safe training.",
                        type: "Guide",
                        icon: "heart.text.square.fill"
                    )
                    
                    ResourceCard(
                        title: "Competition Preparation",
                        description: "Strategies for preparing athletes for competitions at all levels.",
                        type: "Course",
                        icon: "trophy.fill"
                    )
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let specialty: String
    let achievement: String
    let notableAthletes: String
}

struct CoachCard: View {
    let coach: Coach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(coach.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(coach.specialty)
                .font(.subheadline)
                .foregroundColor(.red)
            
            Text(coach.achievement)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            if !coach.notableAthletes.isEmpty {
                Text("Notable Athletes: \(coach.notableAthletes)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ResourceCard: View {
    let title: String
    let description: String
    let type: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.red)
                
                Spacer()
                
                Text(type)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
        }
        .padding()
        .frame(width: 280)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CoachesCornerView_Previews: PreviewProvider {
    static var previews: some View {
        CoachesCornerView()
    }
}

struct AddNewInjuryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var activeInjuries: Int
    @State private var selectedBodyPart = ""
    @State private var injuryType = ""
    @State private var severity = "Mild"
    @State private var date = Date()
    @State private var notes = ""
    
    let severityLevels = ["Mild", "Moderate", "Severe"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Injury Details")) {
                    TextField("Body Part", text: $selectedBodyPart)
                    TextField("Injury Type", text: $injuryType)
                    
                    Picker("Severity", selection: $severity) {
                        ForEach(severityLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Injury")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInjury()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveInjury() {
        activeInjuries += 1
        // Save injury details to storage
    }
} 