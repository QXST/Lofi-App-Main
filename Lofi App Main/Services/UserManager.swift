//
//  UserManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var currentUser: User?
    private let sessionManager = SessionManager.shared
    private let authManager = AuthenticationManager.shared

    private init() {
        // Observe session changes
        currentUser = sessionManager.currentUser
    }

    // MARK: - Profile Updates
    func updateProfile(displayName: String?, bio: String?, avatarURL: String?) async throws {
        do {
            let updatedUser = try await authManager.updateProfile(
                displayName: displayName,
                bio: bio,
                avatarURL: avatarURL
            )
            await MainActor.run {
                currentUser = updatedUser
            }
        } catch {
            throw error
        }
    }

    // MARK: - Avatar Management
    func updateAvatar(url: String) async throws {
        try await updateProfile(
            displayName: currentUser?.displayName,
            bio: currentUser?.bio,
            avatarURL: url
        )
    }

    // MARK: - Change Password
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async throws {
        try await authManager.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
    }

    // MARK: - Delete Account
    func deleteAccount(password: String) async throws {
        try await authManager.deleteAccount(password: password)
    }

    // MARK: - Refresh User Data
    func refreshUserData() {
        currentUser = sessionManager.currentUser
    }
}
