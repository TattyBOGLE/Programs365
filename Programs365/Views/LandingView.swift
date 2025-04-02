import SwiftUI

struct ProgramCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.red)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Button(action: {}) {
                Text("Start Training")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

struct LandingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Hero Section
                ZStack {
                    Image("hero-banner")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
                        .clipped()
                        .overlay {
                            LinearGradient(
                                colors: [
                                    .black,
                                    .black.opacity(0.7),
                                    .clear,
                                    .black.opacity(0.4)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Spacer()
                        Text("2026")
                            .font(.system(size: 86, weight: .heavy))
                            .foregroundColor(.red)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        
                        Text("Professional Training Programs For Coaches Who Demand Excellence")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                            .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
                .frame(maxWidth: .infinity)
                
                // Featured Programs Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Featured")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Text("Programs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ProgramCard(
                                title: "Sprints",
                                description: "Master explosive speed and power with our elite sprint training programs",
                                icon: "figure.run"
                            )
                            
                            ProgramCard(
                                title: "Middle Distance",
                                description: "Build the perfect balance of speed and endurance",
                                icon: "figure.walk"
                            )
                            
                            ProgramCard(
                                title: "Long Distance",
                                description: "Develop endurance and mental strength for marathon success",
                                icon: "figure.walk.motion"
                            )
                            
                            ProgramCard(
                                title: "Hurdles",
                                description: "Master technique and rhythm for efficient hurdling",
                                icon: "figure.step.training"
                            )
                            
                            ProgramCard(
                                title: "Jumps",
                                description: "Enhance explosive power and technique for all jumping events",
                                icon: "arrow.up.circle.fill"
                            )
                            
                            ProgramCard(
                                title: "Throws",
                                description: "Build strength and technical mastery for throwing events",
                                icon: "circle.circle.fill"
                            )
                            
                            ProgramCard(
                                title: "Cross Country",
                                description: "Specialized training for varied terrain and conditions",
                                icon: "mountain.2.fill"
                            )
                            
                            ProgramCard(
                                title: "Recovery",
                                description: "Essential protocols to maintain peak performance and prevent injury",
                                icon: "heart.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Stats Section
                HStack(spacing: 16) {
                    StatBox(title: "WORKOUTS", value: "12", subtitle: "This Week")
                    StatBox(title: "HOURS", value: "18.5", subtitle: "Training Time")
                    StatBox(title: "PBs", value: "3", subtitle: "New Records")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.black)
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    LandingView()
} 