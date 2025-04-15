import SwiftUI
import UIKit

struct DashboardView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    private let chatGPTService = ChatGPTService(apiKey: AppConfig.API.chatGPTApiKey)
    
    init() {
        // Modify tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black
        
        // Configure the tab bar item appearance for both normal and selected states
        let itemAppearance = UITabBarItemAppearance()
        
        // Normal state
        itemAppearance.normal.iconColor = .gray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // Selected state
        itemAppearance.selected.iconColor = .white
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Apply the item appearance to all tab bar item states
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Ensure tab bar is not hidden
        UITabBar.appearance().isHidden = false
    }
    
    var body: some View {
        TabView {
            LandingView()
                .tabItem {
                    Label("Home".localized, systemImage: "house.fill")
                }
            
            ProgramsView()
                .tabItem {
                    Label("Programs".localized, systemImage: "dumbbell.fill")
                }
            
            CompetitionsView()
                .tabItem {
                    Label("Competitions".localized, systemImage: "trophy.fill")
                }
            
            ParaAthletesView(chatGPTService: chatGPTService)
                .tabItem {
                    Label("Para".localized, systemImage: "figure.roll")
                }
            
            MoreViewNew()
                .tabItem {
                    Label("More".localized, systemImage: "ellipsis")
                }
        }
        .tint(.red)  // Make the selected tab items red to match the app's theme
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force view refresh when language changes
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.view.setNeedsLayout()
            }
        }
    }
}

#Preview {
    DashboardView()
} 