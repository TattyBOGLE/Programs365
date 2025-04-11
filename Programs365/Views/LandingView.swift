import SwiftUI
import UIKit

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct LandingProgramCard: View {
    let title: String
    let description: String
    let icon: String
    @State private var navigateToPrograms = false
    
    var body: some View {
        NavigationLink(destination: ProgramsView(initialCategory: title)) {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.red)
                    .frame(height: 32)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Text("Start Training".localized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(20)
            .frame(width: 180)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
        }
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

// AdCard View Component
struct AdCard: View {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
    let action: () -> Void
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // Background Image or Placeholder
                Group {
                    if UIImage(named: imageName) != nil {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image(systemName: getPlaceholderIcon())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(40)
                            .foregroundColor(.black)
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                    }
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: getGradientColors()),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Title and Description
                VStack(alignment: .leading, spacing: 16) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                    
                    Button(action: handleAction) {
                        Text("Learn More")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 24)
            }
        }
        .background(Color.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func getGradientColors() -> [Color] {
        switch imageName {
        case "xplore.disability":
            return [.clear, .black.opacity(0.8), .black.opacity(0.9)]
        case "sale.harriers":
            // Lighter gradient for the bright high jump image
            return [.clear, .black.opacity(0.5), .black.opacity(0.7)]
        case "active.life":
            // Balanced gradient for the bright clinical setting
            return [.clear, .black.opacity(0.6), .black.opacity(0.85)]
        default:
            return [.clear, .black.opacity(0.6), .black.opacity(0.8)]
        }
    }
    
    private func handleAction() {
        switch imageName {
        case "xplore.disability":
            if let url = URL(string: "https://parasport.org.uk") {
                openURL(url)
            }
        case "sale.harriers":
            if let url = URL(string: "https://www.saleharriersmanchester.com") {
                openURL(url)
            }
        case "active.life":
            if let url = URL(string: "https://www.activelifeelites.co.uk") {
                openURL(url)
            }
        default:
            action()
        }
    }
    
    private func getPlaceholderIcon() -> String {
        switch imageName {
        case "xplore.disability":
            return "figure.roll"
        case "sale.harriers":
            return "figure.run"
        case "active.life":
            return "heart.text.square"
        default:
            return "photo"
        }
    }
}

struct LandingView: View {
    @State private var navigateToPrograms = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("England Athletics")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Welcome to Track&field365".localized)
                                .font(.system(size: 40, weight: .heavy))
                                .foregroundColor(.white)
                            
                            Text("Your personalized training companion".localized)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    // Featured Categories
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Featured Categories".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                LandingProgramCard(
                                    title: "Track Events".localized,
                                    description: "Sprints, middle distance, and long distance training programs".localized,
                                    icon: "figure.run"
                                )
                                
                                LandingProgramCard(
                                    title: "Field Events".localized,
                                    description: "Jumping and throwing events training programs".localized,
                                    icon: "figure.disc.sports"
                                )
                                
                                LandingProgramCard(
                                    title: "Para Athletics".localized,
                                    description: "Specialized programs for para-athletes".localized,
                                    icon: "figure.roll"
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    
                    // Our Partners Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Our Partners")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    // Advertisements
                    VStack(spacing: 0) {
                        AdCard(
                            title: "Xplore Disability".localized,
                            description: "Join our inclusive athletics program".localized,
                            imageName: "xplore.disability",
                            backgroundColor: .blue
                        ) {}
                        
                        AdCard(
                            title: "Sale Harriers".localized,
                            description: "Elite training programs for aspiring athletes".localized,
                            imageName: "sale.harriers",
                            backgroundColor: .red
                        ) {}
                        
                        AdCard(
                            title: "Active Life".localized,
                            description: "Professional sports medicine and rehabilitation".localized,
                            imageName: "active.life",
                            backgroundColor: .green
                        ) {}
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

struct ProgramCard: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var navigateToPrograms: Bool
    
    var body: some View {
        Button(action: {
            navigateToPrograms = true
        }) {
            VStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Start Training".localized)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(color)
                    .cornerRadius(20)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
        }
    }
}

// Partner Logo Component
struct PartnerLogo: View {
    let imageName: String
    let name: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            
            Text(name)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    LandingView()
} 