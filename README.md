# Agora UIKit for iOS and macOS

![.github/workflows/podlint.yml](https://github.com/AgoraIO-Community/iOS-UIKit/workflows/Pod%20Lint/badge.svg)
![.github/workflows/swiftlint.yml](https://github.com/AgoraIO-Community/iOS-UIKit/workflows/swiftlint/badge.svg)

Instantly integrate Agora in your own application or prototype using iOS or macOS.

![floating_view.jpg](https://raw.githubusercontent.com/AgoraIO-Community/iOS-UIKit/2f308d3897e3291e12bf6204f0ad722979da6b2a/media/floating_view.jpg)

## Requirements

- Device
    - Either an iOS device with 12.0 or later
    - Or a macOS computer with 10.14 or later
- Xcode 11 or later
- Cocoapods
- [An Agora developer account](https://www.agora.io/en/blog/how-to-get-started-with-agora?utm_source=github&utm_repo=agora-ios-uikit)

Once you have an Agora developer account and an App ID, you're ready to use this pod.

[Click here for full documentation](https://agoraio-community.github.io/iOS-UIKit/)

## Installation

In your iOS or macOS project, add this pod to your repository by adding a file named `Podfile`, with contents similar to this:

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '12.0'

target 'Agora-UIKit-Example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Uncomment the next line if you want to install for iOS
  # pod 'AgoraUIKit_iOS', '~> 1.0'

  # Uncomment the next line if you want to install for macOS
  # pod 'AgoraUIKit_macOS', '~> 1.0'
end
```

And then install the pods using `pod install --repo-update`

If any of these steps are unclear, look at ["Using Cocoapods" on cocoapods.org](https://guides.cocoapods.org/using/using-cocoapods.html).
The installation will change slightly once this pod is out of pre-release.

## Usage

Once installed, open your application `.xcworkspace` file.

Decide where you want to add your `AgoraVideoViewer`, and in the same file import `Agora_UIKit` or `Agora_AppKit` for iOS and macOS respectively.
Next, create an `AgoraVideoViewer` object and frame it in your scene like you would any other `UIView` or `NSView`. The `AgoraVideoViewer` object must be provided `AgoraConnectionData` and a UIViewController/NSViewController on creation.

AgoraConnectionData has two values for initialising. These are appId and appToken.

An `AgoraVideoViewer` can be created like this:

```swift
import AgoraUIKit_iOS

let agoraView = AgoraVideoViewer(
    connectionData: AgoraConnectionData(
        appId: "my-app-id">,
        appToken: "my-channel-token"
    ),
    style: .grid,
    delegate: self
)
```

An alternative style is `.floating`, as seen in the image above.

To join a channel, simply call:

```swift
agoraView.join(channel: "test", as: .broadcaster)
```

## Documentation

For full documentation, see our [AgoraUIKit documentation page](https://agoraio-community.github.io/iOS-UIKit/).