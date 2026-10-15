# ☕ Caffeine for Apple Silicon

[![Platform](https://img.shields.io/badge/Platform-macOS%2011%2B-blue.svg)](https://apple.com/macos)
[![Architecture](https://img.shields.io/badge/Architecture-Apple%20Silicon%20(Universal)-brightgreen.svg)](https://apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)](https://github.com/mjsagar/caffeine-for-apple-silicon/actions)

A lightweight, modern, open-source clone of the beloved classic **Caffeine** app, built natively in Swift for Apple Silicon (M1/M2/M3/M4) and Intel Macs.

---

## ✨ Features

- **⚡ Instant 1-Click Toggle:**
  - **Left-click** the coffee cup icon to toggle awake state instantly on or off.
- **☕ Classic Visual Feedback:**
  - **Inactive:** Empty coffee cup outline.
  - **Active:** Full cup of rich coffee with warm steam curls rising into the air.
  - Automatically adapts to macOS Light and Dark mode using native template rendering.
- **⏱️ Flexible Awake Durations:**
  - Indefinitely (default)
  - 15 Minutes
  - 30 Minutes
  - 1 Hour
  - 2 Hours
  - 5 Hours
  - Custom duration (specify any number of minutes!)
  - Live countdown timer displayed directly in the menu.
- **🛡️ Robust Power Management:**
  - Uses native macOS IOKit power assertions (`IOPMAssertionCreateWithName`).
  - Option to prevent display sleep or system sleep only.
  - Gracefully releases assertions on quit or when machine lid closes.
- **🚀 Menu-Bar Only & Featherlight:**
  - No dock icon, no distracting windows (`LSUIElement = true`).
  - Uses less than 15 MB of RAM and ~0% CPU.
- **🔄 Launch at Login:**
  - Seamless login item integration using modern macOS `SMAppService`.

---

## 📸 Menu & Controls

```
               [ ☕ ]  <- Click to Toggle On/Off
                 │
                 ├── ● Caffeine is Active (24m 12s)
                 ├── ⏳ Time Remaining: 24m 12s
                 ├─────────────────────────────
                 │  Keep Awake Duration:
                 ├── ○ Indefinitely
                 ├── ○ 15 Minutes
                 ├── ✓ 30 Minutes
                 ├── ○ 1 Hour
                 ├── ○ 2 Hours
                 ├── ○ 5 Hours
                 ├── ○ Custom Duration...
                 ├─────────────────────────────
                 ├── [✓] Prevent Display Sleep
                 ├── [ ] Activate on Launch
                 ├── [✓] Launch at Login
                 ├─────────────────────────────
                 ├── About Caffeine
                 └── Quit Caffeine (⌘Q)
```

- **Left-Click:** Toggle awake state immediately.
- **Right-Click / Option-Click / Control-Click:** Open the options menu.

---

## 📥 Installation

### Option 1: Download Prebuilt Release (Recommended)

1. Go to the [Releases](https://github.com/mjsagar/caffeine-for-apple-silicon/releases) page.
2. Download `Caffeine-v1.0.0-macOS.zip` (or `.dmg`).
3. Unzip and drag `Caffeine.app` to your `/Applications` folder.
4. Launch **Caffeine** from `/Applications` or Spotlight!

> **Note on macOS Gatekeeper:**
> Because this is an open-source binary built by the community without an Apple Developer certificate, macOS might show a warning on first launch. If prompted, right-click `Caffeine.app` and choose **Open**, or run this command in Terminal:
> ```bash
> xattr -cr /Applications/Caffeine.app
> ```

---

### Option 2: One-Line Terminal Install

```bash
curl -sL https://github.com/mjsagar/caffeine-for-apple-silicon/releases/latest/download/Caffeine-v1.0.0-macOS.zip -o /tmp/Caffeine.zip && \
unzip -q -o /tmp/Caffeine.zip -d /Applications/ && \
xattr -cr /Applications/Caffeine.app && \
open /Applications/Caffeine.app
```

---

### Option 3: Build from Source

Requirements: macOS 11.0+, Xcode Command Line Tools (`xcode-select --install`).

```bash
# 1. Clone the repository
git clone https://github.com/mjsagar/caffeine-for-apple-silicon.git
cd caffeine-for-apple-silicon

# 2. Build and install to /Applications
make install

# 3. Launch the app
open /Applications/Caffeine.app
```

#### Available Makefile Targets:
- `make app`: Compiles the Universal binary and builds `Caffeine.app`.
- `make zip`: Creates a compressed distributable archive in `dist/`.
- `make dmg`: Creates a distributable DMG disk image in `dist/`.
- `make run`: Builds and runs Caffeine locally.
- `make install`: Copies `Caffeine.app` into `/Applications`.
- `make clean`: Cleans build and distribution artifacts.

---

## 🛠️ How It Works

Caffeine prevents your Mac from sleeping by registering a high-priority power assertion with the macOS IOKit power management daemon (`pmset` / `IOKit.pwr_mgt`):

```swift
let result = IOPMAssertionCreateWithName(
    kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
    IOPMAssertionLevel(kIOPMAssertionLevelOn),
    "Caffeine: Preventing sleep as requested by user" as CFString,
    &assertionID
)
```

You can verify that Caffeine is actively keeping your machine awake at any time by running:
```bash
pmset -g assertions
```
Look for `PreventUserIdleDisplaySleep named: "Caffeine: Preventing sleep as requested by user"`.

---

## 🤝 Contributing

Contributions, bug reports, and feature requests are welcome!
Feel free to open an issue or submit a pull request on GitHub.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

Copyright © 2026 Michael Sagar.
