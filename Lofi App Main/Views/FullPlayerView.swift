//
//  FullPlayerView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct FullPlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Binding var isPresented: Bool
    @State private var isDraggingSlider = false
    @State private var showTimer = false
    @StateObject private var timerManager = TimerManager()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top bar with dismiss button
                    topBar
                        .padding(.horizontal)
                        .padding(.top, 8)

                    Spacer(minLength: 20)

                    // Album art
                    albumArtwork
                        .frame(height: geometry.size.width * 0.85)
                        .padding(.horizontal, 32)

                    Spacer(minLength: 32)

                    // Track info
                    trackInfo
                        .padding(.horizontal, 32)

                    Spacer(minLength: 24)

                    // Playback controls
                    playbackControls
                        .padding(.horizontal, 32)

                    Spacer(minLength: 32)

                    // Additional controls
                    additionalControls
                        .padding(.horizontal, 48)
                        .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showTimer) {
            TimerView(timerManager: timerManager, isPresented: $showTimer)
        }
    }

    // MARK: - View Components
    private var topBar: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isPresented = false
                }
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text("Now Playing")
                .font(AppTheme.Typography.body(weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Button(action: {
                showTimer = true
            }) {
                ZStack {
                    Image(systemName: "timer")
                        .font(.system(size: 20))
                        .foregroundColor(
                            timerManager.hasActiveTimer
                            ? AppTheme.Colors.primary
                            : AppTheme.Colors.textSecondary
                        )
                        .frame(width: 44, height: 44)

                    // Active timer indicator
                    if timerManager.hasActiveTimer {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 8, height: 8)
                            .offset(x: 10, y: -10)
                    }
                }
            }
        }
    }

    private var albumArtwork: some View {
        ZStack {
            if let urlString = viewModel.currentTrack?.albumArtURL {
                AnimatedCloudView(imageURL: urlString)
            } else {
                AnimatedCloudView(imageURL: nil)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xlarge))
        .shadow(
            color: AppTheme.Shadows.large.color,
            radius: AppTheme.Shadows.large.radius,
            x: AppTheme.Shadows.large.x,
            y: AppTheme.Shadows.large.y
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xlarge)
                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
        )
    }

    private var trackInfo: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(viewModel.currentTrack?.title ?? "No Track")
                .font(AppTheme.Typography.title())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(viewModel.currentTrack?.artist ?? "")
                .font(AppTheme.Typography.headline())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var playbackControls: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Progress slider
            VStack(spacing: AppTheme.Spacing.sm) {
                Slider(
                    value: Binding(
                        get: { isDraggingSlider ? viewModel.progress : viewModel.progress },
                        set: { newValue in
                            if isDraggingSlider {
                                viewModel.seekToProgress(newValue)
                            }
                        }
                    ),
                    onEditingChanged: { editing in
                        isDraggingSlider = editing
                    }
                )
                .tint(AppTheme.Colors.primary)

                HStack {
                    Text(viewModel.formattedCurrentTime)
                        .font(AppTheme.Typography.caption(weight: .medium))
                        .foregroundColor(AppTheme.Colors.textTertiary)

                    Spacer()

                    Text(viewModel.formattedDuration)
                        .font(AppTheme.Typography.caption(weight: .medium))
                        .foregroundColor(AppTheme.Colors.textTertiary)
                }
            }

            // Control buttons
            HStack(spacing: 32) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.previousTrack()
                    }
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(width: 60, height: 60)
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        viewModel.togglePlayPause()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.textPrimary)
                            .frame(width: 72, height: 72)
                            .shadow(
                                color: AppTheme.Shadows.medium.color,
                                radius: AppTheme.Shadows.medium.radius,
                                x: AppTheme.Shadows.medium.x,
                                y: AppTheme.Shadows.medium.y
                            )

                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.Colors.backgroundTop)
                            .offset(x: viewModel.isPlaying ? 0 : 2)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .scaleEffect(viewModel.isPlaying ? 1.0 : 0.95)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isPlaying)

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.nextTrack()
                    }
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(width: 60, height: 60)
                }
            }
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }

    private var additionalControls: some View {
        HStack(spacing: 40) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleShuffle()
                }
            }) {
                Image(systemName: viewModel.isShuffled ? "shuffle.circle.fill" : "shuffle")
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.isShuffled ? AppTheme.Colors.primary : AppTheme.Colors.textTertiary)
            }

            Button(action: {
                // Favorite functionality placeholder
            }) {
                Image(systemName: "heart")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.toggleRepeatMode()
                }
            }) {
                Image(systemName: repeatIcon)
                    .font(.system(size: 24))
                    .foregroundColor(viewModel.repeatMode != .off ? AppTheme.Colors.primary : AppTheme.Colors.textTertiary)
            }
        }
    }

    private var repeatIcon: String {
        switch viewModel.repeatMode {
        case .off:
            return "repeat"
        case .one:
            return "repeat.1.circle.fill"
        case .all:
            return "repeat.circle.fill"
        }
    }
}

#Preview {
    FullPlayerView(
        viewModel: {
            let vm = PlayerViewModel()
            vm.playTrack(Track.sampleTracks[0])
            return vm
        }(),
        isPresented: .constant(true)
    )
}
