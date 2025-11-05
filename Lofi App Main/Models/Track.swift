//
//  Track.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation

struct Track: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let artist: String
    let albumArtURL: String?
    let streamURL: String
    let duration: TimeInterval
    let genre: String

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        albumArtURL: String? = nil,
        streamURL: String,
        duration: TimeInterval = 0,
        genre: String = "Lofi"
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumArtURL = albumArtURL
        self.streamURL = streamURL
        self.duration = duration
        self.genre = genre
    }

    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

// Sample data for testing
extension Track {
    static let sampleTracks: [Track] = [
        Track(
            title: "Neighbourhood",
            artist: "Colombo & Massaman",
            albumArtURL: "https://picsum.photos/400/400?blur=2",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            duration: 180,
            genre: "College Music"
        ),
        Track(
            title: "Midnight Dreams",
            artist: "Lofi Collective",
            albumArtURL: "https://picsum.photos/400/400?blur=2&random=2",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
            duration: 210,
            genre: "Lofi Hip Hop"
        ),
        Track(
            title: "Study Session",
            artist: "Chill Beats",
            albumArtURL: "https://picsum.photos/400/400?blur=2&random=3",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
            duration: 195,
            genre: "Focus Music"
        )
    ]
}
