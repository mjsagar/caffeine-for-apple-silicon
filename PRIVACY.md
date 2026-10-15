# Privacy Policy for Caffeine

**Last updated:** October 15, 2026

**Caffeine for Apple Silicon** ("Caffeine", "we", "us", or "our") is an open-source macOS utility developed by Michael Sagar.

### 1. Data Collection & Privacy

Caffeine does **not** collect, store, transmit, or share any personal data, analytics, or user information whatsoever.

- **No Tracking:** We do not track user activity, screen time, or device identifiers.
- **No Analytics:** There are no third-party SDKs, crash reporters, or telemetry frameworks embedded in the app.
- **No Network Requests:** Caffeine does not make network connections or communicate with any external servers. The app works 100% offline.
- **Local Storage:** Caffeine only stores user preferences locally on your Mac using standard macOS `UserDefaults` (such as default keep-awake duration and launch at login preference). This data never leaves your device.

### 2. Permissions & System APIs

Caffeine only interacts with standard macOS system APIs:
- **Power Management (`IOKit.pwr_mgt`):** To register temporary power assertions preventing your display or computer from entering idle sleep mode as explicitly requested by you.
- **Login Items (`ServiceManagement`):** To launch the app upon login only if you explicitly enable "Launch at Login" in the menu.

### 3. Open Source Transparency

Caffeine is open-source software licensed under the MIT License. The complete source code is publicly available for inspection and audit at:
https://github.com/mjsagar/caffeine-for-apple-silicon

### 4. Contact

If you have any questions or feedback regarding this Privacy Policy, please open an issue on the GitHub repository:
https://github.com/mjsagar/caffeine-for-apple-silicon/issues
