# 🔐 YubiToggle

A minimal macOS menu bar utility to toggle your YubiKey's OTP interface on and off. **A modern, native alternative to YubiSwitch.**

Prevent accidental OTP spam `cccccc...` in apps like Slack while keeping your key ready for intentional use.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-6.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **One-Click Toggle** — Enable or disable OTP from your menu bar
- **Visual Status** — Green key (enabled), gray key (disabled), warning (error)
- **Hardware Sync** — Auto-refreshes every 10 seconds to stay in sync
- **Launch at Login** — Start automatically when you log in
- **Notifications** — Optional system notifications on state changes
- **Universal Binary** — Runs natively on Apple Silicon and Intel Macs

## 📋 Requirements

- **macOS 13.0** (Ventura) or later
- **[YubiKey Manager CLI](https://www.yubico.com/support/download/yubikey-manager/)** (`ykman`)

### Installing ykman

```bash
# Homebrew (recommended)
brew install ykman

# Or download from Yubico
# https://www.yubico.com/support/download/yubikey-manager/
```

## 📥 Installation

### Homebrew (Recommended)

```bash
brew tap sudheendrachari/tap
brew install --cask yubitoggle
```

### Manual Download

1. Go to [Releases](https://github.com/sudheendrachari/yubi-toggle/releases)
2. Download `YubiToggle.dmg`
3. Open the DMG and drag `YubiToggle.app` to Applications

> ⚠️ **First Launch**: Since the app isn't notarized, macOS will block it.
> Go to **System Settings → Privacy & Security**, scroll down, and click **"Open Anyway"** next to the YubiToggle message. This is only needed once.

### Build from Source

```bash
git clone https://github.com/sudheendrachari/yubi-toggle.git
cd yubi-toggle
swift build -c release
swift run YubiToggle
```

## 🚀 Usage

1. **Click the menu bar icon** — Shows your YubiKey name and OTP status
2. **Toggle OTP** — Click "Enable OTP" or "Disable OTP"
3. **Settings** — Configure launch at login and notifications

### Menu Bar Icons

| Icon | Meaning |
|------|---------|
| 🟢 `key.fill` | OTP Enabled |
| ⚪ `key.slash` | OTP Disabled |
| 🔵 `↻` | Syncing with hardware |
| 🟠 `⚠️` | Error (ykman missing or no device) |

## 🏗️ Project Structure

```
YubiToggle/
├── Package.swift
└── Sources/YubiToggle/
    ├── YubiToggleApp.swift      # App entry point
    ├── CLI/YubiCLI.swift        # Async ykman wrapper
    ├── Models/YubiKeyDevice.swift
    ├── ViewModels/YubiKeyViewModel.swift
    └── Views/
        ├── MenuBarView.swift
        └── SettingsView.swift
```

## 🔧 How It Works

YubiToggle wraps the `ykman` CLI to control your YubiKey's USB interface:

```bash
# Check OTP status
ykman info

# Disable OTP
ykman config usb --disable OTP --force

# Enable OTP
ykman config usb --enable OTP --force
```

The app runs as a menu bar extra (`MenuBarExtra`) with no Dock icon.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [Yubico](https://www.yubico.com/) for YubiKey and ykman
- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
