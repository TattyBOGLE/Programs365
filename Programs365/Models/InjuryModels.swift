import SwiftUI

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: String
    let description: String
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)
            
            Text(exercise.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Label("\(exercise.sets) sets", systemImage: "number.circle.fill")
                Spacer()
                Label(exercise.reps, systemImage: "repeat.circle.fill")
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
} 