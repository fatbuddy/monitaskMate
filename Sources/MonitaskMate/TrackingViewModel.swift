import Foundation
import SwiftUI
import AppKit

@MainActor
final class TrackingViewModel: ObservableObject {
    @Published private(set) var snapshot = TrackingSnapshot(
        isTracking: false,
        totalSeconds: 0,
        activeSeconds: 0,
        selectedProjectName: "Loading",
        lastUpdated: Date()
    )
    @Published private(set) var loadError: String?

    private let reader = MonitaskReader()
    private let reminderManager: ReminderManager
    private var timer: Timer?

    init(reminderManager: ReminderManager) {
        self.reminderManager = reminderManager
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
        timer?.tolerance = 0.2
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

    func refresh() {
        do {
            snapshot = try reader.loadSnapshot()
            reminderManager.updateTrackingState(snapshot.isTracking)
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

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}
