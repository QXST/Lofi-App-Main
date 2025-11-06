//
//  EditProfileView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var userManager = UserManager.shared

    @State private var displayName = ""
    @State private var bio = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    enum Field {
        case displayName, bio
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Avatar Section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)

                                if let user = sessionManager.currentUser {
                                    Text(user.initials)
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                }

                                // Camera icon overlay
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(AppTheme.Colors.primary)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white)
                                            )
                                            .offset(x: -5, y: -5)
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }

                            Text("Change Photo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                        .padding(.top, 40)

                        // Form Fields
                        VStack(spacing: 20) {
                            // Display Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                TextField("", text: $displayName)
                                    .placeholder(when: displayName.isEmpty) {
                                        Text("Enter your display name")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                    .focused($focusedField, equals: .displayName)
                                    .padding()
                                    .background(AppTheme.Colors.cardLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .displayName ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                    )
                            }

                            // Bio
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                ZStack(alignment: .topLeading) {
                                    if bio.isEmpty {
                                        Text("Tell us about yourself...")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                            .padding()
                                    }

                                    TextEditor(text: $bio)
                                        .focused($focusedField, equals: .bio)
                                        .scrollContentBackground(.hidden)
                                        .padding(8)
                                        .frame(height: 100)
                                }
                                .background(AppTheme.Colors.cardLight)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .bio ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                )

                                Text("\(bio.count)/150")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }

                            // Email (Read-only)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                Text(sessionManager.currentUser?.email ?? "")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(AppTheme.Colors.cardLight.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 24)

                        // Error/Success Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }

                        if showSuccess {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Profile updated successfully!")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 24)
                        }

                        // Save Button
                        Button(action: saveProfile) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Save Changes")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.6 : 1.0)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .onAppear {
                loadUserData()
            }
        }
    }

    // MARK: - Actions
    private func loadUserData() {
        guard let user = sessionManager.currentUser else { return }
        displayName = user.displayName ?? user.username
        bio = user.bio ?? ""
    }

    private func saveProfile() {
        errorMessage = nil
        showSuccess = false
        isLoading = true
        focusedField = nil

        // Validate bio length
        if bio.count > 150 {
            errorMessage = "Bio must be 150 characters or less"
            isLoading = false
            return
        }

        Task {
            do {
                try await userManager.updateProfile(
                    displayName: displayName.isEmpty ? nil : displayName,
                    bio: bio.isEmpty ? nil : bio,
                    avatarURL: nil
                )

                await MainActor.run {
                    isLoading = false
                    showSuccess = true

                    // Auto dismiss after 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
