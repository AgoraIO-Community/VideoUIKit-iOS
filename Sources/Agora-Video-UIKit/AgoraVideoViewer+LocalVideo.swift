//
//  File.swift
//  
//
//  Created by Max Cobb on 23/10/2022.
//

import CoreVideo
import CoreMedia
import Foundation
import AgoraRtcKit
import AVFoundation

extension AgoraVideoViewer: AgoraCameraSourcePushDelegate {

    @discardableResult
    /// Adds the local video feed to the user video collections.
    /// - Returns: The newly created (or already created) local video feed container.
    internal func addLocalVideo() -> AgoraSingleVideoView? {
        if self.userVideoLookup[0] != nil {
            return self.userVideoLookup[0]
        }
        let vidView = AgoraSingleVideoView(
            uid: 0, micColor: self.agoraSettings.colors.micFlag
        )
        vidView.canvas.renderMode = self.agoraSettings.videoRenderMode
        self.agkit.setupLocalVideo(vidView.canvas)
        if !self.agoraSettings.externalVideoSettings.enabled, self.agoraSettings.cameraEnabled {
            self.agkit.startPreview()
        } else if let device = self.agoraSettings.externalVideoSettings.captureDevice {
            vidView.customCameraView = CustomVideoSourcePreview(frame: .zero)
            vidView.customCameraView?.isHidden = true
            self.customCamera = AgoraCameraSourcePush(delegate: self, localVideoPreview: vidView.customCameraView)
            customCamera?.startCapture(ofDevice: device)
        }
        self.userVideoLookup[0] = vidView
        return vidView
    }

    internal func removeLocalVideo() {
        guard let localVideo = self.userVideoLookup[0] else {
            return
        }
        self.agkit.setupLocalVideo(nil)
        if !self.agoraSettings.externalVideoSettings.enabled {
            self.agkit.stopPreview()
        } else if self.agoraSettings.externalVideoSettings.captureDevice != nil {
            localVideo.customCameraView?.removeFromSuperview()
            self.customCamera?.stopCapture()
            self.customCamera?.localVideoPreview = nil
        }
        localVideo.removeFromSuperview()
        self.userVideoLookup.removeValue(forKey: 0)
    }

    /// Initialises the pre-call view. This shows the local Video and lets the user adjust their scene before joining a call.
    /// Do not call this method if you're already in a channel.
    public func startPrecallVideo() {
        guard !self.agoraSettings.previewEnabled, self.connectionData.channel == nil else {
            return
        }
        self.agoraSettings.previewEnabled = true
        if self.userRole == .audience {
            self.setRole(to: .broadcaster)
        }
        self.addLocalVideo()?.videoMuted = !agoraSettings.cameraEnabled
        self.addLocalVideo()?.audioMuted = !agoraSettings.micEnabled
        self.rtcEngine(rtcEngine, didClientRoleChanged: .audience, newRole: .broadcaster, newRoleOptions: .none)
    }

    /// Stops the precall view if we are not in a channel and preview is enabled
    public func stopPrecallVideo() {
        guard self.agoraSettings.previewEnabled, self.connectionData.channel == nil else {
            return
        }
        self.removeLocalVideo()
        self.controlContainer?.isHidden = true
        self.agoraSettings.previewEnabled = false
    }

    /// Set or change the current capture device.
    /// - Parameter captureDevice: Desired AVCaptureDevice to be set up.
    /// - Returns: Returns true if successful, else false.
    public func setCaptureDevice(to captureDevice: AVCaptureDevice) -> Bool {
        if let customCamera = self.customCamera {
            // custom camera already exists, tell that to change device
            customCamera.changeCaptureDevice(to: captureDevice)
        } else if self.agoraSettings.externalVideoSettings.enabled {
            // external video enabled and not in channel yet
            // get it ready for when we do join a channel.
            self.agoraSettings.externalVideoSettings.captureDevice = captureDevice
        } else { return false }
        return true
    }

    /// This method receives the pixelbuffer, converts to `AgoraVideoFrame`, then pushes to Agora RTC.
    /// - Parameters:
    ///   - capture: Custom camera source for push.
    ///   - pixelBuffer: A reference to a Core Video pixel buffer object from the camera stream.
    ///   - rotation: Orientation of the incoming pixel buffer
    ///   - timeStamp: Timestamp when the pixel buffer was captured.
    public func myVideoCapture(
        _ capture: AgoraCameraSourcePush, didOutputSampleBuffer pixelBuffer: CVPixelBuffer,
        rotation: Int, timeStamp: CMTime
    ) {
        let videoFrame = AgoraVideoFrame()
        videoFrame.format = 12
        videoFrame.textureBuf = pixelBuffer
        videoFrame.time = timeStamp
        videoFrame.rotation = Int32(rotation)

        // once we have the video frame, we can push to agora sdk
        self.agkit.pushExternalVideoFrame(videoFrame)

        if let localUser = userVideoLookup[0], localUser.videoMuted {
            self.rtcEngine(
                self.agkit, localVideoStateChangedOf: AgoraVideoLocalState.capturing,
                error: .OK, sourceType: AgoraVideoSourceType.camera
            )
        }
    }

}
