//
//  SubscriptionStatus.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation

enum SubscriptionStatus: String, Codable {
    case active
    case expired
    case trial
    case cancelled
    case none

    var displayName: String {
        switch self {
        case .active: return "Active"
        case .expired: return "Expired"
        case .trial: return "Free Trial"
        case .cancelled: return "Cancelled"
        case .none: return "None"
        }
    }
}

struct SubscriptionInfo: Codable {
    let tier: SubscriptionTier
    let status: SubscriptionStatus
    let expirationDate: Date?
    let isInTrial: Bool
    let trialDaysRemaining: Int?

    var isActive: Bool {
        status == .active || status == .trial
    }

    var displayText: String {
        if isInTrial, let days = trialDaysRemaining {
            return "\(days) days left in trial"
        }
        return status.displayName
    }
}

// MARK: - Subscription Plans
struct SubscriptionPlan: Identifiable {
    let id: String
    let name: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool

    static let monthly = SubscriptionPlan(
        id: "premium_monthly",
        name: "Monthly",
        price: "$4.99",
        period: "per month",
        features: [
            "Full song library (100+ songs)",
            "High quality audio (320kbps)",
            "Unlimited favorites",
            "No ads",
            "Background play",
            "Offline downloads",
            "Custom themes",
            "Advanced stats"
        ],
        isPopular: false
    )

    static let annual = SubscriptionPlan(
        id: "premium_annual",
        name: "Annual",
        price: "$49.99",
        period: "per year",
        features: [
            "Everything in Monthly",
            "Save $10 per year",
            "Priority support",
            "Early access to new features"
        ],
        isPopular: true
    )

    static let allPlans: [SubscriptionPlan] = [monthly, annual]
}
