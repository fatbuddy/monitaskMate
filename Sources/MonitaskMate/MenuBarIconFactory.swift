import AppKit

enum MenuBarIconFactory {
    static func makeIcon(isTracking: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let iconRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)

        let image = NSImage(size: size)
        image.lockFocus()

        let baseIcon = monitaskBaseIcon(size: size)
        baseIcon.draw(in: iconRect)

        let dotDiameter: CGFloat = 6
        let dotRect = NSRect(x: size.width - dotDiameter, y: 0, width: dotDiameter, height: dotDiameter)
        let dotColor = isTracking ? NSColor.systemGreen : NSColor.systemRed
        dotColor.setFill()
        NSBezierPath(ovalIn: dotRect).fill()

        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    private static func monitaskBaseIcon(size: NSSize) -> NSImage {
        let appPath = "/Applications/Monitask.app"
        let icon = NSWorkspace.shared.icon(forFile: appPath)
        icon.size = size
        icon.isTemplate = false
        return icon
    }
}
