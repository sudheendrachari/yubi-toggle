import SwiftUI

@main
struct YubiToggleApp: App {
    @StateObject private var viewModel = YubiKeyViewModel()
    @State private var showSettings = false
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: viewModel, showSettings: $showSettings)
        } label: {
            Image(systemName: viewModel.menuBarIcon)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(viewModel.menuBarIconColor)
        }
        
        Window("YubiToggle Settings", id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
