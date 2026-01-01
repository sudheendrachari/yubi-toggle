import Foundation

/// Error types for YubiKey CLI operations
enum YubiCLIError: Error, LocalizedError {
    case ykmanNotFound
    case noDeviceConnected
    case commandFailed(String)
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .ykmanNotFound:
            return "ykman not found. Please install YubiKey Manager."
        case .noDeviceConnected:
            return "No YubiKey detected."
        case .commandFailed(let message):
            return "Command failed: \(message)"
        case .parseError(let message):
            return "Parse error: \(message)"
        }
    }
}

/// Async wrapper for ykman CLI operations
actor YubiCLI {
    
    /// Possible paths for ykman binary
    private static let ykmanPaths = [
        "/opt/homebrew/bin/ykman",  // Apple Silicon Homebrew
        "/usr/local/bin/ykman"       // Intel Homebrew
    ]
    
    /// Cached path to ykman binary
    private var cachedYkmanPath: String?
    
    /// Find the ykman binary path
    func findYkmanPath() -> String? {
        if let cached = cachedYkmanPath {
            return cached
        }
        
        for path in Self.ykmanPaths {
            if FileManager.default.isExecutableFile(atPath: path) {
                cachedYkmanPath = path
                return path
            }
        }
        return nil
    }
    
    /// Check if ykman is available
    func isYkmanAvailable() -> Bool {
        return findYkmanPath() != nil
    }
    
    /// Execute a ykman command and return output
    private func execute(_ arguments: [String]) async throws -> String {
        guard let ykmanPath = findYkmanPath() else {
            throw YubiCLIError.ykmanNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: ykmanPath)
            process.arguments = arguments
            
            let pipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = pipe
            process.standardError = errorPipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                if process.terminationStatus == 0 {
                    let output = String(data: data, encoding: .utf8) ?? ""
                    continuation.resume(returning: output)
                } else {
                    let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                    continuation.resume(throwing: YubiCLIError.commandFailed(errorOutput))
                }
            } catch {
                continuation.resume(throwing: YubiCLIError.commandFailed(error.localizedDescription))
            }
        }
    }
    
    /// List connected YubiKey serial numbers
    func listDevices() async throws -> [String] {
        let output = try await execute(["list", "--serials"])
        let serials = output
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return serials
    }
    
    /// Get device info for a specific serial
    func getDeviceInfo(serial: String) async throws -> (name: String, otpEnabled: Bool) {
        let output = try await execute(["--device", serial, "info"])
        
        // Parse device name from first line (e.g., "Device type: YubiKey 5C Nano")
        var deviceName = "YubiKey"
        if let deviceTypeLine = output.components(separatedBy: .newlines)
            .first(where: { $0.contains("Device type:") }) {
            let parts = deviceTypeLine.components(separatedBy: ":")
            if parts.count >= 2 {
                deviceName = parts[1].trimmingCharacters(in: .whitespaces)
            }
        }
        
        // Check if OTP is enabled (look for "Yubico OTP" followed by "Enabled")
        // Format: "Yubico OTP          Enabled"
        let otpEnabled = output.contains("OTP") && 
                         output.range(of: "OTP\\s+Enabled", options: .regularExpression) != nil
        
        return (deviceName, otpEnabled)
    }
    
    /// Get all connected devices with their info
    func getAllDevices() async throws -> [YubiKeyDevice] {
        let serials = try await listDevices()
        
        if serials.isEmpty {
            throw YubiCLIError.noDeviceConnected
        }
        
        var devices: [YubiKeyDevice] = []
        for serial in serials {
            do {
                let info = try await getDeviceInfo(serial: serial)
                devices.append(YubiKeyDevice(
                    serial: serial,
                    name: info.name,
                    otpEnabled: info.otpEnabled
                ))
            } catch {
                // If we can't get info for a device, add it with defaults
                devices.append(YubiKeyDevice(serial: serial))
            }
        }
        
        return devices
    }
    
    /// Enable OTP interface for a device
    func enableOTP(serial: String) async throws {
        _ = try await execute(["--device", serial, "config", "usb", "--enable", "OTP", "--force"])
    }
    
    /// Disable OTP interface for a device
    func disableOTP(serial: String) async throws {
        _ = try await execute(["--device", serial, "config", "usb", "--disable", "OTP", "--force"])
    }
    
    /// Toggle OTP interface for a device
    func toggleOTP(serial: String, enable: Bool) async throws {
        if enable {
            try await enableOTP(serial: serial)
        } else {
            try await disableOTP(serial: serial)
        }
    }
}
