import SwiftUI

@main
struct MonitaskMateApp: App {
    @StateObject private var viewModel: TrackingViewModel
    @StateObject private var reminderManager: ReminderManager
    @StateObject private var launchAtLoginManager: LaunchAtLoginManager

    init() {
        let reminderManager = ReminderManager()
        let launchAtLoginManager = LaunchAtLoginManager()
        _reminderManager = StateObject(wrappedValue: reminderManager)
        _launchAtLoginManager = StateObject(wrappedValue: launchAtLoginManager)
        _viewModel = StateObject(wrappedValue: TrackingViewModel(reminderManager: reminderManager))
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
                launchAtLoginManager: launchAtLoginManager
            )
                .frame(minWidth: 360, minHeight: 240)
        }
    }
}
