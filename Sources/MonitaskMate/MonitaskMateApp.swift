import SwiftUI

@main
struct MonitaskMateApp: App {
    @StateObject private var viewModel: TrackingViewModel
    @StateObject private var reminderManager: ReminderManager
    @StateObject private var launchAtLoginManager: LaunchAtLoginManager
    @StateObject private var floatingCounterManager: FloatingCounterManager

    init() {
        let reminderManager = ReminderManager()
        let launchAtLoginManager = LaunchAtLoginManager()
        let floatingCounterManager = FloatingCounterManager()
        _reminderManager = StateObject(wrappedValue: reminderManager)
        _launchAtLoginManager = StateObject(wrappedValue: launchAtLoginManager)
        _floatingCounterManager = StateObject(wrappedValue: floatingCounterManager)
        _viewModel = StateObject(
            wrappedValue: TrackingViewModel(
                reminderManager: reminderManager,
                floatingCounterManager: floatingCounterManager
            )
        )
    }

    var body: some Scene {
        MenuBarExtra {
            MenuPanelView(viewModel: viewModel, reminderManager: reminderManager)
        } label: {
            HStack(spacing: 6) {
                Image(nsImage: viewModel.menuBarIcon)
                Text(viewModel.menuBarTitle)
                    .monospacedDigit()
            }
        }

        Window("MonitaskMate", id: "main") {
            ContentView(
                viewModel: viewModel,
                reminderManager: reminderManager,
                launchAtLoginManager: launchAtLoginManager,
                floatingCounterManager: floatingCounterManager
            )
                .frame(minWidth: 360, minHeight: 240)
        }
    }
}
