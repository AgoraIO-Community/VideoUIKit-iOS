//
//  AgoraVideoViewer+VideoControl.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit

extension AgoraVideoViewer {

    /// Setup the canvas and rendering for the device's local video
    func setupAgoraVideo() {
        if self.agkit.enableVideo() < 0 {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not enable video")
            return
        }
        self.agkit.setVideoEncoderConfiguration(self.agoraSettings.videoConfiguration)
    }

    /// Toggle the camera between on and off
    @objc open func toggleCam() {
        guard let camButton = self.getCameraButton() else {
            return
        }
        #if os(iOS)
        camButton.isSelected.toggle()
        camButton.backgroundColor = camButton.isSelected ? .systemRed : .systemGray
        self.agkit.enableLocalVideo(!camButton.isSelected)
        #else
        camButton.layer?.backgroundColor = camButton.isOn ?
            NSColor.systemRed.cgColor : NSColor.systemGray.cgColor
        self.agkit.enableLocalVideo(!camButton.isOn)
        #endif
    }

    /// Toggle the microphone between on and off
    @objc open func toggleMic() {
        guard let micButton = self.getMicButton() else {
            return
        }
        #if os(iOS)
        micButton.isSelected.toggle()
        micButton.backgroundColor = micButton.isSelected ? .systemRed : .systemGray
        self.agkit.muteLocalAudioStream(micButton.isSelected)
        self.userVideoLookup[self.userID]?.audioMuted = micButton.isSelected
        #else
        micButton.layer?.backgroundColor = (micButton.isOn ?
                                              NSColor.systemRed : NSColor.systemGray).cgColor
        self.agkit.muteLocalAudioStream(micButton.isOn)
        self.userVideoLookup[self.userID]?.audioMuted = micButton.isOn
        #endif
    }

    /// Turn on/off the 'beautify' effect. Visual and voice change.
    @objc open func toggleBeautify() {
        guard let beautifyButton = self.getBeautifyButton() else {
            return
        }
        #if os(iOS)
        beautifyButton.isSelected.toggle()
        beautifyButton.backgroundColor = beautifyButton.isSelected ? .systemGreen : .systemGray
        self.agkit.setVoiceBeautifierPreset(beautifyButton.isSelected ? .timbreTransformationClear : .voiceBeautifierOff)
        self.agkit.setBeautyEffectOptions(beautifyButton.isSelected, options: self.beautyOptions)
        #else

        beautifyButton.layer?.backgroundColor = (beautifyButton.isOn ?
                                                  NSColor.systemGreen : NSColor.systemGray).cgColor
        #if os(iOS)
        self.agkit.setLocalVoiceChanger(beautifyButton.isOn ?
                                          .voiceBeautyClear : .voiceChangerOff)
        #endif
        self.agkit.setBeautyEffectOptions(beautifyButton.isOn, options: self.beautyOptions)
        #endif
    }

    #if os(iOS)
    @objc open func flipCamera() {
        self.agkit.switchCamera()
    }
    #endif

    /// Toggle between being a host or a member of the audience.
    /// On changing to being a broadcaster, the app first checks
    /// that it has access to both the microphone and camera on the device.
    @objc open func toggleBroadcast() {
        // Check if we have access to mic + camera
        // before changing the user role.
        if !self.checkForPermissions(callback: self.toggleBroadcast) {
            return
        }
        // Swap the userRole
        self.userRole = self.userRole == .audience ? .broadcaster : .audience

        // Disable the button, it is re-enabled once the change of role is successful
        // as dictated by the delegate method
        DispatchQueue.main.async {
            // Need to point to the main thread due to the permission popups
            self.agkit.setClientRole(self.userRole)
        }
    }

    /// Join the Agora channel using token stored in AgoraVideoViewer object
    /// - Parameter channel: Channel name to join
    public func join(channel: String, fetchToken: Bool = false) {
        if fetchToken {
            if let tokenURL = self.agoraSettings.tokenURL {
                AgoraVideoViewer.fetchToken(
                    urlBase: tokenURL, channelName: channel,
                    userId: self.userID) { result in
                    switch result {
                    case .success(let token):
                        self.join(channel: channel, with: token)
                    case .failure(let err):
                        AgoraVideoViewer.agoraPrint(.error, message: "Could not fetch token from server: \(err)")
                    }
                }
            } else {
                AgoraVideoViewer.agoraPrint(.error, message: "No token URL provided in AgoraSettings")
            }
            return
        }
        self.join(channel: channel, with: self.currentToken)
    }

    /// Join the Agora channel
    /// - Parameters:
    ///   - channel: Channel name to join
    ///   - token: Valid token to join the channel
    public func join(channel: String, with token: String?) {
        self.currentToken = token
        self.setupAgoraVideo()
        self.connectionData.channel = channel
        self.agkit.joinChannel(
            byToken: token,
            channelId: channel,
            info: nil, uid: self.userID
        ) { [weak self] _, uid, _ in
            self?.userID = uid
            if self?.userRole == .broadcaster {
                self?.addLocalVideo()
            }
            self?.delegate?.joinedChannel?(channel: channel)
        }
    }

    /// Leave channel stops all preview elements
    /// - Parameter leaveChannelBlock: This callback indicates that a user leaves a channel, and provides the statistics of the call.
    /// - Returns: Same return as AgoraRtcEngineKit.leaveChannel, 0 means no problem, less than 0 means there was an issue leaving
    @discardableResult
    public func leaveChannel(_ leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil) -> Int32 {
        if self.connectionData.channel != nil {
            self.connectionData.channel = nil
        }
        self.agkit.setupLocalVideo(nil)
        if self.userRole == .broadcaster {
            agkit.stopPreview()
        }
        self.activeSpeaker = nil
        self.remoteUserIDs = []
        self.userVideoLookup = [:]
        let leaveChannelRtn = self.agkit.leaveChannel(leaveChannelBlock)
        defer {
            if leaveChannelRtn == 0 {
                delegate?.leftChannel?()
            }
        }
        return leaveChannelRtn
    }

    public func updateToken(_ newToken: String) {
        self.currentToken = newToken
        self.agkit.renewToken(newToken)
    }

    public func exit() {
        self.leaveChannel()
        AgoraRtcEngineKit.destroy()
    }
}
