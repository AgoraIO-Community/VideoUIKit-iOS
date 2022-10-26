//
//  AgoraVideoViewer+VideoControl.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit
import AVKit
#if canImport(AgoraRtmControl)
import AgoraRtmControl
#endif

extension AgoraVideoViewer {

    /// Setup the canvas and rendering for the device's local video
    @objc open func setupAgoraVideo() {
        if self.agkit.enableVideo() < 0 {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not enable video")
            return
        }
        self.getControlContainer()

        self.agkit.setExternalVideoSource(
            agoraSettings.externalVideoSettings.enabled,
            useTexture: agoraSettings.externalVideoSettings.texture,
            sourceType: agoraSettings.externalVideoSettings.encoded ? .encodedVideoFrame : .videoFrame
        )
        if self.agoraSettings.externalAudioSettings.enabled {
            let audioSource = self.agoraSettings.externalAudioSettings
            self.agkit.setExternalAudioSource(
                audioSource.enabled,
                sampleRate: .init(audioSource.sampleRate),
                channels: .init(audioSource.channels)
            )
        }
        self.agkit.setVideoEncoderConfiguration(self.agoraSettings.videoConfiguration)
    }

    fileprivate func updateCamButton() {
        if let camButton = self.camButton {
            camButton.isOn = !self.agoraSettings.cameraEnabled
            #if os(iOS)
            camButton.backgroundColor = camButton.isOn
            ? self.agoraSettings.colors.camButtonSelected : self.agoraSettings.colors.camButtonNormal
            #elseif os(macOS)
            if !camButton.alternateTitle.isEmpty {
                swap(&camButton.title, &camButton.alternateTitle)
            }
            camButton.layer?.backgroundColor = (
                camButton.isOn
                ? self.agoraSettings.colors.camButtonSelected
                : self.agoraSettings.colors.camButtonNormal
            ).cgColor
            #endif
        }
    }

    /// Manually set the camera to be enabled or disabled.
    /// - Parameters:
    ///     - enabled: Should the camera be enabled.
    ///     - completion: completion when the setting has been changed, or failed due to permissions.
    @objc open func setCam(to enabled: Bool, completion: ((Bool) -> Void)? = nil) {
        if enabled == self.agoraSettings.cameraEnabled {
            completion?(true)
            return
        }
        if enabled,
           self.connectionData.channel != nil,
           !self.checkPermissions(
            mediaType: .video,
            callback: { err in
                if err == nil { // if permissions are now granted
                    DispatchQueue.main.async {
                        self.setCam(to: enabled, completion: completion)
                    }
                } else { completion?(false) }
            }) { return }
        self.agoraSettings.cameraEnabled = enabled
        self.agkit.enableLocalVideo(enabled)
        if let customCamera = self.customCamera {
            if enabled {
                customCamera.resumeCapture()
                self.agkit.muteLocalVideoStream(false)
                self.rtcEngine(
                    self.agkit, localVideoStateChangedOf: AgoraVideoLocalState.capturing,
                    error: .OK, sourceType: AgoraVideoSourceType.camera
                )
            } else {
                customCamera.stopCapture()
                self.agkit.muteLocalVideoStream(true)
                self.rtcEngine(
                    self.agkit, localVideoStateChangedOf: AgoraVideoLocalState.stopped,
                    error: .OK, sourceType: AgoraVideoSourceType.camera
                )
            }
        }

        updateCamButton()
        completion?(true)
    }

    /// Toggle the camera between on and off
    /// - Parameter sender: The sender is typically the camera button
    @objc open func toggleCam(_ sender: MPButton?) {
        self.setCam(to: !self.agoraSettings.cameraEnabled)
    }

    /// Manually set the microphone to be enabled or disabled.
    /// - Parameters:
    ///     - enabled: Should the microphone be enabled.
    ///     - completion: completion when the setting has been changed, or failed due to permissions.
    @objc open func setMic(to enabled: Bool, completion: ((Bool) -> Void)? = nil) {
        if enabled == self.agoraSettings.micEnabled {
            completion?(true)
            return
        }
        if enabled, self.connectionData.channel != nil, !self.checkPermissions(
            mediaType: .audio,
            callback: { err in
                if err == nil { // if permissions are now granted
                    DispatchQueue.main.async {
                        self.setMic(to: enabled, completion: completion)
                    }
                } else { completion?(false) }
            }) {
            return
        }
        self.agoraSettings.micEnabled = enabled
        self.userVideoLookup[self.userID]?.audioMuted = !self.agoraSettings.micEnabled
        self.agkit.muteLocalAudioStream(!self.agoraSettings.micEnabled)
        if self.agoraSettings.micEnabled {
            // This is only enabled. If you want to disable it then do so manually.
            self.agkit.enableLocalAudio(true)
        }
        if let micButton = self.micButton {
            micButton.isOn = !self.agoraSettings.micEnabled
            #if os(iOS)
            micButton.backgroundColor = micButton.isOn
                ? self.agoraSettings.colors.micButtonSelected : self.agoraSettings.colors.micButtonNormal
            #elseif os(macOS)
            if !micButton.alternateTitle.isEmpty {
                swap(&micButton.title, &micButton.alternateTitle)
            }
            micButton.layer?.backgroundColor = (
                micButton.isOn
                    ? self.agoraSettings.colors.micButtonSelected
                    : self.agoraSettings.colors.micButtonNormal
            ).cgColor
            #endif
        }
        completion?(true)
    }

