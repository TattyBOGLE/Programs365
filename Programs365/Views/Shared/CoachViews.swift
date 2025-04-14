import SwiftUI

struct CoachCard: View {
    let coach: Coach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(coach.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coach.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(coach.specialization)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(15)
    }
}

struct CoachDetailView: View {
    let coach: Coach
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(coach.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .padding(.top)
                    
                    Text(coach.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(coach.specialization)
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(coach.location)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(coach.bio)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            }
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

struct CoachesCornerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoach: Coach?
    @State private var showingCoachDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 20) {
                    ForEach(Coach.allCoaches) { coach in
                        Button(action: {
                            selectedCoach = coach
                            showingCoachDetail = true
                        }) {
                            CoachCard(coach: coach)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Coaches Corner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCoachDetail) {
                if let coach = selectedCoach {
                    CoachDetailView(coach: coach)
                }
            }
        }
    }
} 