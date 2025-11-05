//
//  LoadingView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.cardMedium, lineWidth: 3)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(AppTheme.Colors.primary, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }

            Text("Loading...")
                .font(AppTheme.Typography.callout())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?

    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(message)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("Try Again")
                        .font(AppTheme.Typography.body(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .fill(AppTheme.Colors.primary)
                        )
                }
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text(title)
                .font(AppTheme.Typography.title())
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(description)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTheme.Typography.body(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .fill(AppTheme.Colors.primary)
                        )
                }
                .padding(.top, AppTheme.Spacing.md)
            }
        }
        .padding(AppTheme.Spacing.xxl)
    }
}

#Preview("Loading") {
    ZStack {
        AppTheme.Gradients.background
            .ignoresSafeArea()

        LoadingView()
    }
}

#Preview("Error") {
    ZStack {
        AppTheme.Gradients.background
            .ignoresSafeArea()

        ErrorView(message: "Failed to load tracks. Please check your internet connection.") {
            print("Retry tapped")
        }
    }
}

#Preview("Empty State") {
    ZStack {
        AppTheme.Gradients.background
            .ignoresSafeArea()

        EmptyStateView(
            icon: "music.note.list",
            title: "No Tracks Yet",
            description: "Start exploring lofi beats to build your playlist",
            actionTitle: "Browse Music",
            action: {
                print("Browse tapped")
            }
        )
    }
}
