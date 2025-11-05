//
//  PlayerViewModel.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation
import Combine

class PlayerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentTrack: Track?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playerState: PlayerState = .idle
    @Published var playlist: [Track] = []
    @Published var currentTrackIndex: Int = 0
    @Published var isShuffled: Bool = false
    @Published var repeatMode: RepeatMode = .off
    @Published var radioStations: [RadioStation] = []
    @Published var currentRadioStation: RadioStation?
    @Published var isLoadingTracks: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let audioManager: AudioPlayerManager
    private let apiService = MusicAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var originalPlaylist: [Track] = []

    enum RepeatMode {
        case off
        case one
        case all
    }

    // MARK: - Computed Properties
    var hasNext: Bool {
        currentTrackIndex < playlist.count - 1
    }

    var hasPrevious: Bool {
        currentTrackIndex > 0
    }

    var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    var formattedDuration: String {
        formatTime(duration)
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    // MARK: - Initialization
    init(audioManager: AudioPlayerManager = AudioPlayerManager()) {
        self.audioManager = audioManager
        setupBindings()
        loadSamplePlaylist()
    }

    // MARK: - Setup
    private func setupBindings() {
        audioManager.$currentTrack
            .assign(to: &$currentTrack)

        audioManager.$isPlaying
            .assign(to: &$isPlaying)

        audioManager.$currentTime
            .assign(to: &$currentTime)

        audioManager.$duration
            .assign(to: &$duration)

        audioManager.$playerState
            .assign(to: &$playerState)
    }

    private func loadSamplePlaylist() {
        Task {
            await fetchTracks()
            await fetchRadioStations()
        }
    }

    // MARK: - API Methods
    @MainActor
    func fetchTracks() async {
        isLoadingTracks = true
        errorMessage = nil

        do {
            let tracks = try await apiService.fetchTracks()
            playlist = tracks
            originalPlaylist = tracks
            isLoadingTracks = false
        } catch {
            errorMessage = "Failed to load tracks: \(error.localizedDescription)"
            playlist = Track.sampleTracks
            originalPlaylist = Track.sampleTracks
            isLoadingTracks = false
        }
    }

    @MainActor
    func searchTracks(query: String) async {
        guard !query.isEmpty else {
            playlist = originalPlaylist
            return
        }

        isLoadingTracks = true
        errorMessage = nil

        do {
            let tracks = try await apiService.searchTracks(query: query)
            playlist = tracks
            isLoadingTracks = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isLoadingTracks = false
        }
    }

    @MainActor
    func fetchRadioStations() async {
        do {
            radioStations = try await apiService.fetchRadioStations()
        } catch {
            errorMessage = "Failed to load radio stations"
            radioStations = RadioStation.sampleStations
        }
    }

    @MainActor
    func fetchTracksByGenre(genre: String) async {
        isLoadingTracks = true
        errorMessage = nil

        do {
            let tracks = try await apiService.fetchTracksByGenre(genre: genre)
            playlist = tracks
            isLoadingTracks = false
        } catch {
            errorMessage = "Failed to load genre: \(error.localizedDescription)"
            isLoadingTracks = false
        }
    }

    func playRadioStation(_ station: RadioStation) {
        currentRadioStation = station
        let track = Track(
            title: station.name,
            artist: "Live Radio",
            albumArtURL: station.imageURL,
            streamURL: station.streamURL,
            genre: station.genre
        )
        playTrack(track)
    }

    func refreshContent() {
        Task {
            await fetchTracks()
            await fetchRadioStations()
        }
    }

    // MARK: - Playback Controls
    func play() {
        audioManager.play()
    }

    func pause() {
        audioManager.pause()
    }

    func togglePlayPause() {
        audioManager.togglePlayPause()
    }

    func stop() {
        audioManager.stop()
    }

    func seek(to time: TimeInterval) {
        audioManager.seek(to: time)
    }

    func seekToProgress(_ progress: Double) {
        let time = progress * duration
        seek(to: time)
    }

    func skipForward(_ seconds: TimeInterval = 15) {
        audioManager.skipForward(seconds)
    }

    func skipBackward(_ seconds: TimeInterval = 15) {
        audioManager.skipBackward(seconds)
    }

    func setVolume(_ volume: Float) {
        audioManager.setVolume(volume)
    }

    // MARK: - Track Management
    func playTrack(_ track: Track) {
        audioManager.loadTrack(track)
        if let index = playlist.firstIndex(of: track) {
            currentTrackIndex = index
        }
    }

    func playTrackAt(index: Int) {
        guard index >= 0 && index < playlist.count else { return }
        currentTrackIndex = index
        let track = playlist[index]
        audioManager.loadTrack(track)
    }

    func nextTrack() {
        switch repeatMode {
        case .one:
            // Replay current track
            seek(to: 0)
            play()
        case .all:
            if hasNext {
                playTrackAt(index: currentTrackIndex + 1)
            } else {
                // Loop back to first track
                playTrackAt(index: 0)
            }
        case .off:
            if hasNext {
                playTrackAt(index: currentTrackIndex + 1)
            } else {
                stop()
            }
        }
    }

    func previousTrack() {
        // If we're more than 3 seconds into the song, restart it
        if currentTime > 3.0 {
            seek(to: 0)
        } else if hasPrevious {
            playTrackAt(index: currentTrackIndex - 1)
        }
    }

    func toggleShuffle() {
        isShuffled.toggle()
        if isShuffled {
            // Shuffle playlist while keeping current track at current position
            guard currentTrackIndex < playlist.count else { return }
            let currentTrack = playlist[currentTrackIndex]
            var remainingTracks = playlist
            remainingTracks.remove(at: currentTrackIndex)
            remainingTracks.shuffle()
            playlist = [currentTrack] + remainingTracks
            currentTrackIndex = 0
        } else {
            // Restore original order
            playlist = originalPlaylist
            if let track = currentTrack,
               let index = playlist.firstIndex(of: track) {
                currentTrackIndex = index
            }
        }
    }

    func toggleRepeatMode() {
        switch repeatMode {
        case .off:
            repeatMode = .all
        case .all:
            repeatMode = .one
        case .one:
            repeatMode = .off
        }
    }

    // MARK: - Helper Methods
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
