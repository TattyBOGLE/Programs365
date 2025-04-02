//
//  Programs365App.swift
//  Programs365
//
//  Created by keith hunter on 02/04/2025.
//

import SwiftUI

@main
struct Programs365App: App {
    init() {
        // Set dark mode as default
        UIWindow.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(.dark)
        }
    }
}
