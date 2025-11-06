//
//  ChannelsQuickAccess.swift
//  Lofi App Main
//
//  Created by Quest on 11/6/25.
//

import SwiftUI

struct ChannelsQuickAccess: View {
    @ObservedObject var playerViewModel: PlayerViewModel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(AppTheme.Colors.primary)

                Text("Music Channels")
                    .font(AppTheme.Typography.headline())
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(MusicChannel.allCases) { channel in
                        ChannelButton(channel: channel) {
                            Task {
                                await playerViewModel.fetchTracksByGenre(genre: channel.genre)
                                if let firstTrack = playerViewModel.playlist.first {
                                    playerViewModel.playTrack(firstTrack)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Channel Button
struct ChannelButton: View {
    let channel: MusicChannel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: channel.icon)
                    .font(.system(size: 24))
                    .foregroundColor(
                        Color(
                            red: channel.color.red,
                            green: channel.color.green,
                            blue: channel.color.blue
                        )
                    )
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                Color(
                                    red: channel.color.red,
                                    green: channel.color.green,
                                    blue: channel.color.blue
                                ).opacity(0.15)
                            )
                    )

                Text(channel.rawValue)
                    .font(AppTheme.Typography.caption(weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
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
}

#Preview {
    ZStack {
        AppTheme.Gradients.background
            .ignoresSafeArea()

        VStack {
            ChannelsQuickAccess(
                playerViewModel: PlayerViewModel()
            )
            .padding()

            Spacer()
        }
    }
}
