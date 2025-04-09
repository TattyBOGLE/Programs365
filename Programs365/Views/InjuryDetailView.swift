import SwiftUI
import UIKit

struct InjuryInfo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

struct InjuryDetailView: View {
    let category: InjuryCategory
    @State private var selectedTab = 0
    
    private var injuries: [InjuryInfo] {
        switch category.title {
        case "Sprinting Events":
            return [
                InjuryInfo(name: "Hamstring strain/tear", description: "Common in explosive movements"),
                InjuryInfo(name: "Calf strain", description: "Often occurs during acceleration"),
                InjuryInfo(name: "Achilles tendinopathy", description: "Overuse injury in sprinting"),
                InjuryInfo(name: "Quadriceps strain", description: "Common in sprint acceleration"),
                InjuryInfo(name: "Groin strain", description: "Can occur during explosive movements"),
                InjuryInfo(name: "Lower back pain", description: "Usually muscle-related"),
                InjuryInfo(name: "Shin splints", description: "Medial tibial stress syndrome")
            ]
        case "Middle/Long Distance":
            return [
                InjuryInfo(name: "Runner's knee", description: "Patellofemoral pain syndrome"),
                InjuryInfo(name: "IT band syndrome", description: "Common overuse injury"),
                InjuryInfo(name: "Shin splints", description: "Impact-related injury"),
                InjuryInfo(name: "Stress fractures", description: "Tibia, metatarsals, femur"),
                InjuryInfo(name: "Achilles tendinopathy", description: "Common in distance runners"),
                InjuryInfo(name: "Plantar fasciitis", description: "Heel and arch pain"),
                InjuryInfo(name: "Calf tightness/strain", description: "Common in endurance events"),
                InjuryInfo(name: "Lower back pain", description: "Often from repetitive impact")
            ]
        case "Jumping Events":
            return [
                InjuryInfo(name: "Patellar tendinopathy", description: "Jumper's knee"),
                InjuryInfo(name: "Hamstring strain", description: "Common in take-off phase"),
                InjuryInfo(name: "Groin strain", description: "From explosive movements"),
                InjuryInfo(name: "Ankle sprain", description: "Landing-related injury"),
                InjuryInfo(name: "Achilles tendon issues", description: "Impact-related"),
                InjuryInfo(name: "Back strain", description: "Lumbar region stress"),
                InjuryInfo(name: "Hip flexor strain", description: "Take-off related"),
                InjuryInfo(name: "Gluteal strain", description: "Power generation injury")
            ]
        case "Throwing Events":
            return [
                InjuryInfo(name: "Rotator cuff injuries", description: "Common in all throws"),
                InjuryInfo(name: "Shoulder impingement", description: "Overhead movement stress"),
                InjuryInfo(name: "Elbow tendinopathy", description: "Especially in javelin"),
                InjuryInfo(name: "Wrist sprains", description: "Release-related injuries"),
                InjuryInfo(name: "Back strain", description: "Thoracic/lumbar stress"),
                InjuryInfo(name: "Hip/knee strain", description: "Rotational stress"),
                InjuryInfo(name: "Oblique muscle strains", description: "Rotational movements")
            ]
        case "Multi-Events":
            return [
                InjuryInfo(name: "Hamstring strain", description: "Multiple event risk"),
                InjuryInfo(name: "Ankle sprain", description: "Jump/run related"),
                InjuryInfo(name: "Rotator cuff injuries", description: "Throwing events"),
                InjuryInfo(name: "Shin splints", description: "Impact-related"),
                InjuryInfo(name: "Back pain", description: "Multiple sources"),
                InjuryInfo(name: "Hip/groin issues", description: "Various causes")
            ]
        default: // General/Overuse
            return [
                InjuryInfo(name: "Blisters", description: "Friction-related"),
                InjuryInfo(name: "Tendinitis", description: "Various locations"),
                InjuryInfo(name: "Stress fractures", description: "Overuse injury"),
                InjuryInfo(name: "Muscle tightness", description: "Including DOMS"),
                InjuryInfo(name: "Bursitis", description: "Hip, knee, heel")
            ]
        }
    }
    
    private var causes: [String] {
        switch category.title {
        case "Sprinting Events":
            return [
                "Explosive acceleration",
                "Maximal sprint efforts",
                "Sudden deceleration or poor mechanics",
                "Inadequate warm-up or flexibility"
            ]
        case "Middle/Long Distance":
            return [
                "Repetitive ground impact",
                "Poor footwear or running surfaces",
                "Muscle imbalances",
                "Overtraining or insufficient recovery"
            ]
        case "Jumping Events":
            return [
                "Forceful take-offs and landings",
                "Repetitive jumping",
                "Technique flaws",
                "Poor surface cushioning"
            ]
        case "Throwing Events":
            return [
                "High-velocity arm movements",
                "Rotational forces",
                "Technical errors or overload",
                "Lack of core strength"
            ]
        case "Multi-Events":
            return [
                "High training load across multiple disciplines",
                "Technical overload",
                "Inadequate rest between sessions or events"
            ]
        default: // General/Overuse
            return [
                "Overtraining",
                "Poor technique",
                "Inadequate recovery",
                "Equipment issues",
                "Environmental factors"
            ]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category Header
                HStack {
                    Image(systemName: category.icon)
                        .font(.title)
                        .foregroundColor(.red)
                    
                    Text(category.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Tab Selector
                Picker("", selection: $selectedTab) {
                    Text("Common Injuries").tag(0)
                    Text("Causes").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedTab == 0 {
                    // Injuries List
                    VStack(spacing: 16) {
                        ForEach(injuries) { injury in
                            InjuryRow(injury: injury)
                        }
                    }
                    .padding()
                } else {
                    // Causes List
                    VStack(spacing: 16) {
                        ForEach(causes, id: \.self) { cause in
                            CauseRow(cause: cause)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InjuryRow: View {
    let injury: InjuryInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(injury.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(injury.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct CauseRow: View {
    let cause: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.headline)
            
            Text(cause)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        InjuryDetailView(category: InjuryCategory(title: "Sprinting Events", icon: "figure.run", description: "60m, 100m, 200m, 400m, Hurdles, Relays"))
    }
} 