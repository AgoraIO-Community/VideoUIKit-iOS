// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AgoraUIKit_iOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "AgoraUIKit_iOS", targets: ["AgoraUIKit_iOS"])
    ],
    dependencies: [
        .package(
            name: "AgoraRtcKit",
            url: "https://github.com/agorabuilder/AgoraFFmpegPlayer_iOS_Preview",
            from: "4.0.0"
        ),
        .package(
            name: "AgoraRtmKit",
            url: "https://github.com/AgoraIO/AgoraRtm_iOS",
            from: "1.4.7"
        )
    ],
    targets: [
        .target(
            name: "AgoraUIKit_iOS",
            dependencies: ["AgoraRtcKit", "AgoraRtmKit"],
            path: "Sources/Agora-UIKit"
        ),
        .testTarget(name: "AgoraUIKit-Tests", dependencies: ["AgoraUIKit_iOS"], path: "Tests/Agora-UIKit-Tests")
    ]
)
