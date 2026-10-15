import Foundation
import ServiceManagement

final class PreferencesManager {
    static let shared = PreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let defaultDuration = "defaultDuration"
        static let preventDisplaySleep = "preventDisplaySleep"
        static let activateOnLaunch = "activateOnLaunch"
    }
    
    private init() {
        defaults.register(defaults: [
            Keys.defaultDuration: 0.0, // 0 = indefinite
            Keys.preventDisplaySleep: true,
            Keys.activateOnLaunch: false
        ])
    }
    
    var defaultDuration: TimeInterval {
        get { defaults.double(forKey: Keys.defaultDuration) }
        set { defaults.set(newValue, forKey: Keys.defaultDuration) }
    }
    
    var preventDisplaySleep: Bool {
        get { defaults.bool(forKey: Keys.preventDisplaySleep) }
        set { defaults.set(newValue, forKey: Keys.preventDisplaySleep) }
    }
    
    var activateOnLaunch: Bool {
        get { defaults.bool(forKey: Keys.activateOnLaunch) }
        set { defaults.set(newValue, forKey: Keys.activateOnLaunch) }
    }
    
    var isLaunchAtLoginEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            }
            return false
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        if SMAppService.mainApp.status != .enabled {
                            try SMAppService.mainApp.register()
                        }
                    } else {
                        if SMAppService.mainApp.status == .enabled {
                            try SMAppService.mainApp.unregister()
                        }
                    }
                } catch {
                    NSLog("Caffeine: Failed to set launch at login: \(error.localizedDescription)")
                }
            }
        }
    }
}
