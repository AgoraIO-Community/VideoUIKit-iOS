// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AgoraUIKit_iOS",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "AgoraUIKit", targets: ["AgoraUIKit"]),
        .library(name: "AgoraRtmControl", targets: ["AgoraRtmControl"])
    ],
    dependencies: [
        .package(
            name: "AgoraRtcKit",
            url: "https://github.com/agorabuilder/AgoraRtcEngine_iOS_Preview",
            .exact("4.0.0-preview.3")
//            .upToNextMajor(from: .init(4, 0, 0, prereleaseIdentifiers: ["-preview"], buildMetadataIdentifiers: []))
        ),
        .package(
            name: "AgoraRtmKit",
            url: "https://github.com/AgoraIO/AgoraRtm_iOS",
            .upToNextMinor(from: Version(1, 4, 10))
        )
    ],
    targets: [
        .target(
            name: "AgoraUIKit",
            dependencies: ["AgoraRtcKit", "AgoraRtmKit"],
//            dependencies: [.product(name: "RtcBasic", package: "AgoraRtcKit"), "AgoraRtmKit"],
            path: "Sources/Agora-UIKit"
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
