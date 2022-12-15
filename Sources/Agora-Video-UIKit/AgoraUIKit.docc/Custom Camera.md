# Custom Camera

Adding a custom camera with Agora Video UI Kit.

## Overview

With Agora's core RTC SDK there are many steps involved in using a custom camera, but with Video UI Kit, you only need to do two things.

## Grab The Camera

The first step is fetching the camera. In this example we will use the ultra wide camera, which is available on several different iPhones. Using AVCaptureDevice.DiscoverySession, we can look up cameras that satisfy our criteria:

```swift
guard let ultraWideCamera = AVCaptureDevice.DiscoverySession(
    deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back
).devices.first else {
    fatalError("Cannot find ultra wide camera")
}
```

If you want the above code to fallback on other cameras, simply add more cases to the `deviceTypes` array.

## Set Video UI Kit Properties

Now you need to add some external video settings with Video UI Kit, using ``AgoraSettings`` and ``AgoraSettings/externalVideoSettings-swift.property``.

```swift
var agSettings = AgoraSettings()
agSettings.externalVideoSettings = .init(
    enabled: true, texture: true, encoded: false,
    captureDevice: ultraWideCamera
)
```

The above code snippet specifies the following:

- Enable external videos.
- Tells RTC Engine that it is a texture.
- We are not using an encoded video stream.
- Finally the capture device fetched earlier is passed through.


## Update Custom Camera

To update the custom camera at another point after the user is already connected to a channel, the method ``AgoraVideoViewer/setCaptureDevice(to:)`` can be used:

```swift
guard let firstValidCamera = AVCaptureDevice.DiscoverySession(
    deviceTypes: [.builtInTelephotoCamera], mediaType: .video, position: .back
).devices.first else { fatalError("Cannot find above camera")}

_ = self.agoraView?.setCaptureDevice(to: firstValidCamera)
```


## Conclusion

This shows how to use any AVCaptureDevice and pass that directly through Agora Video RTC Engine.

![Both Cameras Example](custom-camera-both.png)
