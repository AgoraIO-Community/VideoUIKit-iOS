//
//  AgoraVideoViewer+VideoControl.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit
import AVKit

extension AgoraVideoViewer {

    /// Setup the canvas and rendering for the device's local video
    open func setupAgoraVideo() {
        if self.agkit.enableVideo() < 0 {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not enable video")
            return
        }
        self.getControlContainer()

        self.agkit.setExternalVideoSource(
            agSettings.externalVideoSettings.enabled,
            useTexture: agSettings.externalVideoSettings.texture,
            encodedFrame: agSettings.externalVideoSettings.encoded
        )
        if self.agSettings.externalAudioSettings.enabled {
            let audioSource = self.agSettings.externalAudioSettings
            self.agkit.setExternalAudioSource(
                audioSource.enabled,
                sampleRate: .init(audioSource.sampleRate),
                channels: .init(audioSource.channels)
            )
        }
        self.agkit.setVideoEncoderConfiguration(self.agoraSettings.videoConfiguration)
    }

    /// Manually set the camera to be enabled or disabled.
    /// - Parameters:
    ///     - enabled: Should the camera be enabled.
    ///     - completion: completion when the setting has been changed, or failed due to permissions.
    open func setCam(to enabled: Bool, completion: ((Bool) -> Void)? = nil) {
        if enabled == self.agoraSettings.cameraEnabled {
            completion?(true)
            return
        }
        if enabled,
           self.connectionData.channel != nil,
           !self.checkPermissions(
            for: .video,
            callback: { err in
                if err == nil {
                    DispatchQueue.main.async {
                        // if permissions are now granted
                        self.setCam(to: enabled, completion: completion)
                    }
                } else {
                    completion?(false)
                }
            }) {
            return
        }
        self.agoraSettings.cameraEnabled = enabled
        self.agkit.enableLocalVideo(enabled)

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
    open func setMic(to enabled: Bool, completion: ((Bool) -> Void)? = nil) {
        if enabled == self.agoraSettings.micEnabled {
            completion?(true)
            return
        }
        if enabled,
           self.connectionData.channel != nil,
           !self.checkPermissions(
            for: .audio,
            callback: { err in
                if err == nil {
                    DispatchQueue.main.async {
                        // if permissions are now granted
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
        ssButton.layer?.backgroundColor = (
            ssButton.isOn ? NSColor.systemGreen : NSColor.systemGray
        ).cgColor

        if ssButton.isOn {
            self.startSharingScreen()
        } else {
            self.agkit.stopScreenCapture()
        }
        #endif
    }

    /// Start a new screen capture (macOS only for now)
    /// - Parameter displayId: The display ID of the screen to be shared. This parameter specifies which screen you want to share.
    /// <br>For information on how to get the displayId, see [Share the Screen](https://docs.agora.io/en/Voice/screensharing_mac?platform=macOS)
    open func startSharingScreen(displayId: UInt = 0) {
        #if os(macOS)
        let rectangle = CGRect.zero
        let parameters = AgoraScreenCaptureParameters()
        parameters.dimensions = CGSize.zero
        parameters.frameRate = 15
        parameters.bitrate = 1000
        parameters.captureMouseCursor = true
        self.agkit.startScreenCapture(byDisplayId: displayId, rectangle: rectangle, parameters: parameters)
        self.agkit.setScreenCapture(.none)
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

    /// Change the role of the local user when connecting to a channel
    /// - Parameter role: new role for the local user.
    open func setRole(to role: AgoraClientRole) {
        // Check if we have access to mic + camera
        // before changing the user role.
        if role == .broadcaster {
            if !self.checkForPermissions(self.activePermissions, callback: { error in
                if error != nil { return }
                if self.checkForPermissions(self.activePermissions, alsoRequest: false) {
                    self.setRole(to: role)
                }
            }) { return }
        }
        // Swap the userRole
        self.userRole = role

        // Disable the button, it is re-enabled once the change of role is successful
        // as dictated by the delegate method
        DispatchQueue.main.async {
            // Need to point to the main thread due to the permission popups
            self.agkit.setClientRole(self.userRole)
        }
    }

    /// Join the Agora channel using token stored in AgoraVideoViewer object
    /// - Parameters:
    ///     - channel: Channel name to join
    ///     - role: [AgoraClientRole](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraClientRole.html)
    ///             to join the channel as. Default: `.broadcaster`
    ///     - fetchToken: Whether the token should be fetched before joining the channel.
    ///                   A token will only be fetched if a token URL is provided in AgoraSettings.
    ///                   Default: `false`
    ///     - uid: UID to be set when user joins the channel, default will be 0.
    open func join(
        channel: String, as role: AgoraClientRole = .broadcaster,
        fetchToken: Bool = false, uid: UInt? = nil
    ) {
        if self.connectionData == nil {
            fatalError("No app ID is provided")
        }
        if fetchToken {
            if let tokenURL = self.agoraSettings.tokenURL {
                AgoraVideoViewer.fetchToken(
                    urlBase: tokenURL, channelName: channel,
                    userId: self.userID) { result in
                    switch result {
                    case .success(let token):
                        self.join(channel: channel, with: token, as: role, uid: uid)
                    case .failure(let err):
                        AgoraVideoViewer.agoraPrint(.error, message: "Could not fetch token from server: \(err)")
                    }
                }
            } else {
                AgoraVideoViewer.agoraPrint(.error, message: "No token URL provided in AgoraSettings")
            }
            return
        }
        self.join(channel: channel, with: self.currentToken, as: role, uid: uid)
    }

    /// Join the Agora channel
    /// - Parameters:
    ///   - channel: Channel name to join
    ///   - token: Valid token to join the channel
    ///   - role: [AgoraClientRole](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraClientRole.html) to join the channel as.
    ///                   Default: `.broadcaster`
    ///   - uid: UID to be set when user joins the channel, default will be 0.
    open func join(
        channel: String, with token: String?,
        as role: AgoraClientRole = .broadcaster, uid: UInt? = nil
    ) {
        if self.connectionData == nil {
            fatalError("No app ID is provided")
        }
        if role == .broadcaster {
            if !self.checkForPermissions(self.activePermissions, callback: { error in
                if error != nil {
                    return
                }
                DispatchQueue.main.async {
                    self.join(channel: channel, with: token, as: role, uid: uid)
                }
            }) { return }
        }
        if self.connectionData.channel != nil {
            self.handleAlreadyInChannel(channel: channel, with: token, as: role, uid: uid)
            return
        }
        self.userRole = role
        if let uid = uid { self.userID = uid }

        self.currentToken = token
        self.setupAgoraVideo()
        self.connectionData.channel = channel
        if !self.agoraSettings.cameraEnabled { self.agkit.enableLocalVideo(false) }
        if !self.agoraSettings.micEnabled { self.agkit.enableLocalAudio(false) }
        self.agkit.joinChannel(
            byToken: token,
            channelId: channel,
            uid: self.userID,
            mediaOptions: AgoraRtcChannelMediaOptions()
        )
        // Delegate method is called upon success
    }

    /// Initialise RTM to send messages across the network.
    open func setupRtmController(joining channel: String) {
        if self.rtmController == nil {
            self.rtmController = AgoraRtmController(delegate: self)
        }
        self.rtmController?.joinChannel(named: channel)
    }

    internal func handleAlreadyInChannel(
        channel: String, with token: String?,
        as role: AgoraClientRole = .broadcaster, uid: UInt? = nil
    ) {
        if self.connectionData.channel == channel {
            AgoraVideoViewer.agoraPrint(.verbose, message: "We are already in a channel")
        }
        if self.leaveChannel() < 0 {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not leave current channel")
        } else {
            self.join(channel: channel, with: token, as: role, uid: uid)
        }
    }

    /// Leave channel stops all preview elements
    /// - Parameters:
    ///     - stopPreview: Stops the local preview and the video
    ///     - leaveChannelBlock: This callback indicates that a user leaves a channel, and provides the statistics of the call.
    /// - Returns: Same return as AgoraRtcEngineKit.leaveChannel, 0 means no problem, less than 0 means there was an issue leaving
    @discardableResult
    open func leaveChannel(
        stopPreview: Bool = true,
        _ leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil
    ) -> Int32 {
        guard let chName = self.connectionData.channel else {
            AgoraVideoViewer.agoraPrint(.error, message: "Not in a channel, could not leave")
            // Returning 0 to just say we are not in a channel
            return 0
        }
        self.connectionData.channel = nil
        self.agkit.setupLocalVideo(nil)
        if stopPreview, self.userRole == .broadcaster {
            agkit.stopPreview()
        }
        self.activeSpeaker = nil
        self.remoteUserIDs = []
        self.userVideoLookup = [:]
        self.backgroundVideoHolder.subviews.forEach { $0.removeFromSuperview() }
        self.controlContainer?.isHidden = true
        let leaveChannelRtn = self.agkit.leaveChannel(leaveChannelBlock)
        defer {
            if leaveChannelRtn == 0 { delegate?.leftChannel(chName) }
        }

        return leaveChannelRtn
    }

    /// Update the token currently in use by the Agora SDK. Used to not interrupt an active video session.
    /// - Parameter newToken: new token to be applied to the current connection.
    open func updateToken(_ newToken: String) {
        self.currentToken = newToken
        self.agkit.renewToken(newToken)
    }

    /// Leave any open channels and kills the Agora Engine instance.
    open func exit() {
        self.leaveChannel(stopPreview: true)
        AgoraRtcEngineKit.destroy()
    }
}
