// swift-tools-version: 6.2
// Package manifest for the CleoBot macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "CleoBot",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "CleoBotIPC", targets: ["CleoBotIPC"]),
        .library(name: "CleoBotDiscovery", targets: ["CleoBotDiscovery"]),
        .executable(name: "CleoBot", targets: ["CleoBot"]),
        .executable(name: "cleobot-mac", targets: ["CleoBotMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/CleoBotKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "CleoBotIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CleoBotDiscovery",
            dependencies: [
                .product(name: "CleoBotKit", package: "CleoBotKit"),
            ],
            path: "Sources/CleoBotDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "CleoBot",
            dependencies: [
                "CleoBotIPC",
                "CleoBotDiscovery",
                .product(name: "CleoBotKit", package: "CleoBotKit"),
                .product(name: "CleoBotChatUI", package: "CleoBotKit"),
                .product(name: "CleoBotProtocol", package: "CleoBotKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/CleoBot.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "CleoBotMacCLI",
            dependencies: [
                "CleoBotDiscovery",
                .product(name: "CleoBotKit", package: "CleoBotKit"),
                .product(name: "CleoBotProtocol", package: "CleoBotKit"),
            ],
            path: "Sources/CleoBotMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "CleoBotIPCTests",
            dependencies: [
                "CleoBotIPC",
                "CleoBot",
                "CleoBotDiscovery",
                .product(name: "CleoBotProtocol", package: "CleoBotKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
