# Quickstart

Screensharing with iOS can be pretty tricky, this guide is here to help you!

With ``AgoraBroadcastExtensionHelper`` it's easy to get screen sharing enabled in your application.

## Installation

First, go to your project overview in Xcode, and add a new target of type "Broadcast Upload Extension":

![Add Extension](add-app-extension.gif)

Once added, some files will be created for you, and you'll need to add ``AgoraBroadcastExtensionHelper`` to the newly created extension. Also add `AgoraAppGroupDataHelper` to your main app target.

![Add Library](add-helper-library)

## Add RPSystemBroadcastPickerView

The object [`RPSystemBroadcastPickerView`](https://developer.apple.com/documentation/replaykit/rpsystembroadcastpickerview) is a view displaying a broadcast button that, when tapped, shows a broadcast picker.

To add a simple one to the view in our main app, and fetch our extension's bundle identifier to apply to it's property, `preferredExtension`:

```swift
func prepareScreenSharing() {
    let systemBroadcastPicker = RPSystemBroadcastPickerView(
        frame: CGRect(x: 50, y: 200, width: 60, height: 60))
    systemBroadcastPicker.showsMicrophoneButton = false
    systemBroadcastPicker.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
    if let url = Bundle.main.url(forResource: "<#Extension Name#>", withExtension: "appex", subdirectory: "PlugIns"),
       let bundle = Bundle(url: url) {
        systemBroadcastPicker.preferredExtension = bundle.bundleIdentifier
    }
    self.view.addSubview(systemBroadcastPicker)
}
```

Call this method somewhere in your code from the same scene where the video call is present.

That's all for now on the main app target side, more to come below.

## Broadcasting Extension Logic

One of the files created inside the extension is called `SampleHandler.swift`. Go to that file and replace the `SampleHandler` class with something that looks like this:
``AgoraBroadcastSampleHandler/getBroadcastData()``

```swift
import AgoraBroadcastExtensionHelper

class SampleHandler: AgoraBroadcastSampleHandler {
    override public func getAppGroup() -> String? {
        // Follow the article to fill this in!
    }
    
    override public func getBroadcastData() -> AgoraBroadcastExtData? {
        // Method for quick testing.
    }
}
```

Only one of the above two method would need to be added, the next two sections will help you choose the right one for you.

### The basic way (for testing)

The method, ``AgoraBroadcastSampleHandler/getBroadcastData()``, is the easiest to spin up an example. So Here's an example of how to use it.

Simply fill in this override method to return an object of type ``AgoraBroadcastExtData``, such as this one:

```swift
override func getBroadcastData() -> AgoraBroadcastExtData? {
    return AgoraBroadcastExtData(
        appId: "<#Agora App ID#>",
        channel: "<#Channel Name#>",
        token: <#Token or nil#>,
        uid: 0
    )
}
```

The Agora App ID can be found on [Agora console](https://console.agora.io/). Add a channel name, and token if required (or `nil` if not). For the uid, 0 will mean you get assigned one when joining, but it is often better to know ahead of time a specific user ID for screen sharing streams.

### The Production Way

In a production environment, or when you want to specify the channel, token, user ID etc, ``AgoraBroadcastSampleHandler/getAppGroup()`` is the recommended method. Using this method, you can easily consider the rest of your application's logic.

First, the same app group needs to be added to both the application target and the broadcast extension.

![Add App Group](add-app-group)

This app group allows the two targets to share data between them and that's what we're going to do next.

On the main app side, we need to make a small change to pass data such as the App ID and channel over to app extension.

To do so, there are only a few commands we need to add:

```swift
AgoraAppGroupDataHelper.appGroup = "group.com.example.my-app" // Replace with your app group.
AgoraAppGroupDataHelper.set("<#Agora App ID#>", forKey: .appId)
AgoraAppGroupDataHelper.set("<#Channel Name#>", forKey: .channel)
AgoraAppGroupDataHelper.set(<#Token or nil#>, forKey: .token)
AgoraAppGroupDataHelper.set(<#Screenshare User ID#>, forKey: .uid)
```

These values will be picked up by the app extension, and applied when it joins the video call or stream. This can be added to the above method, `prepareScreenSharing`.

The ``AgoraBroadcastSampleHandler/getAppGroup()`` metho would need updating to something like the following, depending on your app group name:

```swift
class SampleHandler: AgoraBroadcastSampleHandler {
    override public func getAppGroup() -> String? {
        return "group.com.example.my-app"
    }
}
```

## Conclusion

That's it, your app is now hooked up to allow users to stream their screen!
Check out our example project here:

[https://github.com/AgoraIO-Community/Video-UI-Kit-ScreenShare](https://github.com/AgoraIO-Community/Video-UI-Kit-ScreenShare)

If you have any issues with this, feel free to [open an issue on GitHub](https://github.com/AgoraIO-Community/VideoUIKit-iOS/issues/new/choose).
