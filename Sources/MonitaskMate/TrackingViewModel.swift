import Foundation
import SwiftUI
import AppKit

@MainActor
final class TrackingViewModel: ObservableObject {
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

    init(reminderManager: ReminderManager, floatingCounterManager: FloatingCounterManager) {
        self.reminderManager = reminderManager
        self.floatingCounterManager = floatingCounterManager
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
        format(seconds: snapshot.totalSeconds)
    }

    var statusColor: Color {
        snapshot.isTracking ? .green : .red
    }

    var menuBarIcon: NSImage {
        MenuBarIconFactory.makeIcon(isTracking: snapshot.isTracking)
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
        return String(format: "%dh %02dm", hours, minutes)
    }

    func resetToDefaults() {
        refreshInterval = .oneSecond
        refresh()
    }

    func diagnosticsText(reminderManager: ReminderManager) -> String {
        [
            "Time: \(menuBarTitle)",
            "Status: \(statusText)",
            "Project: \(snapshot.selectedProjectName)",
            "Last Updated: \(lastUpdatedText)",
            "Sync Interval: \(refreshInterval.label)",
            "Reminder Enabled: \(reminderManager.isEnabled ? "yes" : "no")",
            "Reminder Grace: \(reminderManager.gracePeriodMinutes)m",
            "Reminder Cooldown: \(reminderManager.reminderCooldownMinutes)m",
            "Active Threshold: \(reminderManager.activityIdleThresholdSeconds)s"
        ].joined(separator: "\n")
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}
