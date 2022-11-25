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
        if self.userID == 0 || self.userVideoLookup[self.userID] != nil {
            return self.userVideoLookup[self.userID]
        }
        let vidView = AgoraSingleVideoView(
            uid: self.userID, micColor: self.agoraSettings.colors.micFlag
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
        self.userVideoLookup[self.userID] = vidView
        return vidView
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

        if let localUser = userVideoLookup[self.userID], localUser.videoMuted {
            self.rtcEngine(
                self.agkit, localVideoStateChangedOf: AgoraVideoLocalState.capturing,
                error: .OK, sourceType: AgoraVideoSourceType.camera
            )
        }
    }

}
