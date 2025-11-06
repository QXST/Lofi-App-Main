//
//  User.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    var email: String
    var username: String
    var displayName: String?
    var bio: String?
    var avatarURL: String?
    var subscriptionTier: SubscriptionTier
    var createdAt: Date
    var isGuest: Bool

    init(
        id: String = UUID().uuidString,
        email: String,
        username: String,
        displayName: String? = nil,
        bio: String? = nil,
        avatarURL: String? = nil,
        subscriptionTier: SubscriptionTier = .free,
        createdAt: Date = Date(),
        isGuest: Bool = false
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarURL = avatarURL
        self.subscriptionTier = subscriptionTier
        self.createdAt = createdAt
        self.isGuest = isGuest
    }

    // Guest user factory
    static func guestUser() -> User {
        User(
            id: "guest_\(UUID().uuidString)",
            email: "",
            username: "Guest",
            subscriptionTier: .free,
            isGuest: true
        )
    }

    // Computed property for display
    var displayUsername: String {
        displayName ?? username
    }

    // Initials for avatar placeholder
    var initials: String {
        let name = displayName ?? username
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
}

// MARK: - Subscription Tier
enum SubscriptionTier: String, Codable {
    case free
    case premium

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }

    var features: [String] {
        switch self {
        case .free:
            return [
                "Limited song library",
                "Standard quality audio",
                "25 favorites max",
                "Ads between tracks"
            ]
        case .premium:
            return [
                "Full song library (100+ songs)",
                "High quality audio (320kbps)",
                "Unlimited favorites",
                "No ads",
                "Background play",
                "Offline downloads",
                "Custom themes",
                "Advanced listening stats"
            ]
        }
    }
}
