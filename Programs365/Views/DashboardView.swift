import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            LandingView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ProgramsView()
                .tabItem {
                    Label("Programs", systemImage: "dumbbell.fill")
                }
            
            CompetitionsView()
                .tabItem {
                    Label("Competitions", systemImage: "trophy.fill")
                }
            
            InjuryView()
                .tabItem {
                    Label("Injury", systemImage: "bandage.fill")
                }
            
            MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
        }
    }
}

#Preview {
    DashboardView()
} 