import AppKit

enum AboutWindow {
    static func show() {
        let alert = NSAlert()
        alert.messageText = "Caffeine for Apple Silicon"
        alert.informativeText = """
        Version 1.0.0
        
        A lightweight, open-source menu bar utility designed for Apple Silicon (and Intel Macs) to prevent your Mac from sleeping.
        
        • Left-click the menu bar cup to quickly toggle awake on/off.
        • Right-click or Option-click to choose duration or change preferences.
        
        Created with ❤️ by Michael Sagar.
        Released under the MIT License.
        """
        
        // Custom coffee cup icon for the alert
        let icon = IconRenderer.statusIcon(isActive: true)
        icon.size = NSSize(width: 64, height: 64)
        icon.isTemplate = false
        alert.icon = icon
        
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "GitHub Repository")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://github.com/mjsagar/caffeine-for-apple-silicon") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
