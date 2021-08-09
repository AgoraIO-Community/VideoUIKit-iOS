//
//  AgoraRtmController+AgoraRtmDelegate.swift
//  
//
//  Created by Max Cobb on 29/07/2021.
//

#if os(iOS)
import UIKit.UIDevice
#else
import IOKit
#endif
import AgoraRtmKit

extension AgoraRtmController: AgoraRtmDelegate, AgoraRtmChannelDelegate {
    /// The token used to connect to the current active channel has expired.
    /// - Parameter kit: Agora RTM Engine
    open func rtmKitTokenDidExpire(_ kit: AgoraRtmKit) {
        if let tokenURL = self.agoraSettings.tokenURL {
            AgoraRtmController.fetchRtmToken(
                urlBase: tokenURL, userId: self.connectionData.rtmId,
                callback: self.newTokenFetched(result:)
            )
        }
    }

    /**
     Occurs when receiving a peer-to-peer message.

     @param kit An [AgoraRtmKit](AgoraRtmKit) instance.
     @param message The received message. Ensure that you check the `type` property when receiving the message instance: If the message type is `AgoraRtmMessageTypeRaw`, you need to downcast the received instance from AgoraRtmMessage to AgoraRtmRawMessage. See AgoraRtmMessageType.
     @param peerId The user ID of the sender.
     */
    open func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        if let rawMsg = message as? AgoraRtmRawMessage {
            self.decodeRawMessage(rawMsg: rawMsg, from: peerId)
        }
    }

    /**
     Occurs when a user joins the channel.

     When a remote user calls the [joinWithCompletion]([AgoraRtmChannel joinWithCompletion:]) method and successfully joins the channel, the local user receives this callback.

     **NOTE**

     This callback is disabled when the number of the channel members exceeds 512.

     @param channel The channel that the user joins. See AgoraRtmChannel.
     @param member The user joining the channel. See AgoraRtmMember.
     */
    open func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        self.sendPersonalData(to: member.userId)
    }

    /**
     Occurs when receiving a channel message.

     When a remote channel member calls the [sendMessage]([AgoraRtmChannel sendMessage:completion:]) method and successfully sends out a channel message, the local user receives this callback.

     @param channel The channel, to which the local user belongs. See AgoraRtmChannel.
     @param message The received channel message. See AgoraRtmMessage. Ensure that you check the `type` property when receiving the message instance: If the message type is `AgoraRtmMessageTypeRaw`, you need to downcast the received instance from AgoraRtmMessage to AgoraRtmRawMessage. See AgoraRtmMessageType.
     @param member The message sender. See AgoraRtmMember.
     */
    open func channel(
        _ channel: AgoraRtmChannel,
        messageReceived message: AgoraRtmMessage,
        from member: AgoraRtmMember
    ) {
        if let rawMsg = message as? AgoraRtmRawMessage {
            self.decodeRawMessage(rawMsg: rawMsg, from: member.userId)
        }
    }

    /// Decode an incoming AgoraRtmRawMessage
    /// - Parameters:
    ///   - rawMsg: Incoming Raw message.
    ///   - peerId: Id of the peer this message is coming from
    open func decodeRawMessage(rawMsg: AgoraRtmRawMessage, from peerId: String) {
        if let decodedRaw = AgoraRtmController.decodeRawRtmData(data: rawMsg.rawData, from: peerId) {
            switch decodedRaw {
            case .mute(let muteReq):
                self.delegate.handleMuteRequest(muteReq: muteReq)
            case .userData(let user):
                AgoraVideoViewer.agoraPrint(
                    .verbose, message: "Received user data: \n\(user.prettyPrint())"
                )
                self.rtmLookup[user.rtmId] = user
                if let rtcId = user.rtcId {
                    self.rtcLookup[rtcId] = user.rtmId
                    self.delegate.videoLookup[rtcId]?
                        .showOptions = self.agoraSettings.showRemoteRequestOptions
                }
            }
        }
    }

}
