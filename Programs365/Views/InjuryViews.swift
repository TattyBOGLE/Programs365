import SwiftUI

struct InjuryAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBodyPart: String?
    @State private var showingInjuryDetail = false
    @State private var selectedTab = 0
    @State private var showingCamera = false
    @State private var selectedImage: UIImage?
    @State private var painLevel: Double = 5
    @State private var symptoms: String = ""
    @State private var showingDisclaimer = true
    
    let bodyParts = [
        ("Head & Neck", "person.crop.circle"),
        ("Shoulders", "person.crop.rectangle"),
        ("Arms", "figure.boxing"),
        ("Chest", "heart.fill"),
        ("Back", "figure.walk"),
        ("Hips", "figure.stand"),
        ("Legs", "figure.run"),
        ("Feet", "shoe.fill")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    ZStack(alignment: .bottomLeading) {
                        Image("injury_hero")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Injury Analysis")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Track and analyze your injuries")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Quick Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Active Injuries",
                            value: "2",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Recovered",
                            value: "5",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Total Tracked",
                            value: "7",
                            icon: "chart.bar.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    
                    // Body Parts Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Area of Concern")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(bodyParts, id: \.0) { part in
                                BodyPartCard(
                                    title: part.0,
                                    icon: part.1,
                                    isSelected: selectedBodyPart == part.0,
                                    action: { selectedBodyPart = part.0 }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Injuries
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Injuries")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                InjuryCard(
                                    title: "Knee Strain",
                                    date: "2 days ago",
                                    status: "Active",
                                    severity: "Moderate"
                                )
                                
                                InjuryCard(
                                    title: "Ankle Sprain",
                                    date: "1 week ago",
                                    status: "Recovered",
                                    severity: "Mild"
                                )
                                
                                InjuryCard(
                                    title: "Shoulder Pain",
                                    date: "2 weeks ago",
                                    status: "Recovered",
                                    severity: "Moderate"
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // New Injury Form
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Report New Injury")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            // Pain Level
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pain Level")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Text("1")
                                        .foregroundColor(.gray)
                                    Slider(value: $painLevel, in: 1...10, step: 1)
                                        .accentColor(.red)
                                    Text("10")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Symptoms
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Symptoms")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $symptoms)
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            // Image Upload
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Add Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 12) {
                                    Button(action: { 
                                        showingCamera = true
                                    }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                            Text("Take Photo")
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(12)
                                    }
                                    
                                    if selectedImage != nil {
                                        Button(action: { selectedImage = nil }) {
                                            HStack {
                                                Image(systemName: "trash.fill")
                                                Text("Remove")
                                            }
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.gray)
                                            .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                            
                            // Submit Button
                            Button(action: {
                                // Handle injury submission
                                showingInjuryDetail = true
                            }) {
                                Text("Submit Injury Report")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(symptoms.isEmpty ? Color.gray : Color.red)
                                    .cornerRadius(12)
                            }
                            .disabled(symptoms.isEmpty)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Injury Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingInjuryDetail) {
                InjuryDetailView()
            }
            .alert("Medical Disclaimer", isPresented: $showingDisclaimer) {
                Button("I Understand", role: .cancel) { }
            } message: {
                Text("This injury analysis tool uses AI to provide general guidance and should NOT be considered as professional medical advice. Always consult with a qualified healthcare provider for proper diagnosis and treatment.")
            }
        }
    }
}

// Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct BodyPartCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .red)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.red : Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct InjuryCard: View {
    let title: String
    let date: String
    let status: String
    let severity: String
    
    var statusColor: Color {
        status == "Active" ? .red : .green
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Label(status, systemImage: "circle.fill")
                    .font(.caption)
                    .foregroundColor(statusColor)
                
                Spacer()
                
                Text("Severity: \(severity)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
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

struct InjuryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSeverity = "Mild"
    @State private var injuryDate = Date()
    @State private var notes = ""
    @State private var showingRecoveryExercises = false
    @State private var showingProgressTracking = false
    
    let severityLevels = ["Mild", "Moderate", "Severe"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Injury Details")) {
                    Text("Hamstring Strain")
                        .font(.headline)
                    
                    Picker("Severity", selection: $selectedSeverity) {
                        ForEach(severityLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    DatePicker("Date", selection: $injuryDate, displayedComponents: .date)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section(header: Text("Recovery Plan")) {
                    Button(action: {
                        showingRecoveryExercises = true
                    }) {
                        HStack {
                            Text("View Recommended Exercises")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        showingProgressTracking = true
                    }) {
                        HStack {
                            Text("Track Progress")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Injury Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save injury details
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingRecoveryExercises) {
                RecoveryExercisesView(bodyPart: "Hamstring Strain")
            }
            .sheet(isPresented: $showingProgressTracking) {
                ProgressTrackingView()
            }
        }
    }
}

struct RecoveryExercisesView: View {
    let bodyPart: String
    
    var body: some View {
        NavigationView {
            List {
                ForEach(getExercises(), id: \.id) { exercise in
                    ExerciseRow(exercise: exercise)
                }
            }
            .navigationTitle("Recovery Exercises")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getExercises() -> [Exercise] {
        // Return exercises based on body part
        switch bodyPart {
        case "Head & Neck":
            return [
                Exercise(name: "Neck Stretches", sets: 3, reps: "10-15", description: "Gentle neck rotations and tilts"),
                Exercise(name: "Shoulder Rolls", sets: 3, reps: "10-15", description: "Roll shoulders forward and backward")
            ]
        case "Shoulders":
            return [
                Exercise(name: "Pendulum Swings", sets: 3, reps: "10-15", description: "Gentle arm swings while leaning forward"),
                Exercise(name: "Wall Push-ups", sets: 3, reps: "10-15", description: "Push-ups against a wall")
            ]
        case "Arms":
            return [
                Exercise(name: "Wrist Flexor Stretch", sets: 3, reps: "30s", description: "Stretch wrist flexors"),
                Exercise(name: "Bicep Curls", sets: 3, reps: "10-12", description: "Light weight bicep curls")
            ]
        case "Chest":
            return [
                Exercise(name: "Doorway Stretch", sets: 3, reps: "30s", description: "Stretch chest muscles in doorway"),
                Exercise(name: "Foam Roller", sets: 3, reps: "30s", description: "Roll chest muscles with foam roller")
            ]
        case "Back":
            return [
                Exercise(name: "Cat-Cow Stretch", sets: 3, reps: "10-15", description: "Alternate between arching and rounding back"),
                Exercise(name: "Child's Pose", sets: 3, reps: "30s", description: "Stretch back muscles")
            ]
        case "Hips":
            return [
                Exercise(name: "Hip Flexor Stretch", sets: 3, reps: "30s", description: "Stretch hip flexors"),
                Exercise(name: "Clamshells", sets: 3, reps: "10-15", description: "Side-lying hip exercise")
            ]
        case "Legs":
            return [
                Exercise(name: "Quad Stretch", sets: 3, reps: "30s", description: "Stretch quadriceps"),
                Exercise(name: "Hamstring Stretch", sets: 3, reps: "30s", description: "Stretch hamstrings")
            ]
        case "Feet":
            return [
                Exercise(name: "Toe Curls", sets: 3, reps: "10-15", description: "Curl toes with towel"),
                Exercise(name: "Calf Stretch", sets: 3, reps: "30s", description: "Stretch calf muscles")
            ]
        default:
            return []
        }
    }
}

struct ProgressTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var painLevel = 3
    @State private var mobility = 4
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Check-in")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pain Level (1-10)")
                            .font(.subheadline)
                        
                        Slider(value: .init(get: { Double(painLevel) },
                                          set: { painLevel = Int($0) }),
                               in: 1...10,
                               step: 1)
                        
                        Text("Current: \(painLevel)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobility (1-10)")
                            .font(.subheadline)
                        
                        Slider(value: .init(get: { Double(mobility) },
                                          set: { mobility = Int($0) }),
                               in: 1...10,
                               step: 1)
                        
                        Text("Current: \(mobility)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Progress") {
                        // Save progress
                        dismiss()
                    }
                }
            }
            .navigationTitle("Track Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InjuryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InjuryDetailView()
        }
        .preferredColorScheme(.dark)
    }
} 