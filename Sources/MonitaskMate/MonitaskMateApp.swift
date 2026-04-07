import SwiftUI

@main
struct MonitaskMateApp: App {
    @StateObject private var viewModel: TrackingViewModel
    @StateObject private var reminderManager: ReminderManager

    init() {
        let reminderManager = ReminderManager()
        _reminderManager = StateObject(wrappedValue: reminderManager)
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
            ContentView(viewModel: viewModel, reminderManager: reminderManager)
                .frame(minWidth: 360, minHeight: 240)
        }
    }
}
