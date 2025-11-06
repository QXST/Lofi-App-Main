//
//  MusicChannel.swift
//  Lofi App Main
//
//  Created by Quest on 11/6/25.
//

import Foundation

enum MusicChannel: String, CaseIterable, Identifiable {
    case sleep = "Sleep"
    case deepWork = "Deep Work"
    case study = "Study"
    case chill = "Chill"
    case ambient = "Ambient"
    case relax = "Relax"
    case jazz = "Jazz"
    case calm = "Calm"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .sleep:
            return "moon.stars.fill"
        case .deepWork:
            return "brain.head.profile"
        case .study:
            return "book.fill"
        case .chill:
            return "snowflake"
        case .ambient:
            return "waveform"
        case .relax:
            return "leaf.fill"
        case .jazz:
            return "music.note"
        case .calm:
            return "sparkles"
        }
    }

    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .sleep:
            return (0.4, 0.3, 0.7) // Purple
        case .deepWork:
            return (0.9, 0.3, 0.4) // Red
        case .study:
            return (0.3, 0.6, 0.9) // Blue
        case .chill:
            return (0.4, 0.7, 0.9) // Light Blue
        case .ambient:
            return (0.5, 0.8, 0.6) // Mint
        case .relax:
            return (0.4, 0.8, 0.5) // Green
        case .jazz:
            return (0.9, 0.6, 0.3) // Orange
        case .calm:
            return (0.7, 0.5, 0.9) // Lavender
        }
    }

    var genre: String {
        switch self {
        case .sleep:
            return "sleep"
        case .deepWork:
            return "deep-work"
        case .study:
            return "study"
        case .chill:
            return "chill"
        case .ambient:
            return "ambient"
        case .relax:
            return "relax"
        case .jazz:
            return "jazz"
        case .calm:
            return "calm"
        }
    }

    var description: String {
        switch self {
        case .sleep:
            return "Peaceful sounds for restful sleep"
        case .deepWork:
            return "Focus music for deep concentration"
        case .study:
            return "Perfect background for studying"
        case .chill:
            return "Relaxed vibes to unwind"
        case .ambient:
            return "Atmospheric soundscapes"
        case .relax:
            return "Gentle music to calm your mind"
        case .jazz:
            return "Smooth jazz and lofi beats"
        case .calm:
            return "Serene tracks for peace"
        }
    }
}
