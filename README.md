# AgoraUIKit

UI Kit for the Agora Video iOS SDK

## How to use

AgoraUIKit is distributed through [CocoaPods](www.cocoapods.org)

1. Import the Pod

Add the following to your Podfile:

```
pod 'AgoraUIKit'
```

2. Create a video call view controller

```
let agoraView = AgoraVideoViewController(appID: "YOUR_APP_ID", token: "YOUR_TOKEN_OR_NIL", channel: channelName)
```

3. Show the video view

```
navigationController?.pushViewController(agoraView, animated: true)
```

## Global preferences

Global Agora preferences can be set using the [AgoraPreferences](file:///Users/zontan/OneDrive/Agora/iOS-UIKit/docs/Classes/AgoraPreferences.html) singleton. You can use this to set your app ID and token, or to set the video configuration, e.g:

```
AgoraPreferences.shared.setVideoConfiguration(size: CGSize(width: 960, height: 720), frameRate: .fps30)
```

You can also access the `AgoraRtcEngineKit` object with `AgoraPreferences.shared.getAgoraEngine()`. The full list of available functions can be found in the [Agora API](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html).

## Customizing AgoraVideoViewController

Several methods are provided to customize the call screen. You can hide non-essential buttons:

```
agoraView.hideSwitchCamera()
agoraView.hideVideoMute()
agoraView.hideAudioMute()
```

You can also change the maximum number of video streams to show:

```
agoraView.setMaxStreams(streams: 2)
```

And customize where the controls are located:

```
agoraView.controlLocation = .top
agoraView.controlOffset = 40
```

For a full list of available functions, see the [AgoraVideoViewController API](https://agoraio-community.github.io/iOS-UIKit/Classes/AgoraVideoViewController.html).

For advanced users, `AgoraVideoViewController` is fully subclassable, to allow you to fine-tune its appearance and behavior for your app.

## Support
- [AgoraUIKit Documentation](https://agoraio-community.github.io/iOS-UIKit/)
- [Agora.io iOS API](https://docs.agora.io/en/Video/API%20Reference/oc/docs/headers/Agora-Objective-C-API-Overview.html)
- [Join the Agoira.io Developer Slack community](https://join.slack.com/t/agoraiodev/shared_invite/enQtNjk0OTg4ODgyNTc5LTczOWQ0YjBkMTMwZDFmYzViYjIxNjg4YTM0OWEzZjdkODM1NDNmOTM1ZTE4Y2Q1ZWUwMjNjMzMxMmZiNGI3ODg)
