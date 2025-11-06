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
                    Color.clear.frame(height: 60)
                }
            }
            .zIndex(0)

            // Mini player overlay
            if playerViewModel.currentTrack != nil {
                VStack {
                    Spacer()
                    MiniPlayerView(viewModel: playerViewModel, showFullPlayer: $showFullPlayer)
                        .padding(.bottom, 55)
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
    @StateObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false

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

            // Favorite button
            Button(action: toggleFavorite) {
                Image(systemName: favoritesManager.isFavorite(trackId: track.id.uuidString) ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(favoritesManager.isFavorite(trackId: track.id.uuidString) ? .red : AppTheme.Colors.textSecondary)
            }
            .buttonStyle(.plain)

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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private func toggleFavorite() {
        let success = favoritesManager.toggleFavorite(track: track)
        if !success && !favoritesManager.canAddMore {
            // Show paywall if limit reached
            showPaywall = true
        }
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var playerViewModel = PlayerViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                if favoritesManager.favoriteTracks.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.textTertiary)

                        VStack(spacing: 12) {
                            Text("No favorites yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Tap the heart icon on tracks you love to add them here")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                } else {
                    // Favorites List
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header with count
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(favoritesManager.count) Favorites")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)

                                    if let remaining = favoritesManager.remainingFavorites {
                                        Text("\(remaining) slots remaining")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    } else {
                                        HStack(spacing: 4) {
                                            Image(systemName: "infinity")
                                                .font(.system(size: 12))
                                            Text("Unlimited")
                                                .font(.system(size: 14))
                                        }
                                        .foregroundColor(.green)
                                    }
                                }

                                Spacer()

                                if !subscriptionManager.isPremium {
                                    Button(action: { showPaywall = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "crown.fill")
                                            Text("Upgrade")
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(
                                                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.md)

                            // Favorites Grid
                            LazyVStack(spacing: AppTheme.Spacing.md) {
                                ForEach(favoritesManager.favoriteTracks) { track in
                                    FavoriteTrackRow(
                                        track: track,
                                        isPlaying: playerViewModel.currentTrack?.id == track.id && playerViewModel.isPlaying,
                                        isCurrent: playerViewModel.currentTrack?.id == track.id,
                                        onTap: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                playerViewModel.playTrack(track)
                                            }
                                        },
                                        onRemove: {
                                            withAnimation {
                                                favoritesManager.removeFavorite(trackId: track.id.uuidString)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.bottom, 120)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Favorite Track Row
struct FavoriteTrackRow: View {
    let track: Track
    let isPlaying: Bool
    let isCurrent: Bool
    let onTap: () -> Void
    let onRemove: () -> Void

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

            // Playing indicator or heart
            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.primary)
                    .symbolEffect(.variableColor.iterative)
            } else {
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(isCurrent ? AppTheme.Colors.cardMedium : AppTheme.Colors.cardLight)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture(perform: onTap)
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
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("audioQuality") private var audioQuality = "medium"
    @AppStorage("crossfadeDuration") private var crossfadeDuration = 5.0
    @AppStorage("gaplessPlayback") private var gaplessPlayback = true

    @AppStorage("notif_newMusic") private var notifNewMusic = true
    @AppStorage("notif_community") private var notifCommunity = true
    @AppStorage("notif_weeklyStats") private var notifWeeklyStats = true

    @State private var showProfile = false
    @State private var showPaywall = false
    @State private var showFeedback = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                List {
                    // Account Section
                    if let user = sessionManager.currentUser, !user.isGuest {
                        Section {
                            Button(action: { showProfile = true }) {
                                HStack(spacing: 16) {
                                    // Avatar
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(user.initials)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.displayUsername)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(AppTheme.Colors.textPrimary)

                                        Text(user.email)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                            }
                        } header: {
                            Text("Account")
                        }
                    }

                    // Subscription Section
                    Section {
                        if sessionManager.isPremium {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Premium Member")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Text("Active")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            }

                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "gear")
                                        .foregroundColor(AppTheme.Colors.primary)
                                    Text("Manage Subscription")
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                }
                            }
                        } else {
                            Button(action: { showPaywall = true }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.Colors.primary)
                                    Text("Upgrade to Premium")
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                            }
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Restore Purchases")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                    } header: {
                        Text("Subscription")
                    }

                    // Appearance Section
                    Section {
                        Toggle(isOn: $themeManager.isDarkMode) {
                            HStack(spacing: 12) {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Dark Mode")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .tint(AppTheme.Colors.primary)

                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Theme")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text("Cloud Blue")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            if !sessionManager.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        }
                    } header: {
                        Text("Appearance")
                    }

                    // Audio & Playback Section
                    Section {
                        HStack {
                            Image(systemName: "hifispeaker.fill")
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("Audio Quality")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text(audioQuality.capitalized)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            if audioQuality == "high" && !sessionManager.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "waveform")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Crossfade")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Text("\(Int(crossfadeDuration))s")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            Slider(value: $crossfadeDuration, in: 0...10, step: 1)
                                .tint(AppTheme.Colors.primary)
                        }

                        Toggle(isOn: $gaplessPlayback) {
                            HStack(spacing: 12) {
                                Image(systemName: "music.note.list")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Gapless Playback")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .tint(AppTheme.Colors.primary)
                    } header: {
                        Text("Audio & Playback")
                    }

                    // Notifications Section
                    Section {
                        Toggle(isOn: $notifNewMusic) {
                            HStack(spacing: 12) {
                                Image(systemName: "music.note")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("New Music")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .tint(AppTheme.Colors.primary)

                        Toggle(isOn: $notifCommunity) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Community Updates")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .tint(AppTheme.Colors.primary)

                        Toggle(isOn: $notifWeeklyStats) {
                            HStack(spacing: 12) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Weekly Stats")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                        .tint(AppTheme.Colors.primary)
                    } header: {
                        Text("Notifications")
                    }

                    // Privacy & Data Section
                    Section {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Clear Cache")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Text("127 MB")
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Download My Data")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                    } header: {
                        Text("Privacy & Data")
                    }

                    // Feedback & Support Section
                    Section {
                        Button(action: { showFeedback = true }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Send Feedback")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Rate on App Store")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Contact Support")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "ant.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Report a Bug")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                    } header: {
                        Text("Feedback & Support")
                    }

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(AppTheme.Colors.textTertiary)
                        }

                        Button(action: {}) {
                            HStack {
                                Text("Terms of Service")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        }

                        Button(action: {}) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.textTertiary)
                            }
                        }
                    } header: {
                        Text("About")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
        }
    }
}

#Preview {
    ContentView()
}
