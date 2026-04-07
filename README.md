# MonitaskMate

MonitaskMate is a standalone macOS menu bar companion for Monitask.

It reads your local Monitask data (read-only), shows current tracked time in the menu bar, and gives optional smart reminders when you are active on your Mac but Monitask is not running.

## Why this exists

Teams often forget to start Monitask and end up with untracked work.

MonitaskMate helps by making tracking status visible at all times:

- `icon + time` in the menu bar
- green indicator when tracking is active
- red indicator when tracking is inactive
- optional reminder + snooze controls

## Features

- Live menu bar time display (tabular digits for stable width)
- Monitask app icon in menu bar with status badge
- Auto-refresh every second
- Main app window with tracking details
- Smart reminder (default OFF)
  - only triggers when keyboard/mouse activity is detected
  - reminder appears when active but Monitask is not tracking
  - snooze options: 15m, 30m, 60m

## How it works

MonitaskMate does **not** modify Monitask. It reads local files:

- `~/Library/Application Support/Monitask/ProjectInfo.json`
- `~/Library/Application Support/Monitask/Settings.json`
- `~/Library/Application Support/Monitask/Periods/*.json`
- `~/Library/Application Support/Monitask/Logs/*.txt` (fallback for faster resume detection)

Tracking state is inferred from recent period updates and recent tracking start log events.

## Requirements

- macOS 13+
- Xcode 15+ (for development/build)
- Monitask installed and used on the same Mac

## Run locally

1. Open `MonitaskMate.xcodeproj` in Xcode.
2. Select the `MonitaskMate` scheme.
3. Press `Cmd+R`.

Or build from terminal:

```bash
xcodebuild -project "MonitaskMate.xcodeproj" -scheme "MonitaskMate" -configuration Debug -destination 'platform=macOS' build
```

## Menu controls

- `Smart Reminder` toggle: turn reminders on/off
- `15m / 30m / 60m`: snooze reminders temporarily
- `Refresh`: force immediate data refresh
- `Open App`: bring the main MonitaskMate window to front

## Reminder behavior

- Off by default
- When enabled, reminder checks run periodically
- Reminder triggers only if:
  - user is active (keyboard/mouse), and
  - Monitask appears not tracking for a grace period

macOS will ask for notification permission when enabling reminders.

## Privacy

- Local-only data access
- No external API calls
- No telemetry
- No Monitask file writes

## Known limitations

- Resume detection may still have a short delay depending on Monitask file/log update timing.
- Menu bar text color is system-controlled by macOS; status color is shown on the icon badge.

## Project structure

- `Sources/MonitaskMate/MonitaskMateApp.swift` - app entry and scenes
- `Sources/MonitaskMate/TrackingViewModel.swift` - UI state + refresh logic
- `Sources/MonitaskMate/MonitaskReader.swift` - Monitask file/log parsing
- `Sources/MonitaskMate/MenuBarIconFactory.swift` - menu bar icon rendering
- `Sources/MonitaskMate/ReminderManager.swift` - reminder + snooze logic
- `Sources/MonitaskMate/ContentView.swift` - window and menu panel UI

## GitHub

Repository: `https://github.com/ckwcfm/monitaskMate`
