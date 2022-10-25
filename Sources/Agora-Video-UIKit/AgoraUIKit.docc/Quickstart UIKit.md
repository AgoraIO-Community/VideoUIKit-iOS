# UI Kit Quickstart

Get started fast, using Agora's Video UI Kit.

## Overview

Agora Video UI Kit makes it easy to add video calling to your app in minutes. Video UI Kit is an Open Source project that includes best practices for business logic, as well as a pre-built video UI. Every piece is customizable, so the developer has full control over how the video call looks and feels.

This page outlines the minimum code you need to integrate high-quality, low-latency Video Calling functionality into your app with a customizable UI.

### Installation

Installation is made incredibly easy with Swift Package Manager. [Swift Package Index](https://swiftpackageindex.com/AgoraIO-Community/VideoUIKit-iOS) is a great resource to find out how it all works.

> Make sure you select at least the package product `AgoraUIKit` when prompted by Xcode.

CocoaPods installation is also available, with the pod name `'AgoraUIKit_iOS'`

### Creating an Agora Video Viewer

Your basic initialisation of ``AgoraVideoViewer`` will look something like this:

```swift
let agoraView = AgoraVideoViewer(
    connectionData: AgoraConnectionData(
        appId: "<#my-app-id#>",
        rtcToken: "<#my-channel-token#>",
        rtmToken: "<#my-channel-rtm-token#>"
    )
)
```

Treat ``AgoraVideoViewer`` as you would any UIView. It can use constraints, or just be positioned in the same way any other view in your app.

### Joining Channels

The next thing you'll want to do is join a channel. There are a couple of different methods for this, varying by how a token is fetched or provided:

- ``AgoraVideoViewer/join(channel:with:as:uid:mediaOptions:)``
- ``AgoraVideoViewer/join(channel:as:fetchToken:uid:mediaOptions:)``

The first of these is expecting a token as a property (or `nil` if you're in development); and the second takes a boolean for whether or not you want Agora's Video UI Kit to fetch the token for you. See how in the next topic.

### Fetching Tokens

How you fetch your RTC tokens will depend on how and where your token server is hosted.
However, if you're using the open source token server, [agora-token-service](https://github.com/AgoraIO-Community/agora-token-service), you'll have a much easier time fetching tokens with Video UI Kit.

Once hosted, add the URL of your token server to the settings property, ``AgoraSettings/tokenURL`` like so:

```swift
let agSettings = AgoraSettings()
agSettings.tokenURL = "https://example.com/agora-token-server"
```

And then when creating ``AgoraVideoViewer``, add the settings:

```swift
let agoraView = AgoraVideoViewer(
    connectionData: AgoraConnectionData(
        appId: "<#my-app-id#>",
        rtcToken: "<#my-channel-token#>",
        rtmToken: "<#my-channel-rtm-token#>"
    ),
    agoraSettings: agSettings
)
```

Then when you join channel, use that join method:

```swift
agoraView.join(channel: "test", as: .broadcaster, fetchToken: true)
```

Agora's Video UI Kit will automatically fetch the token from your server and join the channel.


