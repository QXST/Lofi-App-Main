//
//  SubscriptionManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation
import Combine

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var subscriptionInfo: SubscriptionInfo?
    @Published var isLoading: Bool = false

    private let sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadSubscriptionInfo()
    }

    // MARK: - Load Subscription
    private func loadSubscriptionInfo() {
        guard let user = sessionManager.currentUser else {
            subscriptionInfo = nil
            return
        }

        // Mock subscription info based on user's tier
        let status: SubscriptionStatus = user.subscriptionTier == .premium ? .active : .none
        subscriptionInfo = SubscriptionInfo(
            tier: user.subscriptionTier,
            status: status,
            expirationDate: user.subscriptionTier == .premium ? Calendar.current.date(byAdding: .month, value: 1, to: Date()) : nil,
            isInTrial: false,
            trialDaysRemaining: nil
        )
    }

    // MARK: - Purchase Subscription (Mock)
    func purchaseSubscription(plan: SubscriptionPlan) async throws {
        isLoading = true

        // Simulate purchase delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Mock successful purchase
        sessionManager.upgradeToPremium()
        loadSubscriptionInfo()

        await MainActor.run {
            isLoading = false
        }
    }

    // MARK: - Start Free Trial (Mock)
    func startFreeTrial() async throws {
        isLoading = true

        // Simulate trial activation delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Mock trial activation
        sessionManager.upgradeToPremium()

        // Update subscription info with trial
        subscriptionInfo = SubscriptionInfo(
            tier: .premium,
            status: .trial,
            expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            isInTrial: true,
            trialDaysRemaining: 7
        )

        await MainActor.run {
            isLoading = false
        }
    }

    // MARK: - Restore Purchases (Mock)
    func restorePurchases() async throws {
        isLoading = true

        // Simulate restore delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Mock restore - for demo, always succeed
        sessionManager.upgradeToPremium()
        loadSubscriptionInfo()

        await MainActor.run {
            isLoading = false
        }
    }

    // MARK: - Cancel Subscription (Mock)
    func cancelSubscription() async throws {
        isLoading = true

        // Simulate cancellation delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Mock cancellation
        sessionManager.downgradeToFree()

        subscriptionInfo = SubscriptionInfo(
            tier: .free,
            status: .cancelled,
            expirationDate: nil,
            isInTrial: false,
            trialDaysRemaining: nil
        )

        await MainActor.run {
            isLoading = false
        }
    }

    // MARK: - Feature Gating
    func hasAccess(to feature: PremiumFeature) -> Bool {
        guard let info = subscriptionInfo else { return false }
        return info.tier == .premium && info.isActive
    }

    var isPremium: Bool {
        sessionManager.isPremium
    }

    var canAccessPremiumContent: Bool {
        guard let info = subscriptionInfo else { return false }
        return info.tier == .premium && info.isActive
    }

    // MARK: - Refresh
    func refresh() {
        loadSubscriptionInfo()
    }
}

// MARK: - Premium Features
enum PremiumFeature {
    case highQualityAudio
    case unlimitedFavorites
    case offlineDownloads
    case backgroundPlay
    case customThemes
    case advancedStats
    case noAds
    case fullLibrary

    var title: String {
        switch self {
        case .highQualityAudio: return "High Quality Audio"
        case .unlimitedFavorites: return "Unlimited Favorites"
        case .offlineDownloads: return "Offline Downloads"
        case .backgroundPlay: return "Background Play"
        case .customThemes: return "Custom Themes"
        case .advancedStats: return "Advanced Stats"
        case .noAds: return "Ad-Free Listening"
        case .fullLibrary: return "Full Song Library"
        }
    }

    var description: String {
        switch self {
        case .highQualityAudio: return "320kbps audio streaming"
        case .unlimitedFavorites: return "Save as many tracks as you want"
        case .offlineDownloads: return "Listen without internet"
        case .backgroundPlay: return "Keep playing when app is closed"
        case .customThemes: return "Personalize your experience"
        case .advancedStats: return "Detailed listening insights"
        case .noAds: return "Uninterrupted listening experience"
        case .fullLibrary: return "Access to 100+ lofi tracks"
        }
    }

    var icon: String {
        switch self {
        case .highQualityAudio: return "hifispeaker.fill"
        case .unlimitedFavorites: return "heart.fill"
        case .offlineDownloads: return "arrow.down.circle.fill"
        case .backgroundPlay: return "app.badge.fill"
        case .customThemes: return "paintbrush.fill"
        case .advancedStats: return "chart.bar.fill"
        case .noAds: return "speaker.slash.fill"
        case .fullLibrary: return "music.note.list"
        }
    }
}
