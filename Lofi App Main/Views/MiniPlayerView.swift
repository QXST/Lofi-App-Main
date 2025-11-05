//
//  MiniPlayerView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @Binding var showFullPlayer: Bool
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.Colors.primary))
                .scaleEffect(x: 1, y: 0.5, anchor: .center)

            // Player content
            HStack(spacing: AppTheme.Spacing.md) {
                // Album art with animated cloud
                ZStack {
                    if let urlString = viewModel.currentTrack?.albumArtURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            CloudPlaceholderView()
                        }
                    } else {
                        CloudPlaceholderView()
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                .shadow(
                    color: AppTheme.Shadows.small.color,
                    radius: AppTheme.Shadows.small.radius,
                    x: AppTheme.Shadows.small.x,
                    y: AppTheme.Shadows.small.y
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showFullPlayer = true
                    }
                }

                // Track info
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(viewModel.currentTrack?.title ?? "No Track")
                        .font(AppTheme.Typography.callout(weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .lineLimit(1)

                    Text(viewModel.currentTrack?.genre ?? "")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(1)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showFullPlayer = true
                    }
                }

                Spacer()

                // Playback controls
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.togglePlayPause()
                        }
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(width: 44, height: 44)
                            .contentTransition(.symbolEffect(.replace))
                    }

                    Button(action: {
                        viewModel.nextTrack()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(
            ZStack {
                AppTheme.Gradients.background
                    .opacity(0.95)

                // Blur effect
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
            .shadow(
                color: AppTheme.Shadows.medium.color,
                radius: AppTheme.Shadows.medium.radius,
                x: AppTheme.Shadows.medium.x,
                y: AppTheme.Shadows.medium.y
            )
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < 0 {
                        dragOffset = value.translation.height * 0.5
                    }
                }
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showFullPlayer = true
                        }
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
        )
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView(
            viewModel: {
                let vm = PlayerViewModel()
                vm.playTrack(Track.sampleTracks[0])
                return vm
            }(),
            showFullPlayer: .constant(false)
        )
    }
    .background(Color.gray.opacity(0.1))
}
