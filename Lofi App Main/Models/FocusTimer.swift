//
//  FocusTimer.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation

enum TimerState {
    case idle
    case running
    case paused
    case completed
}

struct FocusTimer {
    var duration: TimeInterval
    var remainingTime: TimeInterval
    var state: TimerState
    var startTime: Date?
    var pauseTime: Date?

    init(duration: TimeInterval) {
        self.duration = duration
        self.remainingTime = duration
        self.state = .idle
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return 1.0 - (remainingTime / duration)
    }

    var formattedRemaining: String {
        let hours = Int(remainingTime) / 3600
        let minutes = (Int(remainingTime) % 3600) / 60
        let seconds = Int(remainingTime) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Focus Presets
enum FocusPreset: String, CaseIterable, Identifiable {
    case pomodoro = "Pomodoro"
    case study = "Study Session"
    case deepWork = "Deep Work"
    case sleep = "Sleep"
    case meditation = "Meditation"
    case shortBreak = "Short Break"

    var id: String { rawValue }

    var duration: TimeInterval {
        switch self {
        case .pomodoro:
            return 25 * 60 // 25 minutes
        case .study:
            return 50 * 60 // 50 minutes
        case .deepWork:
            return 90 * 60 // 90 minutes
        case .sleep:
            return 60 * 60 // 1 hour
        case .meditation:
            return 10 * 60 // 10 minutes
        case .shortBreak:
            return 5 * 60 // 5 minutes
        }
    }

    var icon: String {
        switch self {
        case .pomodoro:
            return "timer"
        case .study:
            return "book.fill"
        case .deepWork:
            return "brain.head.profile"
        case .sleep:
            return "moon.stars.fill"
        case .meditation:
            return "figure.mind.and.body"
        case .shortBreak:
            return "cup.and.saucer.fill"
        }
    }

    var description: String {
        switch self {
        case .pomodoro:
            return "Focus for 25 minutes"
        case .study:
            return "Study session for 50 minutes"
        case .deepWork:
            return "Deep focus for 90 minutes"
        case .sleep:
            return "Relax for 1 hour"
        case .meditation:
            return "Mindful break for 10 minutes"
        case .shortBreak:
            return "Quick 5-minute break"
        }
    }

    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .pomodoro:
            return (0.9, 0.4, 0.4) // Red
        case .study:
            return (0.5, 0.6, 1.0) // Blue (primary)
        case .deepWork:
            return (0.6, 0.4, 0.9) // Purple
        case .sleep:
            return (0.4, 0.5, 0.7) // Dark blue
        case .meditation:
            return (0.5, 0.8, 0.6) // Green
        case .shortBreak:
            return (1.0, 0.8, 0.4) // Yellow
        }
    }
}

// MARK: - Focus Session (for tracking)
struct FocusSession: Identifiable, Codable {
    let id: UUID
    let preset: String
    let duration: TimeInterval
    let completedAt: Date
    let completed: Bool // Did they finish the whole session?

    init(
        id: UUID = UUID(),
        preset: String,
        duration: TimeInterval,
        completedAt: Date = Date(),
        completed: Bool
    ) {
        self.id = id
        self.preset = preset
        self.duration = duration
        self.completedAt = completedAt
        self.completed = completed
    }
}
