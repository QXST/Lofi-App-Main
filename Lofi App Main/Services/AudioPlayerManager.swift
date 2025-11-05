//
//  AudioPlayerManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import AVFoundation
import Combine
import MediaPlayer

enum PlayerState {
    case idle
    case loading
    case playing
    case paused
    case stopped
    case error(String)
}

class AudioPlayerManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var currentTrack: Track?
    @Published var playerState: PlayerState = .idle
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.8

    // MARK: - Private Properties
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var playerItem: AVPlayerItem?

    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommands()
        setupNotifications()
    }

    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            playerState = .error("Audio session setup failed")
        }
    }

    // MARK: - Remote Commands (Lock Screen Controls)
    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.skipForward()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.skipBackward()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: event.positionTime)
                return .success
            }
            return .commandFailed
        }
    }

    // MARK: - Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func playerDidFinishPlaying() {
        playerState = .stopped
        isPlaying = false
        currentTime = 0
        // Could implement auto-play next track here
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                play()
            }
        @unknown default:
            break
        }
    }

    // MARK: - Playback Controls
    func loadTrack(_ track: Track) {
        currentTrack = track
        playerState = .loading

        guard let url = URL(string: track.streamURL) else {
            playerState = .error("Invalid URL")
            return
        }

        // Remove old observer
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }

        // Create new player item
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = volume

        // Observe player item status
        playerItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // Setup time observer
        setupTimeObserver()

        // Update Now Playing Info
        updateNowPlayingInfo()

        // Auto-play
        play()
    }

    func play() {
        guard player != nil else { return }
        player?.play()
        isPlaying = true
        playerState = .playing
        updateNowPlayingPlaybackInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        playerState = .paused
        updateNowPlayingPlaybackInfo()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        playerState = .stopped
        currentTime = 0
    }

    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime) { [weak self] _ in
            self?.updateNowPlayingPlaybackInfo()
        }
    }

    func skipForward(_ seconds: TimeInterval = 15) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    func skipBackward(_ seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    func setVolume(_ volume: Float) {
        self.volume = max(0, min(1, volume))
        player?.volume = self.volume
    }

    // MARK: - Time Observer
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds

            // Duration is loaded once in KVO observer when status becomes .readyToPlay
            // No need to load it repeatedly here
        }
    }

    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        do {
                            let duration = try await playerItem.asset.load(.duration)
                            if duration.seconds.isFinite {
                                self.duration = duration.seconds
                            }
                        } catch {
                            print("Failed to load duration: \(error)")
                        }
                    }
                    playerState = .paused
                case .failed:
                    playerState = .error(playerItem.error?.localizedDescription ?? "Unknown error")
                case .unknown:
                    playerState = .loading
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - Now Playing Info
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else { return }

        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        // Load album art asynchronously
        if let artURLString = track.albumArtURL, let artURL = URL(string: artURLString) {
            Task {
                if let data = try? await URLSession.shared.data(from: artURL).0,
                   let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func updateNowPlayingPlaybackInfo() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
