//
//  FavoritesManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published var favorites: [Favorite] = []
    @Published var favoriteTracks: [Track] = []

    private let sessionManager = SessionManager.shared
    private let subscriptionManager = SubscriptionManager.shared
    private let userDefaultsKey = "com.lofiapp.favorites"
    private let freeUserLimit = 25

    private init() {
        loadFavorites()
    }

    // MARK: - Load Favorites
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([Favorite].self, from: data) else {
            favorites = []
            return
        }

        favorites = decoded
        loadFavoriteTracks()
    }

    // MARK: - Save Favorites
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    // MARK: - Load Favorite Tracks
    private func loadFavoriteTracks() {
        // Match favorites with tracks from sample data
        favoriteTracks = Track.sampleTracks.filter { track in
            favorites.contains { $0.trackId == track.id.uuidString }
        }
    }

    // MARK: - Add Favorite
    func addFavorite(track: Track) -> Bool {
        // Check if already favorited
        if isFavorite(trackId: track.id.uuidString) {
            return false
        }

        // Check free user limit
        if !subscriptionManager.isPremium && favorites.count >= freeUserLimit {
            return false // Need to show upgrade prompt
        }

        // Add favorite
        let favorite = Favorite(trackId: track.id.uuidString)
        favorites.append(favorite)
        saveFavorites()

        // Add to favorite tracks
        if !favoriteTracks.contains(where: { $0.id.uuidString == track.id.uuidString }) {
            favoriteTracks.append(track)
        }

        // Mock API sync
        Task {
            await syncWithServer()
        }

        return true
    }

    // MARK: - Remove Favorite
    func removeFavorite(trackId: String) {
        favorites.removeAll { $0.trackId == trackId }
        saveFavorites()

        favoriteTracks.removeAll { $0.id.uuidString == trackId }

        // Mock API sync
        Task {
            await syncWithServer()
        }
    }

    // MARK: - Toggle Favorite
    func toggleFavorite(track: Track) -> Bool {
        if isFavorite(trackId: track.id.uuidString) {
            removeFavorite(trackId: track.id.uuidString)
            return false
        } else {
            return addFavorite(track: track)
        }
    }

    // MARK: - Check if Favorite
    func isFavorite(trackId: String) -> Bool {
        favorites.contains { $0.trackId == trackId }
    }

    // MARK: - Get Favorite Count
    var count: Int {
        favorites.count
    }

    var canAddMore: Bool {
        subscriptionManager.isPremium || favorites.count < freeUserLimit
    }

    var remainingFavorites: Int? {
        if subscriptionManager.isPremium {
            return nil // Unlimited
        }
        return max(0, freeUserLimit - favorites.count)
    }

    // MARK: - Sync with Server (Mock)
    private func syncWithServer() async {
        // Simulate API sync
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        print("✅ Favorites synced with server")
    }

    // MARK: - Clear All
    func clearAll() {
        favorites.removeAll()
        favoriteTracks.removeAll()
        saveFavorites()
    }

    // MARK: - Refresh
    func refresh() {
        loadFavorites()
    }
}
