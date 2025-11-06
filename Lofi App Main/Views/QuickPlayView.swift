import SwiftUI

struct QuickPlayView: View {
    @ObservedObject var playerViewModel: PlayerViewModel
    @State private var currentAnimationStyle: RetroAnimationStyle = .coffeeShop
    @State private var showTapHint: Bool = true
    @AppStorage("hasSeenQuickPlayHint") private var hasSeenHint: Bool = false

    var body: some View {
        ZStack {
            // Full-page animated background
            RetroAnimationView(currentStyle: $currentAnimationStyle)
                .ignoresSafeArea()

            // Tap hint (only show on first launch)
            if showTapHint && !hasSeenHint {
                VStack {
                    Spacer()
                    tapHintView
                        .padding(.bottom, 120)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.mediumImpact()
            playerViewModel.togglePlayPause()
        }
        .onAppear {
            startPlayingIfNeeded()
            showHintBriefly()
        }
    }

    // MARK: - Tap Hint View
    private var tapHintView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 14))
                Text("Tap to play/pause")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )

            HStack(spacing: 8) {
                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 14))
                Text("Swipe to change scene")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Helper Methods
    private func startPlayingIfNeeded() {
        // Only start playing if there's no track or nothing is playing
        if playerViewModel.currentTrack == nil && !playerViewModel.isPlaying {
            // Fetch and start playing from the default playlist
            Task {
                do {
                    try await playerViewModel.fetchTracks()
                    if let firstTrack = playerViewModel.playlist.first {
                        playerViewModel.playTrack(firstTrack)
                    }
                } catch {
                    print("Failed to fetch tracks: \(error)")
                }
            }
        }
    }

    private func showHintBriefly() {
        guard !hasSeenHint else {
            showTapHint = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showTapHint = false
                hasSeenHint = true
            }
        }
    }
}

// MARK: - Haptic Manager
class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Preview
#Preview {
    QuickPlayView(playerViewModel: PlayerViewModel())
}
