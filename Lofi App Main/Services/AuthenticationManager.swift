//
//  AuthenticationManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation

class AuthenticationManager {
    static let shared = AuthenticationManager()

    private let sessionManager = SessionManager.shared
    private let keychainManager = KeychainManager.shared

    // Mock user database (in real app, this would be backend)
    private var mockUsers: [String: (password: String, user: User)] = [:]

    private init() {
        // Pre-populate with a test user
        let testUser = User(
            email: "test@lofi.com",
            username: "testuser",
            displayName: "Test User",
            subscriptionTier: .free
        )
        mockUsers["test@lofi.com"] = ("password123", testUser)
    }

    // MARK: - Sign Up
    func signUp(email: String, username: String, password: String, confirmPassword: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Validation
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }

        guard password == confirmPassword else {
            throw AuthError.passwordMismatch
        }

        guard mockUsers[email.lowercased()] == nil else {
            throw AuthError.userAlreadyExists
        }

        // Create new user
        let newUser = User(
            email: email.lowercased(),
            username: username,
            subscriptionTier: .free
        )

        // Save to mock database
        mockUsers[email.lowercased()] = (password, newUser)

        // Generate mock token
        let token = generateMockToken(for: newUser.id)

        // Start session
        sessionManager.startSession(user: newUser, token: token)

        return newUser
    }

    // MARK: - Login
    func login(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Validate
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        // Check credentials
        guard let stored = mockUsers[email.lowercased()],
              stored.password == password else {
            throw AuthError.invalidCredentials
        }

        // Generate mock token
        let token = generateMockToken(for: stored.user.id)

        // Start session
        sessionManager.startSession(user: stored.user, token: token)

        return stored.user
    }

    // MARK: - Logout
    func logout() {
        sessionManager.endSession()
    }

    // MARK: - Guest Login
    func continueAsGuest() {
        sessionManager.startGuestSession()
    }

    // MARK: - Password Reset
    func sendPasswordResetEmail(email: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard mockUsers[email.lowercased()] != nil else {
            // Don't reveal if email exists (security best practice)
            // Just pretend to send email
            return
        }

        // In real app, would send email via backend
        print("📧 Password reset email sent to \(email)")
    }

    // MARK: - Update Profile
    func updateProfile(displayName: String?, bio: String?, avatarURL: String?) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

        guard var user = sessionManager.currentUser else {
            throw AuthError.sessionExpired
        }

        // Update user
        user.displayName = displayName
        user.bio = bio
        user.avatarURL = avatarURL

        // Update in mock database
        if let stored = mockUsers[user.email.lowercased()] {
            mockUsers[user.email.lowercased()] = (stored.password, user)
        }

        // Update session
        sessionManager.updateUser(user)

        return user
    }

    // MARK: - Change Password
    func changePassword(currentPassword: String, newPassword: String, confirmPassword: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        guard let user = sessionManager.currentUser else {
            throw AuthError.sessionExpired
        }

        // Validate current password
        guard let stored = mockUsers[user.email.lowercased()],
              stored.password == currentPassword else {
            throw AuthError.invalidCredentials
        }

        // Validate new password
        guard newPassword.count >= 8 else {
            throw AuthError.weakPassword
        }

        guard newPassword == confirmPassword else {
            throw AuthError.passwordMismatch
        }

        // Update password in mock database
        mockUsers[user.email.lowercased()] = (newPassword, user)
    }

    // MARK: - Delete Account
    func deleteAccount(password: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        guard let user = sessionManager.currentUser else {
            throw AuthError.sessionExpired
        }

        // Validate password
        guard let stored = mockUsers[user.email.lowercased()],
              stored.password == password else {
            throw AuthError.invalidCredentials
        }

        // Delete from mock database
        mockUsers.removeValue(forKey: user.email.lowercased())

        // End session
        sessionManager.endSession()
    }

    // MARK: - Social Login (Mock)
    func signInWithApple() async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Create mock user from Apple
        let appleUser = User(
            email: "apple_\(UUID().uuidString.prefix(8))@privaterelay.appleid.com",
            username: "AppleUser",
            displayName: "Apple User",
            subscriptionTier: .free
        )

        // Generate token
        let token = generateMockToken(for: appleUser.id)

        // Start session
        sessionManager.startSession(user: appleUser, token: token)

        return appleUser
    }

    func signInWithGoogle() async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Create mock user from Google
        let googleUser = User(
            email: "google_\(UUID().uuidString.prefix(8))@gmail.com",
            username: "GoogleUser",
            displayName: "Google User",
            subscriptionTier: .free
        )

        // Generate token
        let token = generateMockToken(for: googleUser.id)

        // Start session
        sessionManager.startSession(user: googleUser, token: token)

        return googleUser
    }

    // MARK: - Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func generateMockToken(for userID: String) -> String {
        // Generate a mock JWT-like token
        let timestamp = Date().timeIntervalSince1970
        return "mock_token_\(userID)_\(timestamp)"
    }

    // MARK: - Session Check
    var isAuthenticated: Bool {
        sessionManager.isAuthenticated
    }

    var currentUser: User? {
        sessionManager.currentUser
    }
}
