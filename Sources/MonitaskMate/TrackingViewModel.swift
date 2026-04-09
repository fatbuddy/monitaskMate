import Foundation
import SwiftUI
import AppKit

@MainActor
final class TrackingViewModel: ObservableObject {
    enum CounterDisplayFormat: String, CaseIterable, Identifiable {
        case hoursMinutes = "hm"
        case hoursMinutesSeconds = "hms"

        var id: String { rawValue }

        var label: String {
            switch self {
            case .hoursMinutes:
                return "Hours + Minutes"
            case .hoursMinutesSeconds:
                return "Hours + Minutes + Seconds"
            }
        }

        var description: String {
            switch self {
            case .hoursMinutes:
                return "Shows values like 3h 24m"
            case .hoursMinutesSeconds:
                return "Shows values like 3h 24m 18s"
            }
        }
    }

    enum RefreshInterval: Int, CaseIterable, Identifiable {
        case oneSecond = 1
        case tenSeconds = 10
        case thirtySeconds = 30
        case oneMinute = 60

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .oneSecond:
                return "1 second"
            case .tenSeconds:
                return "10 seconds"
            case .thirtySeconds:
                return "30 seconds"
            case .oneMinute:
                return "1 minute"
            }
        }

        var timerTolerance: TimeInterval {
            switch self {
            case .oneSecond:
                return 0.2
            case .tenSeconds:
                return 1
            case .thirtySeconds:
                return 2
            case .oneMinute:
                return 4
            }
        }
    }

    @Published private(set) var snapshot = TrackingSnapshot(
        isTracking: false,
        totalSeconds: 0,
        activeSeconds: 0,
        selectedProjectName: "Loading",
        lastUpdated: Date()
    )
    @Published private(set) var loadError: String?
    @Published private(set) var menuBarLabelImage: NSImage
    @Published var counterDisplayFormat: CounterDisplayFormat {
        didSet {
            UserDefaults.standard.set(counterDisplayFormat.rawValue, forKey: Self.counterDisplayFormatKey)
            updateMenuBarLabelImage()
            floatingCounterManager.update(title: menuBarTitle, isTracking: snapshot.isTracking)
        }
    }
    @Published var refreshInterval: RefreshInterval {
        didSet {
            UserDefaults.standard.set(refreshInterval.rawValue, forKey: Self.refreshIntervalKey)
            configureTimer()
        }
    }

    private let reader = MonitaskReader()
    private let reminderManager: ReminderManager
    private let floatingCounterManager: FloatingCounterManager
    private var timer: Timer?

    private static let refreshIntervalKey = "tracking.refreshIntervalSeconds"
    private static let counterDisplayFormatKey = "tracking.counterDisplayFormat"

    init(reminderManager: ReminderManager, floatingCounterManager: FloatingCounterManager) {
        self.reminderManager = reminderManager
        self.floatingCounterManager = floatingCounterManager
        menuBarLabelImage = MenuBarLabelFactory.makeLabel(timeText: "00h 00m", isTracking: false, showSeconds: false)
        let storedDisplayFormat = UserDefaults.standard.string(forKey: Self.counterDisplayFormatKey)
        counterDisplayFormat = CounterDisplayFormat(rawValue: storedDisplayFormat ?? "") ?? .hoursMinutes
        let stored = UserDefaults.standard.integer(forKey: Self.refreshIntervalKey)
        refreshInterval = RefreshInterval(rawValue: stored) ?? .oneSecond
        refresh()
        configureTimer()
    }

    private func configureTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval.rawValue), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
        timer?.tolerance = refreshInterval.timerTolerance
    }

    var menuBarTitle: String {
        formatForCounter(seconds: snapshot.totalSeconds)
    }

    var statusColor: Color {
        snapshot.isTracking ? .green : .red
    }

    var statusDot: String {
        snapshot.isTracking ? "🟢" : "🔴"
    }

    var statusText: String {
        snapshot.isTracking ? "Tracking" : "Not Tracking"
    }

    var lastUpdatedText: String {
        Self.timeFormatter.string(from: snapshot.lastUpdated)
    }

    var refreshIntervalText: String {
        refreshInterval.label
    }

    func refresh() {
        do {
            snapshot = try reader.loadSnapshot()
            updateMenuBarLabelImage()
            reminderManager.updateTrackingState(snapshot.isTracking)
            floatingCounterManager.update(title: menuBarTitle, isTracking: snapshot.isTracking)
            loadError = nil
        } catch {
            loadError = "Unable to read Monitask data."
        }
    }

    func format(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let h = String(format: "%02d", min(hours, 99))
        let m = String(format: "%02d", minutes)
        return "\(h)h\u{2006}\(m)m"
    }

    func formatForCounter(seconds: Int) -> String {
        switch counterDisplayFormat {
        case .hoursMinutes:
            return format(seconds: seconds)
        case .hoursMinutesSeconds:
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let secondsPart = seconds % 60
            let h = String(format: "%02d", min(hours, 99))
            let m = String(format: "%02d", minutes)
            let s = String(format: "%02d", secondsPart)
            return "\(h)h\u{2006}\(m)m\u{2006}\(s)s"
        }
    }

    func resetToDefaults() {
        counterDisplayFormat = .hoursMinutes
        refreshInterval = .oneSecond
        refresh()
    }

    func diagnosticsText(reminderManager: ReminderManager) -> String {
        [
            "Time: \(menuBarTitle)",
            "Status: \(statusText)",
            "Project: \(snapshot.selectedProjectName)",
            "Last Updated: \(lastUpdatedText)",
            "Counter Format: \(counterDisplayFormat.label)",
            "Sync Interval: \(refreshInterval.label)",
            "Reminder Enabled: \(reminderManager.isEnabled ? "yes" : "no")",
            "Reminder Grace: \(reminderManager.gracePeriodMinutes)m",
            "Reminder Cooldown: \(reminderManager.reminderCooldownMinutes)m",
            "Active Threshold: \(reminderManager.activityIdleThresholdSeconds)s"
        ].joined(separator: "\n")
    }

    private func updateMenuBarLabelImage() {
        menuBarLabelImage = MenuBarLabelFactory.makeLabel(
            timeText: menuBarTitle,
            isTracking: snapshot.isTracking,
            showSeconds: counterDisplayFormat == .hoursMinutesSeconds
        )
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}
