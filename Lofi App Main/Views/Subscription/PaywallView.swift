//
//  PaywallView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedPlan: SubscriptionPlan = .annual
    @State private var showError: String?
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            // Background
            AppTheme.Gradients.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            // Animated crown
                            Image(systemName: "crown.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .yellow.opacity(0.5), radius: 20)
                        }
                        .padding(.top, 40)

                        Text("Upgrade to Premium")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("Unlock the full Lo-fi experience")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    // Premium Features
                    VStack(spacing: 16) {
                        FeatureRow(
                            icon: "music.note.list",
                            title: "100+ Lofi Tracks",
                            description: "Access our entire collection"
                        )

                        FeatureRow(
                            icon: "hifispeaker.fill",
                            title: "High Quality Audio",
                            description: "Stream in 320kbps quality"
                        )

                        FeatureRow(
                            icon: "speaker.slash.fill",
                            title: "Ad-Free Listening",
                            description: "No interruptions, pure focus"
                        )

                        FeatureRow(
                            icon: "arrow.down.circle.fill",
                            title: "Offline Downloads",
                            description: "Listen anywhere, anytime"
                        )

                        FeatureRow(
                            icon: "app.badge.fill",
                            title: "Background Play",
                            description: "Keep playing when app is closed"
                        )

                        FeatureRow(
                            icon: "heart.fill",
                            title: "Unlimited Favorites",
                            description: "Save as many tracks as you want"
                        )
                    }
                    .padding(.horizontal, 24)

                    // Plan Selection
                    VStack(spacing: 12) {
                        PlanCard(
                            plan: .annual,
                            isSelected: selectedPlan.id == SubscriptionPlan.annual.id,
                            action: { selectedPlan = .annual }
                        )

                        PlanCard(
                            plan: .monthly,
                            isSelected: selectedPlan.id == SubscriptionPlan.monthly.id,
                            action: { selectedPlan = .monthly }
                        )
                    }
                    .padding(.horizontal, 24)

                    // Error Message
                    if let showError = showError {
                        Text(showError)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }

                    // Subscribe Button
                    VStack(spacing: 12) {
                        Button(action: startFreeTrial) {
                            if subscriptionManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                VStack(spacing: 4) {
                                    Text("Start 7-Day Free Trial")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Then \(selectedPlan.price)/\(selectedPlan.period)")
                                        .font(.system(size: 14))
                                        .opacity(0.9)
                                }
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
                        .disabled(subscriptionManager.isLoading)

                        Button(action: { dismiss() }) {
                            Text("Restore Purchases")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        Text("Cancel anytime. Auto-renews unless cancelled.")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .alert("Premium Activated!", isPresented: $showSuccess) {
            Button("Awesome!") {
                dismiss()
            }
        } message: {
            Text("You now have access to all premium features!")
        }
    }

    // MARK: - Actions
    private func startFreeTrial() {
        showError = nil
        Task {
            do {
                try await subscriptionManager.startFreeTrial()
                await MainActor.run {
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    showError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(AppTheme.Colors.cardLight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(plan.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        if plan.isPopular {
                            Text("POPULAR")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    Text("\(plan.price) \(plan.period)")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    if plan.isPopular {
                        Text("Best value - Save $10/year")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.textTertiary, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppTheme.Colors.cardMedium : AppTheme.Colors.cardLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
}
