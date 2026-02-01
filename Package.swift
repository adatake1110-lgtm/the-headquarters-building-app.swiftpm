// swift-tools-version: 6.0

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "The Headquarters Building App",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "The Headquarters Building App",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.the-headquarters-building-app",
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "Sources",
            resources: [
                .process("../Resources")
            ]
        )
    ]
)
