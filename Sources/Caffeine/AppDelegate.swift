import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var contextMenu: NSMenu!
    
    private let caffeine = CaffeineManager.shared
    private let preferences = PreferencesManager.shared
    
    // Menu items that need dynamic updates
    private var statusHeaderItem: NSMenuItem!
    private var timerHeaderItem: NSMenuItem!
    private var durationItems: [TimeInterval: NSMenuItem] = [:]
    private var customDurationItem: NSMenuItem!
    private var preventDisplaySleepItem: NSMenuItem!
    private var activateOnLaunchItem: NSMenuItem!
    private var launchAtLoginItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupMenu()
        setupCallbacks()
        
        // Activate on launch if preference is enabled
        if preferences.activateOnLaunch {
            caffeine.activate(duration: preferences.defaultDuration > 0 ? preferences.defaultDuration : nil)
        } else {
            updateUI(isActive: false)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        caffeine.deactivate()
    }
    
    // MARK: - Status Bar Setup
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = IconRenderer.statusIcon(isActive: false)
            button.imagePosition = .imageOnly
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupCallbacks() {
        caffeine.onStateChange = { [weak self] isActive in
            DispatchQueue.main.async {
                self?.updateUI(isActive: isActive)
            }
        }
        
        caffeine.onTimerTick = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateTimerUI()
            }
        }
    }
    
    // MARK: - Click Handling
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        let isRightClick = event.type == .rightMouseUp
        let isModifiedClick = event.modifierFlags.contains(.control) || event.modifierFlags.contains(.option)
        
        if isRightClick || isModifiedClick {
            showContextMenu(at: sender)
        } else {
            // Left click: instant toggle!
            caffeine.toggle()
        }
    }
    
    private func showContextMenu(at button: NSStatusBarButton) {
        updateMenuStates()
        statusItem.menu = contextMenu
        button.performClick(nil)
        statusItem.menu = nil // Reset so next left-click fires action
    }
    
    // MARK: - Menu Setup & Updates
    
    private func setupMenu() {
        contextMenu = NSMenu()
        contextMenu.autoenablesItems = false
        
        // Status indicator row
        statusHeaderItem = NSMenuItem(title: "Caffeine: Inactive", action: nil, keyEquivalent: "")
        statusHeaderItem.isEnabled = false
        contextMenu.addItem(statusHeaderItem)
        
        // Remaining time row (hidden by default)
        timerHeaderItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        timerHeaderItem.isEnabled = false
        timerHeaderItem.isHidden = true
        contextMenu.addItem(timerHeaderItem)
        
        contextMenu.addItem(NSMenuItem.separator())
        
        // Duration section header
        let durationHeader = NSMenuItem(title: "Keep Awake Duration:", action: nil, keyEquivalent: "")
        durationHeader.isEnabled = false
        contextMenu.addItem(durationHeader)
        
        // Presets: Indefinitely (0), 15m, 30m, 1h, 2h, 5h
        let durations: [(String, TimeInterval)] = [
            ("Indefinitely", 0),
            ("15 Minutes", 15 * 60),
            ("30 Minutes", 30 * 60),
            ("1 Hour", 60 * 60),
            ("2 Hours", 120 * 60),
            ("5 Hours", 300 * 60)
        ]
        
        for (title, seconds) in durations {
            let item = NSMenuItem(title: title, action: #selector(durationSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = seconds
            durationItems[seconds] = item
            contextMenu.addItem(item)
        }
        
        customDurationItem = NSMenuItem(title: "Custom Duration...", action: #selector(customDurationSelected(_:)), keyEquivalent: "")
        customDurationItem.target = self
        contextMenu.addItem(customDurationItem)
        
        contextMenu.addItem(NSMenuItem.separator())
        
        // Preferences
        preventDisplaySleepItem = NSMenuItem(
            title: "Prevent Display Sleep",
            action: #selector(togglePreventDisplaySleep(_:)),
            keyEquivalent: ""
        )
        preventDisplaySleepItem.target = self
        contextMenu.addItem(preventDisplaySleepItem)
        
        activateOnLaunchItem = NSMenuItem(
            title: "Activate on Launch",
            action: #selector(toggleActivateOnLaunch(_:)),
            keyEquivalent: ""
        )
        activateOnLaunchItem.target = self
        contextMenu.addItem(activateOnLaunchItem)
        
        launchAtLoginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchAtLoginItem.target = self
        contextMenu.addItem(launchAtLoginItem)
        
        contextMenu.addItem(NSMenuItem.separator())
        
        // About
        let aboutItem = NSMenuItem(title: "About Caffeine", action: #selector(openAbout(_:)), keyEquivalent: "")
        aboutItem.target = self
        contextMenu.addItem(aboutItem)
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit Caffeine", action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self
        contextMenu.addItem(quitItem)
    }
    
    private func updateUI(isActive: Bool) {
        if let button = statusItem.button {
            button.image = IconRenderer.statusIcon(isActive: isActive)
            
            if isActive {
                let durText = caffeine.activeDuration == nil ? "Indefinitely" : (caffeine.formattedRemainingTime ?? "")
                button.toolTip = "Caffeine: Awake (\(durText))\nClick to allow sleep, Right-click for options"
            } else {
                button.toolTip = "Caffeine: Inactive\nClick to keep awake, Right-click for options"
            }
        }
        
        updateMenuStates()
    }
    
    private func updateTimerUI() {
        if caffeine.isActive, let remainingStr = caffeine.formattedRemainingTime {
            timerHeaderItem.title = "⏳ Remaining: \(remainingStr)"
            timerHeaderItem.isHidden = false
            
            if let button = statusItem.button {
                button.toolTip = "Caffeine: Awake (\(remainingStr))\nClick to allow sleep, Right-click for options"
            }
        } else {
            timerHeaderItem.isHidden = true
        }
    }
    
    private func updateMenuStates() {
        let isActive = caffeine.isActive
        
        // Update Status Header
        if isActive {
            if let remainingStr = caffeine.formattedRemainingTime {
                statusHeaderItem.title = "● Caffeine is Active (\(remainingStr))"
                timerHeaderItem.title = "⏳ Time Remaining: \(remainingStr)"
                timerHeaderItem.isHidden = false
            } else {
                statusHeaderItem.title = "● Caffeine is Active (Indefinitely)"
                timerHeaderItem.isHidden = true
            }
        } else {
            statusHeaderItem.title = "○ Caffeine is Inactive"
            timerHeaderItem.isHidden = true
        }
        
        // Update Duration Checkmarks
        let currentDuration = isActive ? (caffeine.activeDuration ?? 0) : preferences.defaultDuration
        var isKnownDuration = false
        
        for (seconds, item) in durationItems {
            let isSelected = (currentDuration == seconds)
            item.state = isSelected ? .on : .off
            if isSelected {
                isKnownDuration = true
            }
        }
        
        customDurationItem.state = (!isKnownDuration && currentDuration > 0) ? .on : .off
        
        // Update Preferences Checkmarks
        preventDisplaySleepItem.state = preferences.preventDisplaySleep ? .on : .off
        activateOnLaunchItem.state = preferences.activateOnLaunch ? .on : .off
        launchAtLoginItem.state = preferences.isLaunchAtLoginEnabled ? .on : .off
    }
    
    // MARK: - Actions
    
    @objc private func durationSelected(_ sender: NSMenuItem) {
        guard let seconds = sender.representedObject as? TimeInterval else { return }
        
        preferences.defaultDuration = seconds
        caffeine.activate(duration: seconds > 0 ? seconds : nil)
    }
    
    @objc private func customDurationSelected(_ sender: NSMenuItem) {
        let alert = NSAlert()
        alert.messageText = "Set Custom Duration"
        alert.informativeText = "Enter duration in minutes to keep your Mac awake:"
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.placeholderString = "e.g. 45"
        input.stringValue = "45"
        alert.accessoryView = input
        
        alert.addButton(withTitle: "Activate")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let minutesText = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if let minutes = Double(minutesText), minutes > 0 {
                let seconds = minutes * 60.0
                preferences.defaultDuration = seconds
                caffeine.activate(duration: seconds)
            }
        }
    }
    
    @objc private func togglePreventDisplaySleep(_ sender: NSMenuItem) {
        preferences.preventDisplaySleep.toggle()
        caffeine.refreshAssertionIfNeeded()
        updateMenuStates()
    }
    
    @objc private func toggleActivateOnLaunch(_ sender: NSMenuItem) {
        preferences.activateOnLaunch.toggle()
        updateMenuStates()
    }
    
    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        preferences.isLaunchAtLoginEnabled.toggle()
        updateMenuStates()
    }
    
    @objc private func openAbout(_ sender: NSMenuItem) {
        AboutWindow.show()
    }
    
    @objc private func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
}
