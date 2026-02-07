// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CleoBotKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "CleoBotProtocol", targets: ["CleoBotProtocol"]),
        .library(name: "CleoBotKit", targets: ["CleoBotKit"]),
        .library(name: "CleoBotChatUI", targets: ["CleoBotChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "CleoBotProtocol",
            path: "Sources/CleoBotProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CleoBotKit",
            dependencies: [
                "CleoBotProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/CleoBotKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "CleoBotChatUI",
            dependencies: [
                "CleoBotKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/CleoBotChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "CleoBotKitTests",
            dependencies: ["CleoBotKit", "CleoBotChatUI"],
            path: "Tests/CleoBotKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
