import SwiftUI

struct InjuryRehabilitationView: View {
    private let categories = [
        InjuryCategory(
            title: "Sprinting Events",
            icon: "figure.run",
            description: "60m, 100m, 200m, 400m, Hurdles, Relays"
        ),
        InjuryCategory(
            title: "Middle/Long Distance",
            icon: "figure.walk.motion",
            description: "800m to Marathon, Steeplechase, Cross Country"
        ),
        InjuryCategory(
            title: "Jumping Events",
            icon: "arrow.up.circle.fill",
            description: "Long Jump, Triple Jump, High Jump, Pole Vault"
        ),
        InjuryCategory(
            title: "Throwing Events",
            icon: "circle.circle.fill",
            description: "Shot Put, Discus, Javelin, Hammer"
        ),
        InjuryCategory(
            title: "Multi-Events",
            icon: "square.stack.3d.up.fill",
            description: "Heptathlon, Decathlon"
        ),
        InjuryCategory(
            title: "General/Overuse",
            icon: "repeat.circle.fill",
            description: "Common injuries across all events"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Section
                    ZStack(alignment: .bottomLeading) {
                        Image("injury.rehab.hero")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Injury Rehabilitation")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Comprehensive recovery programs for track & field athletes")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Categories Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                        ForEach(categories) { category in
                            NavigationLink(destination: InjuryDetailView()) {
                                InjuryCategoryCard(category: category)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InjuryCategoryCard: View {
    let category: InjuryCategory
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.title)
                .foregroundColor(.red)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(category.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    InjuryRehabilitationView()
} 