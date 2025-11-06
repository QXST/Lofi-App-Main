//
//  SessionManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()

    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isGuest: Bool = false
    @Published var isLoading: Bool = true

    private let keychainManager = KeychainManager.shared
    private let userDefaultsKey = "com.lofiapp.currentUser"

    private init() {
        loadSession()
    }

    // MARK: - Session Management
    func loadSession() {
        isLoading = true

        // Try to load user from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            // Check if we have a valid token
            if let token = keychainManager.retrieveAuthToken() {
                // Validate token (in real app, would verify with backend)
                if isTokenValid(token) {
                    currentUser = user
                    isAuthenticated = !user.isGuest
                    isGuest = user.isGuest
                    isLoading = false
                    return
                }
            }
        }

        // No valid session found
        currentUser = nil
        isAuthenticated = false
        isGuest = false
        isLoading = false
    }

    func startSession(user: User, token: String?, refreshToken: String? = nil) {
        // Save user to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }

        // Save tokens to Keychain
        if let token = token {
            _ = keychainManager.saveAuthToken(token)
        }
        if let refreshToken = refreshToken {
            _ = keychainManager.saveRefreshToken(refreshToken)
        }
        _ = keychainManager.saveUserID(user.id)

        // Update state
        currentUser = user
        isAuthenticated = !user.isGuest
        isGuest = user.isGuest
    }

    func startGuestSession() {
        let guestUser = User.guestUser()
        startSession(user: guestUser, token: nil)
    }

    func endSession() {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)

        // Clear Keychain
        keychainManager.clearAuthData()

        // Update state
        currentUser = nil
        isAuthenticated = false
        isGuest = false
    }

    func updateUser(_ user: User) {
        // Update stored user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }

        // Update state
        currentUser = user
    }

    func upgradeFromGuest(user: User, token: String) {
        // Replace guest session with authenticated session
        endSession()
        startSession(user: user, token: token)
    }

    // MARK: - Subscription Helpers
    var isPremium: Bool {
        currentUser?.subscriptionTier == .premium
    }

    func upgradeToPremium() {
        guard var user = currentUser else { return }
        user.subscriptionTier = .premium
        updateUser(user)
    }

    func downgradeToFree() {
        guard var user = currentUser else { return }
        user.subscriptionTier = .free
        updateUser(user)
    }

    // MARK: - Token Validation
    private func isTokenValid(_ token: String) -> Bool {
        // Mock validation - in real app, would check expiration, signature, etc.
        // For now, just check if token exists and is not empty
        return !token.isEmpty
    }

    // MARK: - Helpers
    var userID: String? {
        currentUser?.id
    }

    var isLoggedIn: Bool {
        isAuthenticated && !isGuest
    }
}
