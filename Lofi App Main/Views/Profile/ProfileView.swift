//
//  ProfileView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var userManager = UserManager.shared
    @State private var showEditProfile = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header with Avatar
                        VStack(spacing: 20) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)

                                if let user = sessionManager.currentUser {
                                    Text(user.initials)
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 20, x: 0, y: 10)

                            // User Info
                            if let user = sessionManager.currentUser {
                                VStack(spacing: 8) {
                                    Text(user.displayUsername)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)

                                    if !user.isGuest {
                                        Text(user.email)
                                            .font(.system(size: 16))
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }

                                    // Subscription Badge
                                    HStack(spacing: 8) {
                                        if user.subscriptionTier == .premium {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 14))
                                        }
                                        Text(user.subscriptionTier.displayName)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(user.subscriptionTier == .premium ? .yellow : AppTheme.Colors.textTertiary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(user.subscriptionTier == .premium ? Color.yellow.opacity(0.2) : AppTheme.Colors.cardLight)
                                    )
                                }

                                if let bio = user.bio, !bio.isEmpty {
                                    Text(bio)
                                        .font(.system(size: 15))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                            }
                        }
                        .padding(.top, 40)

                        // Edit Profile Button
                        if let user = sessionManager.currentUser, !user.isGuest {
                            Button(action: { showEditProfile = true }) {
                                Text("Edit Profile")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal, 24)
                        }

                        // Stats Section (if premium)
                        if sessionManager.isPremium {
                            VStack(spacing: 16) {
                                Text("Your Stats")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HStack(spacing: 16) {
                                    StatCard(title: "Songs Played", value: "127")
                                    StatCard(title: "Hours Listened", value: "42")
                                }

                                HStack(spacing: 16) {
                                    StatCard(title: "Focus Sessions", value: "23")
                                    StatCard(title: "Streak", value: "7 days")
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // Logout Button
                        if let user = sessionManager.currentUser, !user.isGuest {
                            Button(action: { showLogoutConfirmation = true }) {
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.red.opacity(0.1))
                                            )
                                    )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }

                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    AuthenticationManager.shared.logout()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.Colors.cardLight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProfileView()
}
