//
//  AgoraVideoViewController+AgoraRtcEngineDelegate.swift
//  AgoraUIKit
//
//  Created by Jonathan Fotland on 2/10/20.
//  Copyright © 2020 Jonathan Fotland. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

/**
The `AgoraVideoViewController`implements the `AgoraRtcEngineDelegate` to handle the Agora RTC Engine events. Within these delegate functions the managed ui handles the UI  updates when a ARBroadcaster joins or leaves the channel.
 - Note: This class extension implements all delegate methods for Agora's Core Delegate, Stream Deleagate, and select Media Delegate methods, can be extended or overwritten.
 
For full list of available delegate methods see [AgoraRtcEngineDelegate](https://docs.agora.io/en/Video/API%20Reference/oc/Protocols/AgoraRtcEngineDelegate.html) API.
*/
extension AgoraVideoViewController: AgoraRtcEngineDelegate {
    
    // MARK: Core Delegate Methods
    /**
    Reports a warning during the Agora SDK at runtime.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - warningCode: Warning code.  Full list: [AgoraWarningCode](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraWarningCode.html)
     
     In most cases, the app can ignore the warning reported by the SDK because the SDK can usually fix the issue and resume running.

     For instance, the SDK may report an AgoraWarningCodeOpenChannelTimeout(106) warning upon disconnection from the server and attempts to reconnect.

     See [AgoraWarningCode](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraWarningCode.html).
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
            lprint("warning: \(warningCode.rawValue)", .Verbose)
    }
    
    /**
    Reports an error during the Agora SDK at runtime.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - errorCode:  [AgoraErrorCode](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraErrorCode.html)
     
     In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or inform the user about the issue.

     For example, the SDK reports an AgoraErrorCodeStartCall = 1002 error when failing to initialize a call. The app informs the user that the call initialization failed and invokes the leaveChannel method to leave the channel.

     See [AgoraErrorCode](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraErrorCode.html).
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
           lprint("error: \(errorCode.rawValue)", .Verbose)
    }
    
    /**
    Occurs when a method is executed by the SDK.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - error: The [AgoraErrorCode](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraErrorCode.html) returned by the SDK when the method call fails. If the SDK returns 0, then the method call succeeds.
        - api: The method executed by the SDK.
        - result: The result of the method call.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didApiCallExecute error: NSInteger, api: String, result: String) {
        lprint("didApiCallExecute: \(api) with result: \(result) and code: \(error)", .Verbose)
    }
    
    /**
    Occurs when the local user joins a specified channel.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - channel: Channel name.
        - uid: User ID. If the  `uid` is specified in the `joinChannelByToken` method, the specified user ID is returned. If the `user ID` is not specified when the `joinChannel` method is called, the server automatically assigns a uid.
        - elapsed: The time elapsed (ms) from the local user calling Agora's `joinChannelByToken` or `setClientRole` method, until the SDK triggers this callback.
     
     Same as joinSuccessBlock in the joinChannelByToken method.
     */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        lprint("local user did join channel with uid:\(uid)", .Verbose)
    }
    
    /**
    Occurs when the local user rejoins a channel.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - channel: Channel name.
        - uid: User ID. If the  `uid` is specified in the `joinChannelByToken` method, the specified user ID is returned. If the `user ID` is not specified when the `joinChannel` method is called, the server automatically assigns a uid.
        - elapsed: The time elapsed (ms) from the local user calling Agora's `joinChannelByToken` or `setClientRole` method, until the SDK triggers this callback.
     
     If the client loses connection with the server because of network problems, the SDK automatically attempts to reconnect and then triggers this callback upon reconnection, indicating that the user rejoins the channel with the assigned channel ID and user ID.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        lprint("local user did rejoin channel with uid:\(uid)", .Verbose)
    }
    
    /**
    Occurs when the local user leaves a channel.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - stats: Statistics of the call:. See [AgoraChannelStats](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraChannelStats.html) for more details.
     
     When the app calls the `leaveChannel` method, this callback notifies the app that a user leaves a channel.

     With this callback, the app retrieves information, such as the call duration and the statistics of the received/transmitted data reported by the `audioQualityOfUid` callback.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        lprint("local user did leave channel with stats: \n", .Verbose)
        lprint(String(describing: stats), .Verbose)
    }
    
    /**
    Occurs when the local user successfully registers a user account by calling the registerLocalUserAccount or joinChannelByUserAccount method.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - userAccount: The user account of the local user.
        - uid: The ID of the local user.
    
     This callback reports the user ID and user account of the local user.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRegisteredLocalUser userAccount: String, withUid uid: UInt) {
        lprint("didRegisteredLocalUser userAccount: \(userAccount) for local user: \(uid)", .Verbose)
    }
    
    /**
    Occurs when a remote user or host joins a channel.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - channel: Channel name.
        - uid: ID of the remote user whose video state changes.
        - elapsed: The time elapsed (ms) from the local user calling Agora's `joinChannel` method until the SDK triggers this callback.
     
     - **Communication profile:** This callback notifies the app that another user joins the channel. If other users are already in the channel, the SDK also reports to the app on the existing users.
     - **Live-broadcast profile:** This callback notifies the app that a host joins the channel. If other hosts are already in the channel, the SDK also reports to the app on the existing hosts. Agora recommends limiting the number of hosts to 17.
     
     The SDK triggers this callback under one of the following circumstances: - A remote user/host joins the channel by calling the joinChannelByToken method. - A remote user switches the user role to the host by calling the setClientRole method after joining the channel. - A remote user/host rejoins the channel after a network interruption. - A host injects an online media stream into the channel by calling the addInjectStreamUrl method.

     - Note: Live-broadcast profile:
        - The host receives this callback when another host joins the channel.
        - The audience in the channel receives this callback when a new host joins the channel.
        - When a web application joins the channel, the SDK triggers this callback as long as the web application publishes streams.
     */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        lprint("remote user joined of uid: \(uid)", .Verbose)
        remoteUserIDs.append(uid)
        activeVideoIDs.append(uid)
        collectionView.reloadData()
    }
    
    /**
    Occurs when the SDK gets the user ID and user account of the remote user.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - userInfo: The [AgoraUserInfo](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraUserInfo.html) object that contains the user ID and user account of the remote user.
        - uid: The ID of the remote user.
    
     After a remote user joins the channel, the SDK gets the user ID and user account of the remote user, caches them in a mapping table object (userInfo), and triggers this callback on the local client.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didUpdatedUserInfo userInfo: AgoraUserInfo, withUid uid: UInt) {
        if let index = remoteUserIDs.first(where: { $0 == uid }) {
            collectionView.reloadItems(at: [IndexPath(item: Int(index), section: 0)])
        }
        lprint("updated userinfo for remote user: \(uid)", .Verbose)
        lprint(String(describing:userInfo), .Verbose)
    }
    
    /**
    Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as userOfflineBlock.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - uid: ID of the user or host who leaves a channel or goes offline.
         - reason: Reason why the user goes offline, see [AgoraUserOfflineReason](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraUserOfflineReason.html).
     
     There are two reasons for users to be offline:

     - **Leave a channel:** When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
     - **Drop offline:** When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so Agora recommends using a signaling system for more reliable offline detection.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if let index = remoteUserIDs.firstIndex(where: { $0 == uid }) {
            remoteUserIDs.remove(at: index)
            activeVideoIDs = activeVideoIDs.filter { $0 != uid }
            collectionView.reloadData()
        }
        lprint("didOfflineOfUid: \(uid) with code: \(reason)", .Verbose)
    }
    
    /**
    Occurs when the network connection state changes.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - state: The current network connection state, see [AgoraConnectionStateType](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraConnectionStateType.html).
        - reason: The reason of the connection state change, see [AgoraConnectionChangedReason](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraConnectionChangedReason.html).
     
     The SDK triggers this callback to report on the current network connection state when it changes, and the reason of the change.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        lprint("connectionChangedToState: \(state) with code: \(reason)", .Verbose)
    }
    
    /**
    Occurs when the local network type changes.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - type: The network type, see [AgoraNetworkType](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraNetworkType.html).
     
     When the network connection is interrupted, this callback indicates whether the interruption is caused by a network type change or poor network conditions.
     */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, networkTypeChangedTo type: AgoraNetworkType) {
        lprint("networkTypeChangedTo: \(type)", .Verbose)
    }
    
    /**
    Occurs when the SDK cannot reconnect to Agora’s edge server 10 seconds after its connection to the server is interrupted.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
     
     The SDK triggers this callback when it cannot connect to the server 10 seconds after calling the [joinChannelByToken](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/joinChannelByToken:channelId:info:uid:joinSuccess:) method, regardless of whether it is in the channel or not.

     This callback is different from [rtcEngineConnectionDidInterrupted](https://docs.agora.io/en/Video/API%20Reference/oc/Protocols/AgoraRtcEngineDelegate.html#//api/name/rtcEngineConnectionDidInterrupted:):
     - The SDK triggers the [rtcEngineConnectionDidInterrupted](https://docs.agora.io/en/Video/API%20Reference/oc/Protocols/AgoraRtcEngineDelegate.html#//api/name/rtcEngineConnectionDidInterrupted:) callback when it loses connection with the server for more than four seconds after it successfully joins the channel.
     - The SDK triggers the [rtcEngineConnectionDidLost](https://docs.agora.io/en/Video/API%20Reference/oc/Protocols/AgoraRtcEngineDelegate.html#//api/name/rtcEngineConnectionDidLost:) callback when it loses connection with the server for more than 10 seconds, regardless of whether it joins the channel or not.
     If the SDK fails to rejoin the channel 20 minutes after being disconnected from Agora’s edge server, the SDK stops rejoining the channel.
    */
    open func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        lprint("rtcEngineConnectionDidLost", .Verbose)
    }
    
    /**
    Occurs when the token expires in 30 seconds.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - token: The token that expires in 30 seconds.
     
     The user becomes offline if the token used in the joinChannelByToken method expires. The SDK triggers this callback 30 seconds before the token expires to remind the app to get a new token. Upon receiving this callback, generate a new token on the server and call the renewToken method to pass the new token to the SDK.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        lprint("tokenPrivilegeWillExpire", .Verbose)
    }
    
    /**
    Occurs when the token expires.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
     
     After a token is specified by calling the [joinChannelByToken](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/joinChannelByToken:channelId:info:uid:joinSuccess:) method, if the SDK losses connection to the Agora server due to network issues, the token may expire after a certain period of time and a new token may be required to reconnect to the server.

     Th SDK triggers this callback to notify the app to generate a new token. Call the [renewToken](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/renewToken:) method to renew the token.
    */
    open func rtcEngineRequestToken(_ engine: AgoraRtcEngineKit) {
        lprint("rtcEngineRequestToken", .Verbose)
    }
    
    // MARK: Media Delegate Methods
     /**
     Reports which users are speaking, the speakers' volumes, and whether the local user is speaking.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - speakers: AgoraRtcAudioVolumeInfo array. An empty speakers array in the callback indicates that no remote user is speaking at the moment.
             - In the local user’s callback, this array contains the following members: uid = 0, volume = totalVolume, which reports the sum of the voice volume and audio-mixing volume of the local user, and vad, which reports the voice activity status of the local user.
             - In the remote speakers' callback, this array contains the following members: uid of each remote speaker, volume, which reports the sum of the voice volume and audio-mixing volume of each remote speaker, and vad = 0.
         - totalVolume:Total volume after audio mixing. The value range is [0,255].
             - In the local user’s callback, totalVolume is the sum of the voice volume and audio-mixing volume of the local user.
             - In the remote speakers' callback, totalVolume is the sum of the voice volume and audio-mixing volume of all the remote speakers.
      - NOTE:To enable the voice activity detection of the local user, ensure that you set `report_vad(YES)` in the `enableAudioVolumeIndication` method.
          - Calling the [muteLocalAudioStream](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/enableAudioVolumeIndication:smooth:report_vad:) method affects the behavior of the SDK:
              - If the local user calls the [muteLocalAudioStream](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/muteLocalAudioStream:) method, the SDK stops triggering the local user’s callback immediately.
              - 20 seconds after a remote speaker calls the `muteLocalAudioStream` method, the remote speakers' callback excludes information of this user; 20 seconds after all remote users call the `muteLocalAudioStream` method, the SDK stops triggering the remote speakers' callback.
      
      This callback reports the IDs and volumes of the loudest speakers at the moment in the channel, and whether the local user is speaking.  By default, this callback is disabled. You can enable it by calling the enableAudioVolumeIndication method. Once enabled, this callback is triggered at the set interval, regardless of whether a user speaks or not. The SDK triggers two independent [reportAudioVolumeIndicationOfSpeakers](https://docs.agora.io/en/Video/API%20Reference/oc/Protocols/AgoraRtcEngineDelegate.html#//api/name/rtcEngine:reportAudioVolumeIndicationOfSpeakers:totalVolume:) callbacks at one time, which separately report the volume information of the local user and all the remote speakers. For more information, see the detailed parameter descriptions.
     */
     open func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
         lprint("reportAudioVolumeIndicationOfSpeakers, totalVolume: \(totalVolume)", .Verbose)
         lprint(String(describing: speakers), .Verbose)
     }
    
    /**
     Occurs when a remote user’s audio stream is muted/unmuted.
     - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - muted: Whether the remote user’s audio stream is muted/unmuted. Where `true` represets MUTED, and `false` is UNMUTED
        - uid: ID of the remote user or host who's mic was muted
      
      The SDK triggers this callback when the remote user stops or resumes sending the audio stream by calling the muteLocalAudioStream method.

      - Note: This callback is invalid when the number of the users or broadcasters in a channel exceeds 20.
     */
     open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioMuted muted: Bool, byUid uid: UInt) {
         lprint("remote user with uid: \(uid), set Audio Muted: \(muted)", .Verbose)
     }
    
     /**
     Reports which user is the loudest speaker over a period of time.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - speakerUid: The user ID of the active speaker. A speakerUid of 0 represents the local user.
      
      This callback reports the speaker with the highest accumulative volume during a certain period. If the user enables the audio volume indication by calling the enableAudioVolumeIndication method, this callback returns the user ID of the active speaker whose voice is detected by the audio volume detection module of the SDK.
      
      - Note:
          - To receive this callback, you need to call the enableAudioVolumeIndication method.
          - This callback returns the user ID of the user with the highest voice volume during a period of time, instead of at the moment.
      */
     open func rtcEngine(_ engine: AgoraRtcEngineKit, activeSpeaker speakerUid: UInt) {
         lprint("activeSpeaker has uid: \(speakerUid)")
     }
    
     /**
     Occurs when the engine sends the first local audio frame.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - elapsed: Time elapsed (ms) from the local user calling the [joinChannelByToken](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/joinChannelByToken:channelId:info:uid:joinSuccess:) method until the SDK triggers this callback.
      
      */
     open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalAudioFrame elapsed: Int) {
         lprint("firstLocalAudioFrame with elapsed time: \(elapsed)")
     }
    
     /**
     Occurs when the engine receives the first audio frame from a specified remote user.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - uid:User ID of the remote user.
         - elapsed:Time elapsed (ms) from the local user calling the [joinChannelByToken](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/joinChannelByToken:channelId:info:uid:joinSuccess:) method until the SDK triggers this callback.
      
      This callback is triggered in either of the following scenarios:
     - The remote user joins the channel and sends the audio stream.
     - The remote user stops sending the audio stream and re-sends it after 15 seconds. Possible reasons include:
     - The remote user leaves channel.
     - The remote user drops offline.
     - The remote user calls [muteLocalAudioStream](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/muteLocalAudioStream:).
     - The remote user calls [disableAudio](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/disableAudio).
     */
     open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameOfUid uid: UInt, elapsed: Int) {
         lprint("firstRemoteAudioFrameOfUid: \(uid) with elapsed time: \(elapsed)")
     }
    
     /**
     Occurs when a remote user’s video stream playback pauses/resumes.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - muted: A remote user’s video stream playback pauses/resumes. Where `true` represets PAUSE, and `false` is RESUME
         - uid: ID of the remote user or host who's video was paused/resumed
      
      You can also use the remoteVideoStateChangedOfUid callback with the following parameters:

      - `AgoraVideoRemoteStateStopped(0)` and `AgoraVideoRemoteStateReasonRemoteMuted(5)`.
      - `AgoraVideoRemoteStateDecoding(2)` and `AgoraVideoRemoteStateReasonRemoteUnmuted(6)`.

      The SDK triggers this callback when the remote user stops or resumes sending the video stream by calling the [muteLocalVideoStream](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/userMuteVideoBlock:) method.
      - Note:
      This callback is invalid when the number of users or broadcasters in a channel exceeds 20.
      */
     open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
         lprint("remote user with uid: \(uid), set Video Muted: \(muted)", .Verbose)
     }
    
    /**
    Occurs when the remote video state changes.
    - Parameters:
        - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
        - uid: ID of the remote user whose video state changes.
        - state: The state of the remote video. For more detail see [AgoraVideoRemoteState](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraVideoRemoteState.html)
        - reason: The reason of the remote video state change.  For more detail see [AgoraVideoRemoteStateReason](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraVideoRemoteStateReason.html)
        - elapsed: The time elapsed (ms) from the local user calling Agora's `joinChannel` method until the SDK triggers this callback.
    */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStateChangedOfUid uid: UInt, state: AgoraVideoRemoteState, reason: AgoraVideoRemoteStateReason, elapsed: Int) {
        if state == .failed || state == .stopped {
            activeVideoIDs = activeVideoIDs.filter { $0 != uid }
        } else if state == .starting {
            activeVideoIDs.append(uid)
        }
        collectionView.reloadData()
    }
    
    // MARK: Stream Message Delegate Methods
     /**
     Occurs when the local user receives the data stream from a remote user within five seconds.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - uid: User ID of the remote user sending the message.
         - streamId: Stream ID
         - data: Data received by the local user
      
      The SDK triggers this callback when the local user receives the stream message that the remote user sends by calling the [sendStreamMessage](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/sendStreamMessage:data:) method.
      */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
            // successfully received message from user
            lprint("STREAMID: \(streamId)\n - DATA: \(data)", .Verbose)
    }
        
     /**
     Occurs when the local user does not receive the data stream from the remote user within five seconds.
     - Parameters:
         - engine: [AgoraRtcEngineKit](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html) object
         - uid: User ID of the remote user sending the message.
         - streamId: Stream ID
         - error:Error code. See [AgoraErrorCode](https://docs.agora.io/en/Video/API%20Reference/oc/Constants/AgoraErrorCode.html).
         - missed: Number of lost messages.
         - cached: Number of incoming cached messages when the data stream is interrupted.

      The SDK triggers this callback when the local user fails to receive the stream message that the remote user sends by calling the [sendStreamMessage](https://docs.agora.io/en/Video/API%20Reference/oc/Classes/AgoraRtcEngineKit.html#//api/name/sendStreamMessage:data:) method.
      */
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
            // message failed to send(
            lprint("STREAMID: \(streamId)\n - ERROR: \(error)", .Verbose)
    }
}
