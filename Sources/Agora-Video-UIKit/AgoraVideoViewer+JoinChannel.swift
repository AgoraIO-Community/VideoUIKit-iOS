//
//  AgoraVideoViewer+JoinChannel.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 26/10/2022.
//

import Foundation
import AgoraRtcKit
import AgoraRtmKit
import AgoraRtmControl

extension AgoraVideoViewer {
    /// Change the role of the local user when connecting to a channel
    /// - Parameter role: new role for the local user.
    @objc open func setRole(to role: AgoraClientRole) {
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

        // Disable the button, it is re-enabled once the change of role is successful as dictated by the delegate method
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
    ///     - mediaOptions: Media options such as custom audio/video tracks, subscribing options etc.
    public func join(
        channel: String, as role: AgoraClientRole = .broadcaster,
        fetchToken: Bool = false, uid: UInt? = nil,
        mediaOptions: AgoraRtcChannelMediaOptions? = nil
    ) {
        if self.connectionData == nil { fatalError("No app ID is provided") }
        guard fetchToken else {
            self.join(channel: channel, with: self.currentRtcToken, as: role, uid: uid, mediaOptions: mediaOptions)
            return
        }
        if let tokenURL = self.agoraSettings.tokenURL {
            AgoraVideoViewer.fetchToken(
                urlBase: tokenURL, channelName: channel, userId: self.userID
            ) { result in
                switch result {
                case .success(let token):
                    DispatchQueue.main.async {
                        self.join(channel: channel, with: token, as: role, uid: uid, mediaOptions: mediaOptions)
                    }
                case .failure(let err):
                    AgoraVideoViewer.agoraPrint(.error, message: "Could not fetch token from server: \(err)")
                }
            }
        } else {
            AgoraVideoViewer.agoraPrint(.error, message: "No token URL provided in AgoraSettings")
        }
    }

    /// Join the Agora channel
    /// - Parameters:
    ///   - channel: Channel name to join
    ///   - token: Valid token to join the channel
    ///   - role: [AgoraClientRole](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraClientRole.html) to join the channel as. Default: `.broadcaster`
    ///   - uid: UID to be set when user joins the channel, default will be 0.
    ///   - mediaOptions: Media options such as custom audio/video tracks, subscribing options etc.
    /// - Returns: An integer representing Agora's joinChannelByToken response. If response is `nil`,
    ///            that means it has continued on another thread due to requesting camera/mic permissions,
    ///            or you area already in the channel. If the response is 0, everything is fine.
    @discardableResult
    public func join(
        channel: String, with token: String?,
        as role: AgoraClientRole = .broadcaster, uid: UInt? = nil,
        mediaOptions: AgoraRtcChannelMediaOptions? = nil
    ) -> Int32? {
        if self.connectionData == nil { fatalError("No app ID is provided") }
        if role == .broadcaster {
            if !self.checkForPermissions(self.activePermissions, callback: { error in
                if error != nil { return }
                DispatchQueue.main.async {
                    self.join(channel: channel, with: token, as: role, uid: uid, mediaOptions: mediaOptions)
                }
            }) { return nil }
        }
        if self.connectionData.channel != nil {
            self.handleAlreadyInChannel(
                channel: channel, with: token, as: role, uid: uid, mediaOptions: mediaOptions
            )
            return nil
        }
        self.userRole = role
        if let uid = uid { self.userID = uid }

        self.currentRtcToken = token
        self.setupAgoraVideo()
        self.connectionData.channel = channel
        if !self.agoraSettings.cameraEnabled { self.agkit.enableLocalVideo(false) }
        if !self.agoraSettings.micEnabled { self.agkit.enableLocalAudio(false) }
        return self.agkit.joinChannel(
            byToken: token,
            channelId: channel,
            uid: self.userID,
            mediaOptions: mediaOptions ?? AgoraRtcChannelMediaOptions()
        ) // Delegate method is called upon success
    }

    #if canImport(AgoraRtmControl)
    /// Initialise RTM to send messages across the network.
    @objc open func setupRtmController(joining channel: String) {
        self.setupRtmController { rtmController in
            rtmController?.joinChannel(named: channel)
        }
    }

    /// Initialise RTM within Agora Video Starter Kit.
    /// - Parameter callback: Return the rtm controller as a callback parameter.
    @objc open func setupRtmController(callback: ((AgoraRtmController?) -> Void)? = nil) {
        if !self.agoraSettings.rtmEnabled { return }
        if self.rtmController == nil {
            DispatchQueue.global(qos: .utility).async {
                self.rtmController = AgoraRtmController(delegate: self)
                if self.rtmController == nil {
                    AgoraVideoViewer.agoraPrint(.error, message: "Error initialising RTM")
                }
                callback?(self.rtmController)
            }
        }
    }
    #endif

    internal func handleAlreadyInChannel(
        channel: String, with token: String?,
        as role: AgoraClientRole = .broadcaster, uid: UInt? = nil,
        mediaOptions: AgoraRtcChannelMediaOptions? = nil
    ) {
        if self.connectionData.channel == channel {
            AgoraVideoViewer.agoraPrint(.verbose, message: "We are already in a channel")
        }
        if self.leaveChannel() < 0 {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not leave current channel")
        } else {
            self.join(channel: channel, with: token, as: role, uid: uid, mediaOptions: mediaOptions)
        }
    }

    /// Leave channel stops all preview elements
    /// - Parameters:
    ///     - stopPreview: Stops the local preview and the video
    ///     - leaveChannelBlock: This callback indicates that a user leaves a channel, and provides the statistics of the call.
    /// - Returns: Same return as AgoraRtcEngineKit.leaveChannel, 0 means no problem, less than 0 means there was an issue leaving
    @discardableResult
    @objc open func leaveChannel(
        stopPreview: Bool = true, _ leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil
    ) -> Int32 {
        guard let chName = self.connectionData.channel else {
            AgoraVideoViewer.agoraPrint(.error, message: "Not in a channel, could not leave")
            // Returning 0 to just say we are not in a channel
            return 0
        }
        self.connectionData.channel = nil
        self.agkit.setupLocalVideo(nil)
        self.customCamera?.stopCapture()
        if stopPreview, self.userRole == .broadcaster { agkit.stopPreview() }
        self.activeSpeaker = nil
        self.remoteUserIDs = []
        self.userVideoLookup = [:]
        self.backgroundVideoHolder.subviews.forEach { $0.removeFromSuperview() }
        self.controlContainer?.isHidden = true
        let leaveChannelRtn = self.agkit.leaveChannel(leaveChannelBlock)
        defer { if leaveChannelRtn == 0 { delegate?.leftChannel(chName) } }
        return leaveChannelRtn
    }

}
