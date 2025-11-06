//
//  AuthResponse.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation

// MARK: - Auth Response Models (for Mock API)

struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let user: User?
    let token: String?
    let refreshToken: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct SignUpRequest: Codable {
    let email: String
    let username: String
    let password: String
    let confirmPassword: String
}

struct PasswordResetRequest: Codable {
    let email: String
}

struct UpdateProfileRequest: Codable {
    let displayName: String?
    let bio: String?
    let avatarURL: String?
}

struct ChangePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
    let confirmPassword: String
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case weakPassword
    case invalidEmail
    case passwordMismatch
    case networkError
    case unknown
    case sessionExpired
    case noInternet

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 8 characters"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .passwordMismatch:
            return "Passwords do not match"
        case .networkError:
            return "Network error. Please try again"
        case .unknown:
            return "An unknown error occurred"
        case .sessionExpired:
            return "Your session has expired. Please log in again"
        case .noInternet:
            return "No internet connection"
        }
    }
}
