# Release Checklist

Use this checklist to build and publish a new MonitaskMate release.

## 1) Prepare code

- Ensure `main` is up to date.
- Update `README.md` if needed.
- Bump version in `project.yml`:
  - `MARKETING_VERSION` (example: `0.1.1`)
  - `CURRENT_PROJECT_VERSION` (example: `2`)

Then regenerate project files:

```bash
xcodegen generate
```

## 2) Build archive in Xcode

1. Open `MonitaskMate.xcodeproj`.
2. Select `Any Mac (Apple Silicon, Intel)`.
3. `Product` -> `Archive`.
4. In Organizer, pick latest archive.

## 3) Export app

### Fast internal release

- Click `Distribute App` -> `Copy App`.
- Export `MonitaskMate.app`.
- Zip it:

```bash
ditto -c -k --sequesterRsrc --keepParent "MonitaskMate.app" "MonitaskMate-vX.Y.Z-macOS.zip"
```

### Recommended teammate release

- Click `Distribute App` -> `Developer ID`.
- Complete signing + notarization flow.
- Export notarized `MonitaskMate.app`.
- Zip it with the same `ditto` command above.

## 4) Create GitHub release

1. Open `https://github.com/ckwcfm/monitaskMate/releases`.
2. Click `Draft a new release`.
3. Tag format: `vX.Y.Z`.
4. Title format: `MonitaskMate vX.Y.Z`.
5. Add release notes.
6. Upload `MonitaskMate-vX.Y.Z-macOS.zip`.
7. Publish release.

## 5) Suggested release notes template

```text
## Highlights
- Menu bar tracking time with Monitask icon + status badge
- Improved tracking-state stability
- Smart reminder toggle and snooze controls

## Notes
- MonitaskMate reads local Monitask files only (read-only)
- No external telemetry
```
