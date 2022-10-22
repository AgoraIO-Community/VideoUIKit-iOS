// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AgoraUIKit_iOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "AgoraUIKit", targets: ["AgoraUIKit", "AgoraRtmControl"]),
        .library(name: "AgoraAppGroupDataHelper", targets: ["AgoraAppGroupDataHelper"]),
        .library(name: "AgoraBroadcastExtensionHelper", targets: ["AgoraBroadcastExtensionHelper"])
    ],
    dependencies: [
        .package(
            name: "AgoraRtcKit",
            url: "https://github.com/AgoraIO/AgoraRtcEngine_iOS",
            .upToNextMinor(from: Version(4, 0, 1))
        ),
        .package(
            name: "AgoraRtmKit",
            url: "https://github.com/AgoraIO/AgoraRtm_iOS",
            .upToNextMinor(from: Version(1, 5, 1))
        )
    ],
    targets: [
        .target(
            name: "AgoraUIKit",
            dependencies: [
                .product(name: "RtcBasic", package: "AgoraRtcKit"), "AgoraRtmControl"
            ],
            path: "Sources/Agora-Video-UIKit"
        ),
        .target(
            name: "AgoraBroadcastExtensionHelper",
            dependencies: [.product(name: "RtcBasic", package: "AgoraRtcKit"), "AgoraAppGroupDataHelper"],
            path: "Sources/AgoraBroadcastExtensionHelper"
        ),
        .target(
            name: "AgoraAppGroupDataHelper",
            dependencies: [],
            path: "Sources/AgoraAppGroupDataHelper"
        ),
        .target(
            name: "AgoraRtmControl",
            dependencies: ["AgoraRtmKit"],
            path: "Sources/AgoraRtmControl"
        ),
        .testTarget(
            name: "AgoraUIKit-Tests", dependencies: ["AgoraUIKit", "AgoraRtmControl"],
            path: "Tests/Agora-UIKit-Tests"
        )
    ]
)
