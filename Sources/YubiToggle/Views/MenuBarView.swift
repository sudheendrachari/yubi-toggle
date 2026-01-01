import SwiftUI

/// Menu bar dropdown content view
struct MenuBarView: View {
    @ObservedObject var viewModel: YubiKeyViewModel
    @Binding var showSettings: Bool
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status Section
            statusSection
            
            Divider()
            
            // Toggle Button
            toggleSection
            
            Divider()
            
            // Footer
            footerSection
        }
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private var statusSection: some View {
        HStack {
            Image(systemName: viewModel.menuBarIcon)
                .foregroundStyle(viewModel.menuBarIconColor)
            Text(viewModel.statusText)
                .font(.headline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        
        if case .ykmanMissing = viewModel.appState {
            Link(destination: URL(string: "https://www.yubico.com/support/download/yubikey-manager/")!) {
                HStack {
                    Image(systemName: "arrow.up.forward.app")
                    Text("Install YubiKey Manager")
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private var toggleSection: some View {
        Button(action: {
            Task {
                await viewModel.toggleOTP()
            }
        }) {
            HStack {
                Image(systemName: viewModel.currentDevice?.otpEnabled == true ? "power.circle" : "power.circle.fill")
                Text(viewModel.toggleButtonText)
            }
        }
        .disabled(!viewModel.canToggle)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .keyboardShortcut("t", modifiers: .command)
    }
    
    @ViewBuilder
    private var footerSection: some View {
        Button(action: {
            Task {
                await viewModel.refresh()
            }
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Refresh")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .keyboardShortcut("r", modifiers: .command)
        
        Button(action: {
            openWindow(id: "settings")
            // Ensure the window comes to front after it's created
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.activate(ignoringOtherApps: true)
                for window in NSApp.windows where window.title == "YubiToggle Settings" {
                    window.makeKeyAndOrderFront(nil)
                    window.orderFrontRegardless()
                }
            }
        }) {
            HStack {
                Image(systemName: "gear")
                Text("Settings...")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .keyboardShortcut(",", modifiers: .command)
        
        Divider()
        
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
            HStack {
                Image(systemName: "xmark.circle")
                Text("Quit YubiToggle")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .keyboardShortcut("q", modifiers: .command)
    }
}
