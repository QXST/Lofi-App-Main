//
//  ContentView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var playerViewModel = PlayerViewModel()
    @State private var showFullPlayer = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: playerViewModel)
                    .tabItem {
                        Label("Radio", systemImage: "headphones")
                    }
                    .tag(0)

                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .tag(1)

                CommunityView()
                    .tabItem {
                        Label("Lo-fi Clouds", systemImage: "cloud.fill")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .accentColor(Color(red: 0.5, green: 0.6, blue: 1.0))
            .safeAreaInset(edge: .bottom) {
                if playerViewModel.currentTrack != nil {
                    Color.clear.frame(height: 72)
                }
            }
            .zIndex(0)

            // Mini player overlay
            if playerViewModel.currentTrack != nil {
                VStack {
                    Spacer()
                    MiniPlayerView(viewModel: playerViewModel, showFullPlayer: $showFullPlayer)
                        .transition(.move(edge: .bottom))
                }
                .zIndex(1)
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            FullPlayerView(viewModel: playerViewModel, isPresented: $showFullPlayer)
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @State private var selectedSegment = 0
    @StateObject private var timerManager = TimerManager()
    @State private var showTimer = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Now Playing Card
                        if let track = viewModel.currentTrack {
                            NowPlayingCard(
                                track: track,
                                isPlaying: viewModel.isPlaying
                            )
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.md)
                        } else {
                            // Hero section when nothing is playing
                            VStack(spacing: AppTheme.Spacing.lg) {
                                Text("Now Playing")
                                    .font(AppTheme.Typography.largeTitle())
                                    .foregroundColor(AppTheme.Colors.textPrimary)

                                AnimatedCloudView(imageURL: nil)
                                    .frame(height: 280)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xlarge))
                                    .shadow(
                                        color: AppTheme.Shadows.large.color,
                                        radius: AppTheme.Shadows.large.radius,
                                        x: AppTheme.Shadows.large.x,
                                        y: AppTheme.Shadows.large.y
                                    )
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.xxl)
                        }

                        // Quick Focus Access
                        FocusQuickAccess(
                            timerManager: timerManager,
                            showTimer: $showTimer
                        )
                        .padding(.horizontal, AppTheme.Spacing.lg)

                        // Segmented control
                        SegmentedControlView(
                            selectedIndex: $selectedSegment,
                            options: ["Radio", "Favorites"]
                        )
                        .padding(.horizontal, AppTheme.Spacing.lg)

                        // Content based on selection
                        if selectedSegment == 0 {
                            radioSection
                        } else {
                            favoritesSection
                        }
                    }
                    .padding(.bottom, 120)
                }
                .refreshable {
                    await viewModel.fetchTracks()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showTimer) {
                TimerView(timerManager: timerManager, isPresented: $showTimer)
            }
        }
    }

    private var radioSection: some View {
        Group {
            if viewModel.isLoadingTracks {
                LoadingView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppTheme.Spacing.xxl)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    viewModel.refreshContent()
                }
                .padding(.top, AppTheme.Spacing.xxl)
            } else if viewModel.playlist.isEmpty {
                EmptyStateView(
                    icon: "music.note.list",
                    title: "No Tracks Available",
                    description: "Pull to refresh or check your connection",
                    actionTitle: "Refresh",
                    action: {
                        viewModel.refreshContent()
                    }
                )
                .padding(.top, AppTheme.Spacing.xxl)
            } else {
                VStack(spacing: AppTheme.Spacing.md) {
                    ForEach(Array(viewModel.playlist.enumerated()), id: \.element.id) { index, track in
                        TrackRow(
                            track: track,
                            isPlaying: viewModel.currentTrack?.id == track.id && viewModel.isPlaying,
                            isCurrent: viewModel.currentTrack?.id == track.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.playTrack(track)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
    }

    private var favoritesSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.textTertiary)

            Text("No favorites yet")
                .font(AppTheme.Typography.headline())
                .foregroundColor(AppTheme.Colors.textSecondary)

            Text("Tap the heart icon on tracks you love")
                .font(AppTheme.Typography.callout())
                .foregroundColor(AppTheme.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.Spacing.xxl)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .opacity
        ))
    }
}

