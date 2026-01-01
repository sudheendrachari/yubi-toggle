// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YubiToggle",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "YubiToggle", targets: ["YubiToggle"])],
    targets: [
        .executableTarget(
            name: "YubiToggle",
            path: "Sources/YubiToggle",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/YubiToggle/Resources/Info.plist"
                ])
            ]
        )
    ]
)
