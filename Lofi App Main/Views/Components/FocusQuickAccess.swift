//
//  FocusQuickAccess.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct FocusQuickAccess: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var showTimer: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(AppTheme.Colors.primary)

                Text("Quick Focus")
                    .font(AppTheme.Typography.headline())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()

                Button(action: {
                    showTimer = true
                }) {
                    Text("See All")
                        .font(AppTheme.Typography.callout(weight: .medium))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach([FocusPreset.pomodoro, .study, .deepWork, .sleep]) { preset in
                        QuickPresetButton(preset: preset) {
                            timerManager.startTimer(preset: preset)
                            showTimer = true
                        }
                    }
                }
            }

            // Active timer indicator
            if timerManager.hasActiveTimer {
                activeTimerIndicator
            }
        }
    }

    private var activeTimerIndicator: some View {
        Button(action: {
            showTimer = true
        }) {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.cardMedium, lineWidth: 3)
                        .frame(width: 32, height: 32)

                    Circle()
                        .trim(from: 0, to: timerManager.currentTimer?.progress ?? 0)
                        .stroke(AppTheme.Colors.primary, lineWidth: 3)
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                }

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(timerManager.currentPreset?.rawValue ?? "Focus Session")
                        .font(AppTheme.Typography.callout(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(timerManager.currentTimer?.formattedRemaining ?? "0:00")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.primary)
                        .monospacedDigit()
                }

                Spacer()

                Image(systemName: timerManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardMedium)
            )
        }
    }
}

// MARK: - Quick Preset Button
struct QuickPresetButton: View {
    let preset: FocusPreset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: preset.icon)
                    .font(.system(size: 24))
                    .foregroundColor(
                        Color(
                            red: preset.color.red,
                            green: preset.color.green,
                            blue: preset.color.blue
                        )
                    )
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                Color(
                                    red: preset.color.red,
                                    green: preset.color.green,
                                    blue: preset.color.blue
                                ).opacity(0.15)
                            )
                    )

                Text(preset.rawValue)
                    .font(AppTheme.Typography.caption(weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)

                Text(formatDuration(preset.duration))
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .frame(width: 100)
            .padding(.vertical, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardLight)
            )
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            return "\(minutes / 60)h"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    ZStack {
        AppTheme.Gradients.background
            .ignoresSafeArea()

        VStack {
            FocusQuickAccess(
                timerManager: TimerManager(),
                showTimer: .constant(false)
            )
            .padding()

            Spacer()
        }
    }
}