// MARK: - Now Playing Card
struct NowPlayingCard: View {
    let track: Track
    let isPlaying: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text("Now Playing")
                .font(AppTheme.Typography.largeTitle())
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            AnimatedCloudView(imageURL: track.albumArtURL)
                .frame(height: 280)
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

            VStack(spacing: AppTheme.Spacing.xs) {
                Text(track.title)
                    .font(AppTheme.Typography.title())
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(track.genre)
                    .font(AppTheme.Typography.callout())
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Track Row
struct TrackRow: View {
    let track: Track
    let isPlaying: Bool
    let isCurrent: Bool
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Album art
            AsyncImage(url: track.albumArtURL.flatMap { URL(string: $0) }) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                CloudPlaceholderView()
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))

            // Track info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(track.title)
                    .font(AppTheme.Typography.body(weight: .semibold))
                    .foregroundColor(isCurrent ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                Text(track.artist)
                    .font(AppTheme.Typography.callout())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Playing indicator
            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.primary)
                    .symbolEffect(.variableColor.iterative)
            } else if isCurrent {
                Image(systemName: "pause.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.primary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(isCurrent ? AppTheme.Colors.cardMedium : AppTheme.Colors.cardLight)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPlaying)
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.2),
                        Color(red: 0.1, green: 0.1, blue: 0.15)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("You have no favorites yet.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Community View
struct CommunityView: View {
    @State private var selectedTab = 1 // 0 = News, 1 = Community

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    Text("Lo-fi Clouds")
                        .font(AppTheme.Typography.largeTitle())
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.xxl)
                        .padding(.bottom, AppTheme.Spacing.md)

                    // Tab Selector
                    SegmentedControlView(
                        selectedIndex: $selectedTab,
                        options: ["News", "Community"]
                    )
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.lg)

                    // Content
                    ScrollView(showsIndicators: false) {
                        if selectedTab == 0 {
                            newsSection
                        } else {
                            communitySection
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var newsSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ForEach(NewsItem.sampleNews) { item in
                NewsCard(item: item)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, 100)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    private var communitySection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Description
            VStack(spacing: AppTheme.Spacing.md) {
                Text("LFC radio is so much more than just an app. We are a team of audiophiles and regularly release music, sample packs, radio shows and more.")
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Checking out the links below, following and interacting with our socials and supporting music is how you can directly help LFC and the artists. We appreciate all your help.")
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, AppTheme.Spacing.md)

            // Social links
            VStack(spacing: AppTheme.Spacing.md) {
                SocialLinkButton(icon: "globe", title: "Website")
                SocialLinkButton(icon: "music.note.list", title: "Bandcamp")
                SocialLinkButton(icon: "music.note", title: "Spotify")
                SocialLinkButton(icon: "waveform", title: "Soundcloud")
                SocialLinkButton(icon: "play.circle.fill", title: "Youtube")
                SocialLinkButton(icon: "camera.fill", title: "Instagram")
                SocialLinkButton(icon: "music.quarternote.3", title: "TikTok")
                SocialLinkButton(icon: "message.fill", title: "Discord")
                SocialLinkButton(icon: "bird.fill", title: "Twitter")
                SocialLinkButton(icon: "f.circle.fill", title: "Facebook")
                SocialLinkButton(icon: "envelope.fill", title: "Email")
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, 100)
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - News Card
struct NewsCard: View {
    let item: NewsItem

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Thumbnail
            AsyncImage(url: item.imageURL.flatMap { URL(string: $0) }) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                CloudPlaceholderView()
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))

            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.title)
                    .font(AppTheme.Typography.body(weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)

                Text(item.relativeTime)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }

            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
}

struct SocialLinkButton: View {
    let icon: String
    let title: String
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 40)

            Text(title)
                .font(AppTheme.Typography.body(weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.cardLight)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                List {
                    Section {
                        Toggle(isOn: $isDarkMode) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Dark Mode")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .tint(AppTheme.Colors.primary)
                    }

                    Section {
                        Button(action: {}) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Sharing is caring")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }

                        Button(action: {}) {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Help us Grow")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
