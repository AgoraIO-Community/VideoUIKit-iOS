# [ARCHIVED] Agora Video UI Kit for iOS

**⚠️ This project is no longer maintained and has been archived.**  
Please note that this repository is now in a read-only state and will not receive any further updates or support.
We recommend migrating to the following alternatives:

- **Agora SDK**: For developers seeking a customizable solution with full control over the user experience. [Learn more](https://www.agora.io/en/products/video-call/)
- **Agora App Builder**: For those preferring a no-code approach to integrate real-time engagement features. [Get started](https://appbuilder.agora.io/)

For documentation and support, please visit the [Agora Documentation](https://docs.agora.io/en/).

<p align="center">
    <a href="https://github.com/AgoraIO-Community/VideoUIKit-iOS/releases">
        <img src="https://img.shields.io/github/v/release/AgoraIO-Community/VideoUIKit-iOS?color=orange&label=Stable%20Release&logo=swift"/>
    </a>
    <a href="https://swiftpackageindex.com/AgoraIO-Community/VideoUIKit-iOS">
        <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAgoraIO-Community%2FVideoUIKit-iOS%2Fbadge%3Ftype%3Dplatforms"/>
    </a>
    <a href="https://swiftpackageindex.com/AgoraIO-Community/VideoUIKit-iOS">
        <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAgoraIO-Community%2FVideoUIKit-iOS%2Fbadge%3Ftype%3Dswift-versions"/>
    </a>
    <br/>
    <img src="https://github.com/AgoraIO-Community/VideoUIKit-iOS/actions/workflows/swift-build-lint.yml/badge.svg"/>
    <a href="https://agoraio-community.github.io/VideoUIKit-iOS/documentation/agorauikit">
        <img src="https://github.com/AgoraIO-Community/VideoUIKit-iOS/actions/workflows/deploy_docs.yml/badge.svg"/>
    </a>
    <a href="https://www.agora.io/en/join-slack/">
        <img src="https://img.shields.io/badge/slack-@RTE%20Dev-blue?logo=slack">
    </a>
</p>

Instantly integrate Agora in your own application or prototype using iOS. For macOS, see [VideoUIKit-macOS](https://github.com/AgoraIO-Community/VideoUIKit-macOS).

<p align="center">
  <img src="https://github.com/AgoraIO-Community/VideoUIKit-iOS/raw/main/media/agora-uikit-banner.png"/>
</p>

[More information available on this repo's Wiki](https://github.com/AgoraIO-Community/VideoUIKit-iOS/wiki)

[Click here for full documentation](https://agoraio-community.github.io/VideoUIKit-iOS/documentation/agorauikit/)

To see full documentation for other packages in this repo, such as `AgoraBroadcastExtensionHelper`, `AgoraAppGroupDataHelper` or `AgoraRtmControl`, check them out here:

- [AgoraBroadcastExtensionHelper](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraBroadcastExtensionHelper/)
- [AgoraAppGroupDataHelper](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraAppGroupDataHelper/)
- [AgoraRtmControl](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraRtmControl/)

## Requirements

- iOS 13.0+ or a macOS 10.15 or later
- Xcode 12.3 or later
- CocoaPods (if installing with CocoaPods)
- [An Agora developer account](https://www.agora.io/en/blog/how-to-get-started-with-agora?utm_source=github&utm_repo=agora-ios-uikit)

Once you have an Agora developer account and an App ID, you're ready to use this package.

## Installation

Swift Package Manager and CocoaPods are both available offered for installation methods.

The Pod for this package is called `AgoraUIKit_iOS` and `AgoraUIKit_macOS` for the two available platforms.

See the [Installation wiki](https://github.com/AgoraIO-Community/VideoUIKit-iOS/wiki/Installation) page for more information on installing the package.

## Usage

Once installed, open your application `.xcodeproj` file. Or `.xcworkspace` if using CocoaPods.

The main view for Agora UIKit is `AgoraVideoViewer`. This is an example of a minimal creation that gives you a view similar to the one at the top of this README:

```swift
import AgoraRtcKit
import AgoraUIKit

let agoraView = AgoraVideoViewer(
    connectionData: AgoraConnectionData(
        appId: "<#my-app-id#>",
        rtcToken: "<#my-channel-token#>",
        rtmToken: "<#my-channel-rtm-token#>"
    ), delegate: self
)
```

Frame your newly created AgoraVideoViewer in the app scene, then join a channel by calling:

```swift
agoraView.join(channel: "test", as: .broadcaster)
```

[More examples available on the wiki](https://github.com/AgoraIO-Community/VideoUIKit-iOS/wiki/Examples)

### Screen Sharing

For an example for screen sharing with Agora Video UI Kit and [AgoraBroadcastExtensionHelper Quickstart](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraBroadcastExtensionHelper/documentation/agorabroadcastextensionhelper/quickstart), check out the example project here:

https://github.com/AgoraIO-Community/Video-UI-Kit-ScreenShare

## Documentation

For full documentation, see our [AgoraUIKit documentation page](https://agoraio-community.github.io/VideoUIKit-iOS/documentation/agorauikit/).

For other libraries in this package:
- [AgoraBroadcastExtensionHelper](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraBroadcastExtensionHelper/)
- [AgoraAppGroupDataHelper](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraAppGroupDataHelper/)
- [AgoraRtmControl](https://agoraio-community.github.io/VideoUIKit-iOS/extensions/AgoraRtmControl/)


## Error Handling and Troubleshooting

For tips on how to overcome some common errors, [see the wiki page](https://github.com/AgoraIO-Community/VideoUIKit-iOS/wiki/Error-Handling-and-Troubleshooting).

## Roadmap

- [x] Muting/Unmuting a remote member
- [x] Usernames ([Settable value, not currently rendered](https://agoraio-community.github.io/VideoUIKit-iOS/documentation/agorauikit/agoraconnectiondata/username))
- [ ] Promoting an audience member to a broadcaster role.
- [ ] Layout for Voice Calls
- [ ] Cloud recording

## UIKits

The plan is to grow this library and have similar offerings across all supported platforms. There are already similar libraries for [Android](https://github.com/AgoraIO-Community/VideoUIKit-Android), [React Native](https://github.com/AgoraIO-Community/VideoUIKit-ReactNative), [Flutter](https://github.com/AgoraIO-Community/VideoUIKit-Flutter) and [Web React](https://github.com/AgoraIO-Community/VideoUIKit-Web-React) so be sure to check them out.

## UML Diagrams

- AgoraUIKit

<p align="center">
    <img src="media/uml_agorauikit.svg" alt="UML of AgoraUIKit"/>
</p>

- AgoraRtmControl

<p align="center">
    <img src="media/uml_agorartmcontrol.svg" alt="UML of AgoraRtmControl"/>
</p>

> generated with `swiftplantuml classdiagram Sources`
