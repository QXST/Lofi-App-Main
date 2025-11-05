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
        HStack(spacing: 12) {
            // Album art
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
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showFullPlayer = true
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10)
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

            // Track info
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.currentTrack?.title ?? "No Track")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(viewModel.currentTrack?.artist ?? viewModel.currentTrack?.genre ?? "")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showFullPlayer = true
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10)
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

            // Playback controls
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)

                Button(action: {
                    viewModel.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .allowsHitTesting(false)
        )
        .offset(y: dragOffset)
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
