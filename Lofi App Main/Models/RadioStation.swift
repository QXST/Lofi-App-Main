//
//  RadioStation.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation

struct RadioStation: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let streamURL: String
    let imageURL: String?
    let genre: String
    let description: String?
    let isLive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        streamURL: String,
        imageURL: String? = nil,
        genre: String = "Lofi",
        description: String? = nil,
        isLive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.streamURL = streamURL
        self.imageURL = imageURL
        self.genre = genre
        self.description = description
        self.isLive = isLive
    }

    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        lhs.id == rhs.id
    }
}

// Sample radio stations
extension RadioStation {
    static let sampleStations: [RadioStation] = [
        RadioStation(
            name: "Lofi Girl Radio",
            streamURL: "https://streams.ilovemusic.de/iloveradio17.mp3",
            imageURL: "https://picsum.photos/400/400?random=10",
            genre: "Lofi Hip Hop",
            description: "24/7 lofi hip hop beats to relax/study to"
        ),
        RadioStation(
            name: "ChillHop Radio",
            streamURL: "https://streams.ilovemusic.de/iloveradio2.mp3",
            imageURL: "https://picsum.photos/400/400?random=11",
            genre: "Chillhop",
            description: "Chill beats and smooth jazz"
        ),
        RadioStation(
            name: "Ambient Sounds",
            streamURL: "https://streams.ilovemusic.de/iloveradio1.mp3",
            imageURL: "https://picsum.photos/400/400?random=12",
            genre: "Ambient",
            description: "Peaceful ambient music for sleep and focus"
        )
    ]
}

// MARK: - API Response Models
struct TracksResponse: Codable {
    let tracks: [TrackDTO]
    let total: Int
    let page: Int
}

struct TrackDTO: Codable {
    let id: String
    let title: String
    let artist: String
    let albumArt: String?
    let streamUrl: String
    let duration: Double
    let genre: String

    func toTrack() -> Track {
        Track(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            artist: artist,
            albumArtURL: albumArt,
            streamURL: streamUrl,
            duration: duration,
            genre: genre
        )
    }
}

struct PlaylistResponse: Codable {
    let id: String
    let name: String
    let description: String?
    let tracks: [TrackDTO]
    let imageUrl: String?
}

struct RadioStationsResponse: Codable {
    let stations: [RadioStationDTO]
}

struct RadioStationDTO: Codable {
    let id: String
    let name: String
    let streamUrl: String
    let imageUrl: String?
    let genre: String
    let description: String?

    func toRadioStation() -> RadioStation {
        RadioStation(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            streamURL: streamUrl,
            imageURL: imageUrl,
            genre: genre,
            description: description,
            isLive: true
        )
    }
}
