//
//  AgoraVideoViewer+AgoraRtcEngineDelegate.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit

extension AgoraVideoViewer: AgoraRtcEngineDelegate {
    /// Called when the user role successfully changes
    /// - Parameters:
    ///   - engine: AgoraRtcEngine of this session.
    ///   - oldRole: Previous role of the user.
    ///   - newRole: New role of the user.
    ///   - newRoleOptions: The client role option of the new role.
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didClientRoleChanged oldRole: AgoraClientRole,
        newRole: AgoraClientRole,
        newRoleOptions: AgoraClientRoleOptions?
    ) {
        let isHost = newRole == .broadcaster
        if !isHost {
            self.userVideoLookup.removeValue(forKey: self.userID)
        } else if self.userVideoLookup[self.userID] == nil {
            self.addLocalVideo()
        }

        // Only show the camera options when we are a broadcaster
        self.getControlContainer().isHidden = !isHost

        #if canImport(AgoraRtmControl)
        self.broadcastPersonalData()
        #endif

        self.agoraSettings.rtcDelegate?.rtcEngine?(
            engine, didClientRoleChanged: oldRole,
            newRole: newRole, newRoleOptions: newRoleOptions
        )
    }

    /// New User joined the channel
    /// - Parameters:
    ///   - engine: AgoraRtcEngine of this session.
    ///   - uid: ID of the user or host who joins the channel. If the `uid` is specified in the joinChannel method, the specified user ID is returned. If the `uid` is not specified in the joinChannelByToken method, the Agora server automatically assigns a `uid`.
    ///   - elapsed: Time elapsed (ms) from the local user calling the joinChannel or setClientRole method until the SDK triggers this callback.
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didJoinedOfUid uid: UInt,
        elapsed: Int
    ) {
        // Keeping track of all people in the session
        self.remoteUserIDs.insert(uid)
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didJoinedOfUid: uid, elapsed: elapsed)
    }

    /// This callback indicates the state change of the local audio stream, including the state of the audio recording and encoding, and allows you to troubleshoot issues when exceptions occur.
    ///  - Parameters:
    ///    - engine: engine See AgoraRtcEngineKit.
    ///    - uid: uid ID of the remote user whose audio state changes.
    ///    - state: state  State of the remote audio. See AgoraAudioRemoteState
    ///    - reason: reason The reason of the remote audio state change. See AgoraAudioRemoteStateReason.
    ///    - elapsed: elapsed Time elapsed (ms) from the local user calling the joinChannel method until the SDK triggers this callback.
    ///
    /// This callback does not work properly when the number of users (in the communication profile) or broadcasters (in the live interactive streaming profile) in the channel exceeds 17.
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit, remoteAudioStateChangedOfUid uid: UInt,
        state: AgoraAudioRemoteState, reason: AgoraAudioRemoteReason, elapsed: Int
    ) {
        if state == .stopped || state == .starting {
            if let videoView = self.userVideoLookup[uid] {
                videoView.audioMuted = state == .stopped
            } else if state != .stopped {
                self.addUserVideo(with: uid).audioMuted = false
                if self.activeSpeaker == nil && uid != self.userID {
                    self.activeSpeaker = uid
                }
            }
        }
        self.agoraSettings.rtcDelegate?.rtcEngine?(
            engine, remoteAudioStateChangedOfUid: uid, state: state,
            reason: reason, elapsed: elapsed
        )
    }

    /**
     Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as userOfflineBlock.

     There are two reasons for users to be offline:

     - Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
     - Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the live interactive streaming profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using the [Agora RTM SDK](https://docs.agora.io/en/Real-time-Messaging/product_rtm?platform=All%20Platforms) for more reliable offline detection.

     - Parameters:
         - engine: AgoraRtcEngineKit object.
         - uid: ID of the user or host who leaves a channel or goes offline.
         - reason: Reason why the user goes offline, see AgoraUserOfflineReason.
    */
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        didOfflineOfUid uid: UInt,
        reason: AgoraUserOfflineReason
    ) {
        // Removing on quit and dropped only
        // the other option is `.becomeAudience`,
        // which means it's still relevant.
        if reason == .quit || reason == .dropped {
            self.remoteUserIDs.remove(uid)
        }
        if self.userVideoLookup[uid] != nil {
            // User is no longer hosting, need to change the lookups
            // and remove this view from the list
            self.removeUserVideo(with: uid)
        }
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didOfflineOfUid: uid, reason: reason)
    }

    /**
     Occurs when the most active speaker is detected.

     After a successful call of [enableAudioVolumeIndication]([AgoraRtcEngineKit enableAudioVolumeIndication:smooth:report_vad:]),
     the SDK continuously detects which remote user has the loudest volume. During the current period, the remote user,
     who is detected as the loudest for the most times, is the most active user.

     When the number of users is more than or equal to two and an active speaker exists, the SDK triggers this callback and reports the `uid` of the most active speaker.

     - If the most active speaker is always the same user, the SDK triggers this callback only once.
     - If the most active speaker changes to another user, the SDK triggers this callback again and reports the `uid` of the new active speaker.

     - Parameters:
         - engine: AgoraRtcEngineKit object.
         - speakerUid: The user ID of the most active speaker.
     */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, activeSpeaker speakerUid: UInt) {
        self.activeSpeaker = speakerUid
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, activeSpeaker: speakerUid)
    }

    /**
     Occurs when the remote video state changes.

     This callback does not work properly when the number of users (in the communication profile) or hosts (in the live interactive streaming profile) in the channel exceeds 17.

     - Parameters:
         - engine: AgoraRtcEngineKit object.
         - uid: ID of the remote user whose video state changes.
         - state: The state of the remote video. See AgoraVideoRemoteState.
         - reason: The reason of the remote video state change. See AgoraVideoRemoteStateReason.
         - elapsed: The time elapsed (ms) from the local user calling the joinChannel.
     */
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt,
        state: AgoraVideoRemoteState, reason: AgoraVideoRemoteReason, elapsed: Int
    ) {
        switch state {
        case .decoding:
            self.addUserVideo(with: uid).videoMuted = false
            if self.activeSpeaker == nil && uid != self.userID {
                self.activeSpeaker = uid
            }
        case .stopped:
            self.userVideoLookup[uid]?.videoMuted = true
        default:
            break
        }
        self.agoraSettings.rtcDelegate?.rtcEngine?(
            engine, remoteVideoStateChangedOfUid: uid, state: state,
            reason: reason, elapsed: elapsed
        )
    }

    /**
     Occurs when the local user successfully joins a specified channel.

     - Parameters:
        - engine: AgoraRtcEngineKit object
        - channel: The channel name.
        - uid: The user ID.
        - elapsed: The time elapsed (ms) from the local user calling `joinChannelByToken` until this event occurs.
     */
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit, didJoinChannel channel: String,
        withUid uid: UInt, elapsed: Int
    ) {
        self.userID = uid
        if self.userRole == .broadcaster { self.addLocalVideo() }
        #if canImport(AgoraRtmControl)
        self.setupRtmController(joining: channel)
        #endif
        self.delegate?.joinedChannel(channel: channel)
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didJoinChannel: channel, withUid: uid, elapsed: elapsed)
    }

    /**
     Occurs when the local video stream state changes.
     The SDK reports the current video state in this callback.

     - Parameters:
        - engine: AgoraRtcEngineKit object.
        - state: The local video state, see AgoraVideoLocalState. When the state is AgoraVideoLocalStateFailed(3), see the `error` parameter for details.
        - error: The detailed error information of the local video, see AgoraLocalVideoStreamError.
        - sourceType: Source type of the orignated video source
     */
    public func rtcEngine(
        _ engine: AgoraRtcEngineKit, localVideoStateChangedOf state: AgoraVideoLocalState,
        error: AgoraLocalVideoStreamError, sourceType: AgoraVideoSourceType
    ) {
        switch state {
        case .capturing, .stopped:
            self.userVideoLookup[self.userID]?.videoMuted = state == .stopped
        default:
            break
        }
        self.agoraSettings.rtcDelegate?.rtcEngine?(
            engine, localVideoStateChangedOf: state, error: error, sourceType: sourceType
        )
    }

    /**
     Occurs when the local audio state changes.
     This callback indicates the state change of the local audio stream, including the state of the audio recording and encoding, and allows you to troubleshoot issues when exceptions occur.

     When the state is AgoraAudioLocalStateFailed(3), see the `error` parameter for details.

     - Parameters:
        - engine: See AgoraRtcEngineKit.
        - state: The state of the local audio. See AgoraAudioLocalState.
        - error: The error information of the local audio. See AgoraAudioLocalError.
     */
    open func rtcEngine(
        _ engine: AgoraRtcEngineKit,
        localAudioStateChanged state: AgoraAudioLocalState,
        error: AgoraAudioLocalError
    ) {
        switch state {
        case .recording, .stopped:
            self.userVideoLookup[self.userID]?.audioMuted = state == .stopped
        default:
            break
        }
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, localAudioStateChanged: state, error: error)
    }

    /**
     Occurs when the first audio frame is published.

     The SDK triggers this callback under one of the following circumstances:

     - The local client enables the audio module and calls joinChannelByToken successfully.
     - The local client calls `muteLocalAudioStream(YES)` and `muteLocalAudioStream(NO)` in sequence.
     - The local client calls disableAudio and enableAudio in sequence.

     - Parameters:
         - engine: AgoraRtcEngineKit object.
         - elapsed: The time elapsed (ms) from the local client calling `joinChannelByToken` until the SDK triggers this callback.
     */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalAudioFramePublished elapsed: Int) {
        self.addLocalVideo()?.audioMuted = false
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstLocalAudioFramePublished: elapsed)
    }

    /**
     Occurs when the token expires.
     After a `token` is specified by calling the joinChannelByToken method, if the SDK losses connection to the Agora server due to network issues, the `token` may expire after a certain period of time and a new `token` may be required to reconnect to the server.

     This callback notifies the app to generate a new token and call `joinChannelByToken` to rejoin the channel with the new token.

     - Parameter engine: AgoraRtcEngineKit object
     */
    open func rtcEngineRequestToken(_ engine: AgoraRtcEngineKit) {
        if let tokenURL = self.agoraSettings.tokenURL, let channelName = self.connectionData.channel {
            AgoraVideoViewer.fetchToken(
                urlBase: tokenURL, channelName: channelName,
                userId: self.userID, callback: self.newTokenFetched
            )
        }
        self.delegate?.tokenDidExpire(engine)
        self.agoraSettings.rtcDelegate?.rtcEngineRequestToken?(engine)
    }

    /**
     Occurs when the token expires in 30 seconds.

     The user becomes offline if the `token` used in the joinChannelByToken method expires. The SDK triggers this callback 30 seconds before the `token` expires to remind the app to get a new `token`.
     Upon receiving this callback, generate a new `token` on the server and call the renewToken method to pass the new `token` to the SDK.

     - Parameters:
        - engine: AgoraRtcEngineKit object.
        - token: The `token` that expires in 30 seconds.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        if let tokenURL = self.agoraSettings.tokenURL, let channelName = self.connectionData.channel {
            AgoraVideoViewer.fetchToken(
                urlBase: tokenURL, channelName: channelName,
                userId: self.userID, callback: self.newTokenFetched
            )
        }
        self.delegate?.tokenWillExpire(engine, tokenPrivilegeWillExpire: token)
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, tokenPrivilegeWillExpire: token)
    }
}