    /// Toggle the microphone between on and off
    /// - Parameter sender: The sender is typically the microphone button
    @objc open func toggleMic(_ sender: MPButton?) {
        self.setMic(to: !self.agoraSettings.micEnabled)
    }

    /// Turn screen sharing on/off
    @objc open func toggleScreenShare() {
        guard let ssButton = self.getScreenShareButton() else { return }
        #if os(iOS)
        ssButton.isSelected.toggle()
        ssButton.backgroundColor = ssButton.isSelected ? .systemGreen : .systemGray
        #elseif os(macOS)
        ssButton.layer?.backgroundColor = (ssButton.isOn ? NSColor.systemGreen : NSColor.systemGray).cgColor
        if ssButton.isOn { self.startSharingScreen()
        } else { self.agkit.stopScreenCapture() }
        #endif
    }

    /// Start a new screen capture (macOS only for now)
    /// - Parameter displayId: The display ID of the screen to be shared. This parameter specifies which screen you want to share.
    /// - Parameter contentHint: The content hint for screen sharing, see [AgoraVideoContentHint](https://docs.agora.io/en/Interactive%20Broadcast/API%20Reference/oc/Constants/AgoraVideoContentHint.html?platform=macOS).
    ///
    /// <br>For information on how to get the displayId, see [Share the Screen](https://docs.agora.io/en/Video/screensharing_mac?platform=macOS)
    @objc open func startSharingScreen(displayId: UInt = 0) { // , contentHint: AgoraVideoContentHint = .none) {
        #if os(macOS)
        let rectangle = CGRect.zero
        let parameters = AgoraScreenCaptureParameters()
        parameters.dimensions = CGSize.zero
        parameters.frameRate = 15
        parameters.bitrate = 1000
        parameters.captureMouseCursor = true
        self.agkit.startScreenCapture(byDisplayId: UInt32(displayId), regionRect: rectangle, captureParams: parameters)
        #endif
    }

    /// Turn on/off the 'beautify' effect. Visual and voice change.
    @objc open func toggleBeautify() {
        guard let beautifyButton = self.getBeautifyButton() else { return }
        #if os(iOS)
        beautifyButton.isSelected.toggle()
        beautifyButton.backgroundColor = beautifyButton.isSelected ? .systemGreen : .systemGray
        self.agkit.setVoiceBeautifierPreset(
            beautifyButton.isSelected ? .timbreTransformationClear : .presetOff
        )
        self.agkit.setBeautyEffectOptions(beautifyButton.isSelected, options: self.beautyOptions)
        #elseif os(macOS)

        beautifyButton.layer?.backgroundColor = (
            beautifyButton.isOn ? NSColor.systemGreen : NSColor.systemGray).cgColor
        #if os(iOS)
        self.agkit.setLocalVoiceChanger(beautifyButton.isOn ? .voiceBeautyClear : .voiceChangerOff)
        #endif
        self.agkit.setBeautyEffectOptions(beautifyButton.isOn, options: self.beautyOptions)
        #endif
    }

    #if os(iOS)
    /// Swap between front and back facing camera.
    @objc open func flipCamera() { self.agkit.switchCamera() }
    #endif

    /// Toggle between being a host or a member of the audience.
    /// On changing to being a broadcaster, the app first checks
    /// that it has access to both the microphone and camera on the device.
    @objc open func toggleBroadcast() {
        self.setRole(to: self.userRole == .broadcaster ? .audience : .broadcaster)
    }

    internal var activePermissions: [AVMediaType] {
        var rtnMedias = [AVMediaType]()
        if self.agoraSettings.micEnabled { rtnMedias.append(.audio) }
        if self.agoraSettings.cameraEnabled { rtnMedias.append(.video) }
        return rtnMedias
    }

    /// Leave any open channels and kills the Agora Engine instance.
    @objc open func exit(stopPreview: Bool = true) {
        self.leaveChannel(stopPreview: true)
        AgoraRtcEngineKit.destroy()
    }
}
