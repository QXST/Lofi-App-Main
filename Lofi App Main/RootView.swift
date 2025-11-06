//
//  RootView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        Group {
            if sessionManager.isLoading {
                // Loading screen
                ZStack {
                    AppTheme.Gradients.background(for: themeManager.colorScheme)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        // Animated cloud logo
                        AnimatedCloudView(imageURL: nil)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        ProgressView()
                            .tint(AppTheme.Colors.primary)
                    }
                }
            } else if sessionManager.isAuthenticated || sessionManager.isGuest {
                // Main app
                ContentView()
                    .environmentObject(themeManager)
            } else {
                // Welcome/Auth screen
                WelcomeView()
                    .environmentObject(themeManager)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .animation(.easeInOut(duration: 0.3), value: sessionManager.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: sessionManager.isLoading)
        .animation(.easeInOut(duration: 0.3), value: themeManager.isDarkMode)
    }
}

#Preview {
    RootView()
}
