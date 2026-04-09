import AppKit

enum MenuBarLabelFactory {
    static func makeLabel(timeText: String, isTracking: Bool, showSeconds: Bool) -> NSImage {
        let icon = MenuBarIconFactory.makeIcon(isTracking: isTracking)
        let size = NSSize(width: showSeconds ? 108 : 80, height: 18)
        let image = NSImage(size: size)

        image.lockFocus()
        let iconRect = NSRect(x: 0, y: 1, width: 16, height: 16)
        icon.draw(in: iconRect)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byClipping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 12.5, weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle
        ]

        let textRect = NSRect(x: 22, y: 1, width: size.width - 22, height: 16)
        NSString(string: timeText).draw(in: textRect, withAttributes: attributes)

        image.unlockFocus()
        image.isTemplate = false
        return image
    }
}
