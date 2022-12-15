# ``AgoraUIKit``

Integrate Agora Video Calling or Live Video Streaming to your iOS or macOS app with just a few lines of code.

## Overview

Agora Video UI Kit is a low-code solution to adding video calls and live streams into your application.

Get started with this package by creating an ``AgoraVideoViewer`` and joining a channel:

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

agoraView.join(channel: "test", as: .broadcaster)
```

- ``AgoraVideoViewer/init(connectionData:style:agoraSettings:delegate:)``
- ``AgoraConnectionData``
- ``AgoraVideoViewer/join(channel:with:as:uid:mediaOptions:)``

### Getting Started

- <doc:/tutorials/TOC>
- <doc:Quickstart-UIKit>
