import Foundation
import AppKit
import IOKit.pwr_mgt

final class CaffeineManager {
    static let shared = CaffeineManager()
    
    private(set) var isActive: Bool = false
    private(set) var activeDuration: TimeInterval? = nil // nil = indefinite
    private(set) var targetExpirationDate: Date? = nil
    
    private var assertionID: IOPMAssertionID = 0
    private var countdownTimer: Timer?
    
    var onStateChange: ((Bool) -> Void)?
    var onTimerTick: ((TimeInterval?) -> Void)?
    
    private init() {
        setupSystemSleepNotifications()
    }
    
    deinit {
        deactivate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Toggle & Activation
    
    func toggle() {
        if isActive {
            deactivate()
        } else {
            let prefDuration = PreferencesManager.shared.defaultDuration
            activate(duration: prefDuration > 0 ? prefDuration : nil)
        }
    }
    
    func activate(duration: TimeInterval? = nil) {
        // Release any existing assertion before creating a new one
        releaseAssertion()
        
        let preventDisplay = PreferencesManager.shared.preventDisplaySleep
        let assertionType = preventDisplay ?
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString :
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString
        
        let reason = "Caffeine: Preventing sleep as requested by user" as CFString
        let result = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        
        if result == kIOReturnSuccess {
            isActive = true
            activeDuration = duration
            
            stopTimer()
            if let duration = duration, duration > 0 {
                targetExpirationDate = Date().addingTimeInterval(duration)
                startTimer()
            } else {
                targetExpirationDate = nil
            }
            
            onStateChange?(true)
        } else {
            NSLog("Caffeine: Failed to create power assertion. Result code: \(result)")
            isActive = false
            onStateChange?(false)
        }
    }
    
    func deactivate() {
        releaseAssertion()
        stopTimer()
        
        isActive = false
        activeDuration = nil
        targetExpirationDate = nil
        
        onStateChange?(false)
    }
    
    func refreshAssertionIfNeeded() {
        if isActive {
            let currentRemaining = remainingTime
            let durationToKeep = (currentRemaining != nil && currentRemaining! > 0) ? currentRemaining : activeDuration
            activate(duration: durationToKeep)
        }
    }
    
    // MARK: - Timer & Duration Helpers
    
    var remainingTime: TimeInterval? {
        guard let expiration = targetExpirationDate else { return nil }
        let diff = expiration.timeIntervalSinceNow
        return max(0, diff)
    }
    
    var formattedRemainingTime: String? {
        guard let remaining = remainingTime else { return nil }
        let totalSeconds = Int(ceil(remaining))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    private func startTimer() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let remaining = self.remainingTime {
                if remaining <= 0 {
                    self.deactivate()
                    return
                }
                self.onTimerTick?(remaining)
            }
        }
    }
    
    private func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func releaseAssertion() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
    }
    
    // MARK: - Sleep / Wake Observers
    
    private func setupSystemSleepNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc private func systemWillSleep() {
        // System sleep triggered (e.g. lid closed)
    }
    
    @objc private func systemDidWake() {
        // When waking, verify assertion status
        if isActive {
            if let remaining = remainingTime, remaining <= 0 {
                deactivate()
            } else {
                refreshAssertionIfNeeded()
            }
        }
    }
}
