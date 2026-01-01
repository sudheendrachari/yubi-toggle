import Foundation
import SwiftUI
import UserNotifications

/// Application state enum
enum AppState: Equatable {
    case loading
    case ready
    case noDevice
    case ykmanMissing
    case error(String)
}

/// Observable ViewModel for YubiKey state management
@MainActor
final class YubiKeyViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var devices: [YubiKeyDevice] = []
    @Published private(set) var appState: AppState = .loading
    @Published private(set) var isToggling: Bool = false
    
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    // MARK: - Computed Properties
    
    /// The first/primary device (MVP strategy)
    var currentDevice: YubiKeyDevice? {
        devices.first
    }
    
    /// Menu bar icon based on current state
    var menuBarIcon: String {
        // Show sync indicator while toggling
        if isToggling {
            return "arrow.triangle.2.circlepath"
        }
        
        switch appState {
        case .loading:
            return "key"
        case .ready:
            if let device = currentDevice {
                return device.otpEnabled ? "key.fill" : "key.slash"
            }
            return "key"
        case .noDevice:
            return "key.slash"
        case .ykmanMissing, .error:
            return "exclamationmark.triangle"
        }
    }
    
    /// Menu bar icon color
    var menuBarIconColor: Color {
        // Blue while syncing
        if isToggling {
            return .blue
        }
        
        switch appState {
        case .ready:
            if let device = currentDevice, device.otpEnabled {
                return .green
            }
            return .secondary
        case .ykmanMissing, .error:
            return .orange
        default:
            return .secondary
        }
    }
    
    /// Status text for menu display
    var statusText: String {
        switch appState {
        case .loading:
            return "Loading..."
        case .ready:
            if let device = currentDevice {
                return device.name
            }
            return "Ready"
        case .noDevice:
            return "No YubiKey detected"
        case .ykmanMissing:
            return "⚠️ ykman not found"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    /// Whether toggling is available
    var canToggle: Bool {
        switch appState {
        case .ready:
            return currentDevice != nil && !isToggling
        default:
            return false
        }
    }
    
    /// Toggle button text
    var toggleButtonText: String {
        if let device = currentDevice {
            return device.otpEnabled ? "Disable OTP" : "Enable OTP"
        }
        return "Toggle OTP"
    }
    
    // MARK: - Private Properties
    
    private let cli = YubiCLI()
    private var pollingTask: Task<Void, Never>?
    private let pollingInterval: TimeInterval = 10.0
    
    // MARK: - Initialization
    
    init() {
        startPolling()
    }
    
    deinit {
        pollingTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Refresh device state
    func refresh() async {
        // Check ykman availability first
        let isAvailable = await cli.isYkmanAvailable()
        
        guard isAvailable else {
            appState = .ykmanMissing
            devices = []
            return
        }
        
        do {
            let fetchedDevices = try await cli.getAllDevices()
            devices = fetchedDevices
            appState = .ready
        } catch YubiCLIError.noDeviceConnected {
            devices = []
            appState = .noDevice
        } catch {
            appState = .error(error.localizedDescription)
        }
    }
    
    /// Toggle OTP for current device
    func toggleOTP() async {
        guard let device = currentDevice,
              let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        
        isToggling = true
        defer { isToggling = false }
        
        let newState = !device.otpEnabled
        
        // Optimistic UI update - immediately reflect the change
        devices[index].otpEnabled = newState
        
        do {
            try await cli.toggleOTP(serial: device.id, enable: newState)
            
            // Send notification if enabled
            if notificationsEnabled {
                await sendStateChangeNotification(enabled: newState)
            }
            
            // Background refresh to confirm state (don't block UI)
            Task {
                try? await Task.sleep(for: .seconds(1))
                await refresh()
            }
        } catch {
            // Revert optimistic update on failure
            devices[index].otpEnabled = !newState
            appState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func startPolling() {
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                try? await Task.sleep(for: .seconds(self?.pollingInterval ?? 10))
            }
        }
    }
    
    private func sendStateChangeNotification(enabled: Bool) async {
        // Note: UNUserNotificationCenter requires a proper .app bundle to work.
        // When running via `swift run`, we just log to console instead.
        // For production distribution, build as .app bundle for notifications to work.
        let message = enabled ? "OTP interface enabled" : "OTP interface disabled"
        print("YubiToggle: \(message)")
    }
}
