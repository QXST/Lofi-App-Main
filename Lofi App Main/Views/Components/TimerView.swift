//
//  TimerView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            AppTheme.Gradients.background
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Focus Timer")
                        .font(AppTheme.Typography.headline())
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.md)

                if timerManager.hasActiveTimer {
                    activeTimerView
                } else {
                    presetSelectionView
                }

                Spacer()
            }
        }
    }

    // MARK: - Active Timer View
    private var activeTimerView: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            // Circular Timer
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        AppTheme.Colors.cardMedium,
                        lineWidth: 12
                    )
                    .frame(width: 280, height: 280)

                // Progress circle
                Circle()
                    .trim(from: 0, to: timerManager.currentTimer?.progress ?? 0)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(
                                    red: timerManager.currentPreset?.color.red ?? 0.5,
                                    green: timerManager.currentPreset?.color.green ?? 0.6,
                                    blue: timerManager.currentPreset?.color.blue ?? 1.0
                                ),
                                AppTheme.Colors.primary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerManager.currentTimer?.progress)

                // Time display
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(timerManager.currentTimer?.formattedRemaining ?? "0:00")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .monospacedDigit()

                    if let preset = timerManager.currentPreset {
                        Text(preset.rawValue)
                            .font(AppTheme.Typography.callout())
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(.top, AppTheme.Spacing.xxl)

            // Controls
            VStack(spacing: AppTheme.Spacing.lg) {
                // Play/Pause Button
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.pauseTimer()
                    } else {
                        timerManager.resumeTimer()
                    }
                }) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))

                        Text(timerManager.isRunning ? "Pause" : "Resume")
                            .font(AppTheme.Typography.body(weight: .semibold))
                    }
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .fill(AppTheme.Colors.primary)
                    )
                }

                // Quick time adjustments
                HStack(spacing: AppTheme.Spacing.md) {
                    timeAdjustButton(minutes: -5, label: "-5 min")
                    timeAdjustButton(minutes: 5, label: "+5 min")
                    stopButton
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }

    // MARK: - Preset Selection View
    private var presetSelectionView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.lg) {
                Text("Choose Your Focus Mode")
                    .font(AppTheme.Typography.title())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                        GridItem(.flexible(), spacing: AppTheme.Spacing.md)
                    ],
                    spacing: AppTheme.Spacing.md
                ) {
                    ForEach(FocusPreset.allCases) { preset in
                        PresetCard(preset: preset) {
                            timerManager.startTimer(preset: preset)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)

                // Today's stats
                if timerManager.todaysFocusTime() > 0 {
                    todaysStatsView
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.lg)
                }
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
    }

    // MARK: - Helper Views
    private func timeAdjustButton(minutes: Int, label: String) -> some View {
        Button(action: {
            timerManager.addTime(TimeInterval(minutes * 60))
        }) {
            Text(label)
                .font(AppTheme.Typography.callout(weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(AppTheme.Colors.cardMedium)
                )
        }
    }

    private var stopButton: some View {
        Button(action: {
            timerManager.stopTimer(completed: false)
        }) {
            Text("Stop")
                .font(AppTheme.Typography.callout(weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .fill(AppTheme.Colors.cardMedium)
                )
        }
    }

    private var todaysStatsView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppTheme.Colors.primary)

                Text("Today's Focus Time")
                    .font(AppTheme.Typography.body(weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()
            }

            HStack(spacing: AppTheme.Spacing.xl) {
                StatItem(
                    value: formatDuration(timerManager.todaysFocusTime()),
                    label: "Total Time"
                )

                StatItem(
                    value: "\(timerManager.completedSessionsCount())",
                    label: "Sessions"
                )

                Spacer()
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.cardLight)
        )
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Preset Card
struct PresetCard: View {
    let preset: FocusPreset
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: preset.icon)
                    .font(.system(size: 32))
                    .foregroundColor(
                        Color(
                            red: preset.color.red,
                            green: preset.color.green,
                            blue: preset.color.blue
                        )
                    )

                VStack(spacing: AppTheme.Spacing.xs) {
                    Text(preset.rawValue)
                        .font(AppTheme.Typography.callout(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text(formatPresetDuration(preset.duration))
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardLight)
            )
        }
    }

    private func formatPresetDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            return "\(minutes) min"
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(value)
                .font(AppTheme.Typography.title(weight: .bold))
                .foregroundColor(AppTheme.Colors.primary)

            Text(label)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
    }
}

#Preview {
    TimerView(
        timerManager: TimerManager(),
        isPresented: .constant(true)
    )
}
