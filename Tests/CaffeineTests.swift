import Foundation
import IOKit.pwr_mgt

@main
struct CaffeineTests {
    static func main() {
        print("Testing IOPMAssertion creation...")
        var assertionID: IOPMAssertionID = 0
        let reason = "Test assertion" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        assert(result == kIOReturnSuccess, "IOPMAssertionCreateWithName failed with \(result)")
        assert(assertionID != 0, "Assertion ID should not be 0")
        print("Assertion created successfully with ID: \(assertionID)")
        
        let releaseResult = IOPMAssertionRelease(assertionID)
        assert(releaseResult == kIOReturnSuccess, "IOPMAssertionRelease failed with \(releaseResult)")
        print("Assertion released successfully")
        
        print("All tests passed! ✅")
    }
}
