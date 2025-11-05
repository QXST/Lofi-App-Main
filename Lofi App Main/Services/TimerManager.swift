//
//  TimerManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import Foundation
import Combine
import UserNotifications

class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentTimer: FocusTimer?
    @Published var sessions: [FocusSession] = []
    @Published var currentPreset: FocusPreset?

    // MARK: - Private Properties
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var isRunning: Bool {
        currentTimer?.state == .running
    }

    var isPaused: Bool {
        currentTimer?.state == .paused
    }

    var hasActiveTimer: Bool {
        currentTimer != nil && currentTimer?.state != .completed
    }

    // MARK: - Initialization
    init() {
        loadSessions()
        requestNotificationPermission()
    }

    // MARK: - Timer Control
    func startTimer(preset: FocusPreset) {
        currentPreset = preset
        currentTimer = FocusTimer(duration: preset.duration)
        currentTimer?.state = .running
        currentTimer?.startTime = Date()

        startCountdown()
    }

    func startCustomTimer(duration: TimeInterval) {
        currentPreset = nil
        currentTimer = FocusTimer(duration: duration)
        currentTimer?.state = .running
        currentTimer?.startTime = Date()

        startCountdown()
    }

    func pauseTimer() {
        guard currentTimer?.state == .running else { return }

        currentTimer?.state = .paused
        currentTimer?.pauseTime = Date()
        timer?.invalidate()
        timer = nil
    }

    func resumeTimer() {
        guard currentTimer?.state == .paused else { return }

        currentTimer?.state = .running
        currentTimer?.pauseTime = nil
        startCountdown()
    }

    func stopTimer(completed: Bool = false) {
        timer?.invalidate()
        timer = nil

        if let currentTimer = currentTimer, let preset = currentPreset {
            // Save session
            let session = FocusSession(
                preset: preset.rawValue,
                duration: currentTimer.duration - currentTimer.remainingTime,
                completed: completed
            )
            sessions.insert(session, at: 0)
            saveSessions()
        }

        currentTimer = nil
        currentPreset = nil

        // Cancel any pending notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timer_completed"])
    }

    func addTime(_ seconds: TimeInterval) {
        guard var timer = currentTimer else { return }
        timer.remainingTime += seconds
        timer.duration += seconds
        currentTimer = timer
    }

    // MARK: - Private Methods
    private func startCountdown() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, var currentTimer = self.currentTimer else { return }

            if currentTimer.remainingTime > 0 {
                currentTimer.remainingTime -= 1
                self.currentTimer = currentTimer
            } else {
                self.completeTimer()
            }
        }

        // Schedule notification for when timer completes
        scheduleCompletionNotification()
    }

    private func completeTimer() {
        timer?.invalidate()
        timer = nil

        currentTimer?.state = .completed
        currentTimer?.remainingTime = 0

        // Trigger notification
        sendCompletionNotification()

        // Save completed session
        if let currentTimer = currentTimer, let preset = currentPreset {
            let session = FocusSession(
                preset: preset.rawValue,
                duration: currentTimer.duration,
                completed: true
            )
            sessions.insert(session, at: 0)
            saveSessions()
        }

        // Auto-clear after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.currentTimer = nil
            self?.currentPreset = nil
        }
    }

    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleCompletionNotification() {
        guard let remainingTime = currentTimer?.remainingTime else { return }

        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Great job! You've completed your \(currentPreset?.rawValue ?? "focus") session."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingTime, repeats: false)
        let request = UNNotificationRequest(identifier: "timer_completed", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    private func sendCompletionNotification() {
        // In-app notification (could trigger a sound or haptic)
        // This is called when timer actually completes
    }

    // MARK: - Session Persistence
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "focus_sessions")
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "focus_sessions"),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }

    // MARK: - Statistics
    func totalFocusTime() -> TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }

    func completedSessionsCount() -> Int {
        sessions.filter { $0.completed }.count
    }

    func todaysFocusTime() -> TimeInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return sessions
            .filter { calendar.startOfDay(for: $0.completedAt) == today }
            .reduce(0) { $0 + $1.duration }
    }
}
