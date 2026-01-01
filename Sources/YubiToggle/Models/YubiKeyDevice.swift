import Foundation

/// Represents a YubiKey device with its properties
struct YubiKeyDevice: Identifiable, Equatable {
    let id: String  // Serial number
    let name: String
    var otpEnabled: Bool
    
    init(serial: String, name: String = "YubiKey", otpEnabled: Bool = false) {
        self.id = serial
        self.name = name
        self.otpEnabled = otpEnabled
    }
}
