import SwiftUI
import ServiceManagement

/// Settings window with General and About tabs
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 200)
    }
}

// MARK: - General Tab

struct GeneralSettingsTab: View {
    @AppStorage("launchAtLogin") private var launchAtLogin: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @State private var isProperBundle: Bool = false
    
    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .disabled(!isProperBundle)
                .onChange(of: launchAtLogin) { newValue in
                    if isProperBundle {
                        updateLaunchAtLogin(enabled: newValue)
                    }
                }
            
            if !isProperBundle {
                Text("Requires app bundle (not available via swift run)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Toggle("Show Notifications", isOn: $notificationsEnabled)
            
            if !isProperBundle {
                Text("Logs to console in debug mode")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .onAppear {
            checkBundleStatus()
        }
    }
    
    private func checkBundleStatus() {
        // SMAppService requires proper app bundle with valid bundle identifier
        // Check if we're running as a proper .app bundle
        let bundlePath = Bundle.main.bundlePath
        isProperBundle = bundlePath.hasSuffix(".app")
        
        if isProperBundle {
            syncLaunchAtLoginState()
        }
    }
    
    private func updateLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
            launchAtLogin = !enabled
        }
    }
    
    private func syncLaunchAtLoginState() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}

// MARK: - About Tab

struct AboutTab: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            
            Text("YubiToggle")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Version \(appVersion) (\(buildNumber))")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("A minimalist YubiKey OTP toggle utility")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Link(destination: URL(string: "https://github.com/sudheendrachari/yubi-toggle")!) {
                HStack {
                    Image(systemName: "link")
                    Text("View on GitHub")
                }
                .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
