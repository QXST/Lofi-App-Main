//
//  MusicAPIService.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation

class MusicAPIService {
    static let shared = MusicAPIService()

    private let networkManager = NetworkManager.shared
    private let baseURL = "https://api.example.com/v1" // Replace with actual API endpoint

    private init() {}

    // MARK: - Tracks
    func fetchTracks(page: Int = 1, limit: Int = 20) async throws -> [Track] {
        // For now, return sample data
        // When you have a real API, uncomment and use this:
        /*
        let response: TracksResponse = try await networkManager.request(
            "\(baseURL)/tracks",
            parameters: [
                "page": page,
                "limit": limit
            ]
        )
        return response.tracks.map { $0.toTrack() }
        */

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        return Track.sampleTracks
    }

    func searchTracks(query: String) async throws -> [Track] {
        // For now, filter sample data
        // When you have a real API:
        /*
        let response: TracksResponse = try await networkManager.request(
            "\(baseURL)/tracks/search",
            parameters: ["q": query]
        )
        return response.tracks.map { $0.toTrack() }
        */

        try await Task.sleep(nanoseconds: 300_000_000)

        return Track.sampleTracks.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.artist.localizedCaseInsensitiveContains(query)
        }
    }

    func fetchTracksByGenre(genre: String) async throws -> [Track] {
        /*
        let response: TracksResponse = try await networkManager.request(
            "\(baseURL)/tracks",
            parameters: ["genre": genre]
        )
        return response.tracks.map { $0.toTrack() }
        */

        try await Task.sleep(nanoseconds: 300_000_000)

        return Track.sampleTracks.filter { $0.genre == genre }
    }

    // MARK: - Playlists
    func fetchPlaylists() async throws -> [PlaylistResponse] {
        /*
        let response: [PlaylistResponse] = try await networkManager.request(
            "\(baseURL)/playlists"
        )
        return response
        */

        try await Task.sleep(nanoseconds: 500_000_000)

        // Return sample playlists
        return [
            PlaylistResponse(
                id: UUID().uuidString,
                name: "Focus & Study",
                description: "Perfect beats for concentration",
                tracks: Track.sampleTracks.map { TrackDTO(
                    id: $0.id.uuidString,
                    title: $0.title,
                    artist: $0.artist,
                    albumArt: $0.albumArtURL,
                    streamUrl: $0.streamURL,
                    duration: $0.duration,
                    genre: $0.genre
                )},
                imageUrl: "https://picsum.photos/400/400?random=20"
            ),
            PlaylistResponse(
                id: UUID().uuidString,
                name: "Sleep & Relax",
                description: "Calm sounds for better sleep",
                tracks: Track.sampleTracks.map { TrackDTO(
                    id: $0.id.uuidString,
                    title: $0.title,
                    artist: $0.artist,
                    albumArt: $0.albumArtURL,
                    streamUrl: $0.streamURL,
                    duration: $0.duration,
                    genre: $0.genre
                )},
                imageUrl: "https://picsum.photos/400/400?random=21"
            )
        ]
    }

    func fetchPlaylist(id: String) async throws -> PlaylistResponse {
        /*
        let response: PlaylistResponse = try await networkManager.request(
            "\(baseURL)/playlists/\(id)"
        )
        return response
        */

        try await Task.sleep(nanoseconds: 300_000_000)

        return PlaylistResponse(
            id: id,
            name: "Focus & Study",
            description: "Perfect beats for concentration",
            tracks: Track.sampleTracks.map { TrackDTO(
                id: $0.id.uuidString,
                title: $0.title,
                artist: $0.artist,
                albumArt: $0.albumArtURL,
                streamUrl: $0.streamURL,
                duration: $0.duration,
                genre: $0.genre
            )},
            imageUrl: "https://picsum.photos/400/400?random=20"
        )
    }

    // MARK: - Radio Stations
    func fetchRadioStations() async throws -> [RadioStation] {
        /*
        let response: RadioStationsResponse = try await networkManager.request(
            "\(baseURL)/radio/stations"
        )
        return response.stations.map { $0.toRadioStation() }
        */

        try await Task.sleep(nanoseconds: 500_000_000)

        return RadioStation.sampleStations
    }

    func fetchFeaturedStation() async throws -> RadioStation {
        try await Task.sleep(nanoseconds: 300_000_000)

        return RadioStation.sampleStations.first ?? RadioStation(
            name: "Lofi Radio",
            streamURL: "https://streams.ilovemusic.de/iloveradio17.mp3",
            genre: "Lofi"
        )
    }

    // MARK: - Trending & Featured
    func fetchTrendingTracks() async throws -> [Track] {
        /*
        let response: TracksResponse = try await networkManager.request(
            "\(baseURL)/tracks/trending"
        )
        return response.tracks.map { $0.toTrack() }
        */

        try await Task.sleep(nanoseconds: 500_000_000)

        return Track.sampleTracks
    }

    func fetchRecentlyAdded() async throws -> [Track] {
        try await Task.sleep(nanoseconds: 500_000_000)

        return Track.sampleTracks
    }

    // MARK: - News/Updates
    func fetchNews() async throws -> [NewsItem] {
        try await Task.sleep(nanoseconds: 500_000_000)

        return NewsItem.sampleNews
    }
}

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "https://api.loficlouds.com/v1" // Replace with actual API
    static let apiKey = "" // Add API key if needed

    // Endpoints
    struct Endpoints {
        static let tracks = "/tracks"
        static let playlists = "/playlists"
        static let radio = "/radio/stations"
        static let trending = "/tracks/trending"
        static let search = "/search"
        static let news = "/news"
    }
}
