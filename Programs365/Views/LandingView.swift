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
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Banner
                ZStack(alignment: .leading) {
                    Image("track_hero_banner")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 400)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.7),
                                    Color.black.opacity(0.5)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .bottom, spacing: 0) {
                            Text("Program")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("36")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                                Text("5")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                    .baselineOffset(20)
                            }
                        }
                        
                        Text("Professional Training Programs For Coaches Who Demand Excellence")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 300)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                
                // Featured Section
                VStack(alignment: .leading, spacing: 24) {
                    Text("Featured")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("Programs")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("365")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .baselineOffset(-20)
                    }
                    .padding(.horizontal, 24)
                    
                    // Program Categories Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        // Sprints Card
                        NavigationLink(destination: ProgramsView(initialCategory: "Sprints")) {
                            ProgramCategoryCard(
                                title: "Sprints",
                                description: "Master explosive speed and power with our elite sprint training programs",
                                iconName: "figure.run"
                            )
                        }
                        
                        // Middle Distance Card
                        NavigationLink(destination: ProgramsView(initialCategory: "Middle Distance")) {
                            ProgramCategoryCard(
                                title: "Middle Distance",
                                description: "Build the perfect balance of speed and endurance",
                                iconName: "figure.run"
                            )
                        }
                        
                        // Long Distance Card
                        NavigationLink(destination: ProgramsView(initialCategory: "Long Distance")) {
                            ProgramCategoryCard(
                                title: "Long Distance",
                                description: "Develop endurance and stamina for distance events",
                                iconName: "figure.run"
                            )
                        }
                        
                        // Jumps Card
                        NavigationLink(destination: ProgramsView(initialCategory: "Jumps")) {
                            ProgramCategoryCard(
                                title: "Jumps",
                                description: "Perfect your technique and power for jumping events",
                                iconName: "figure.jumprope"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                
                // Advertisements Section
                VStack(spacing: 0) {
                    // Xplore Disability Ad
                    AdCard(
                        title: "Xplore Disability",
                        description: "Join our inclusive athletics program",
                        imageName: "xplore.disability",
                        backgroundColor: .blue
                    ) {}
                    
                    // Sale Harriers Ad
                    AdCard(
                        title: "Sale Harriers",
                        description: "Elite training programs for aspiring athletes",
                        imageName: "sale.harriers",
                        backgroundColor: .red
                    ) {}
                    
                    // Active Life Ad
                    AdCard(
                        title: "Active Life",
                        description: "Professional sports medicine and rehabilitation",
                        imageName: "active.life",
                        backgroundColor: .green
                    ) {}
                }
                .padding(.top, 16)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

struct ProgramCategoryCard: View {
    let title: String
    let description: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.red)
                .padding(.bottom, 4)
            
            // Title
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Description
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Spacer()
            
            // Start Training Button
            HStack {
                Text("Start Training")
                    .foregroundColor(.red)
                Image(systemName: "chevron.right")
                    .foregroundColor(.red)
            }
            .font(.subheadline)
            .padding(.top, 8)
        }
        .padding(20)
        .frame(height: 200)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
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

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LandingView()
        }
    }
} 