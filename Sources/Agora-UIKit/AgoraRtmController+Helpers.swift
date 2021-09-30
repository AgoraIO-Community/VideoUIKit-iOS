//
//  AgoraRtmController+Helpers.swift
//  
//
//  Created by Max Cobb on 30/09/2021.
//

import AgoraRtmKit

// MARK: Helper Methods
extension AgoraRtmController {
    /// Type of decoded message coming from other users
    public enum DecodedRtmAction {
        /// Mute is when a user is requesting another user to mute or unmute a device
        case mute(_: MuteRequest)
        /// DecodedRtmAction type containing data about a user (local or remote)
        case userData(_: UserData)
        /// Message that contains a small action request, such as a ping or requesting a user's data
        case genericAction(_: RtmGenericRequest)
    }

    /// Decode message to a compatible DecodedRtmMessage type.
    /// - Parameters:
    ///   - data: Raw data input, should be utf8 encoded JSON string of MuteRequest or UserData.
    ///   - rtmId: Sender Real-time Messaging ID.
    /// - Returns: DecodedRtmMessage enum of the appropriate type.
    internal static func decodeRawRtmData(data: Data, from rtmId: String) -> DecodedRtmAction? {
        let decoder = JSONDecoder()
        if let userData = try? decoder.decode(UserData.self, from: data) {
            return .userData(userData)
        } else if let muteReq = try? decoder.decode(MuteRequest.self, from: data) {
            return .mute(muteReq)
        } else if let genericRequest = try? decoder.decode(RtmGenericRequest.self, from: data) {
            return .genericAction(genericRequest)
        }
        return nil
    }

    /// Share local UserData to all connected channels.
    /// Call this method when personal details are updated.
    open func broadcastPersonalData() {
        for channel in self.channels { self.sendPersonalData(to: channel.value) }
    }

    /// Share local UserData to a specific channel
    /// - Parameter channel: Channel to share UserData with.
    open func sendPersonalData(to channel: AgoraRtmChannel) {
        self.sendRaw(message: self.personalData, channel: channel) { sendMsgState in
            switch sendMsgState {
            case .errorOk:
                AgoraVideoViewer.agoraPrint(
                    .verbose, message: "Personal data sent to channel successfully"
                )
            case .errorFailure, .errorTimeout, .tooOften,
                 .invalidMessage, .errorNotInitialized, .notLoggedIn:
                AgoraVideoViewer.agoraPrint(
                    .error, message: "Could not send message to channel \(sendMsgState.rawValue)"
                )
            @unknown default:
                AgoraVideoViewer.agoraPrint(.error, message: "Could not send message to channel (unknown)")
            }
        }
    }

    /// Share local UserData to a specific RTM member
    /// - Parameter member: Member to share UserData with.
    open func sendPersonalData(to member: String) {
        self.sendRaw(message: self.personalData, member: member) { sendMsgState in
            switch sendMsgState {
            case .ok:
                AgoraVideoViewer.agoraPrint(
                    .verbose, message: "Personal data sent to member successfully"
                )
            case .failure, .timeout, .tooOften, .invalidMessage, .notInitialized, .notLoggedIn,
                 .peerUnreachable, .cachedByServer, .invalidUserId, .imcompatibleMessage:
                AgoraVideoViewer.agoraPrint(
                    .error, message: "Could not send message to channel \(sendMsgState.rawValue)"
                )
            @unknown default:
                AgoraVideoViewer.agoraPrint(.error, message: "Could not send message to channel (unknown)")
            }
        }
    }

    /// Send a raw codable message over RTM to the channel.
    /// - Parameters:
    ///   - message: Codable message to send over RTM.
    ///   - channel: String channel name to send the message to.
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendRaw<Value>(
        message: Value, channel: String,
        callback: @escaping (AgoraRtmSendChannelMessageErrorCode) -> Void
    ) where Value: Codable {
        if let channel = self.channels[channel], let data = try? JSONEncoder().encode(message) {
            channel.send(
                AgoraRtmRawMessage(rawData: data, description: "AgoraUIKit"), completion: callback
            )
        }
    }

    /// Create raw message from codable object
    /// - Parameter codableObj: Codable object to be sent over the Real-time Messaging network.
    /// - Returns: AgoraRtmRawMessage that is ready to be sent across the Agora Real-time Messaging network.
    public static func createRawRtm<Value>(from codableObj: Value) -> AgoraRtmRawMessage? where Value: Codable {
        if let data = try? JSONEncoder().encode(codableObj) {
            return AgoraRtmRawMessage(rawData: data, description: "AgoraUIKit")
        }
        AgoraVideoViewer.agoraPrint(.error, message: "Message could not be encoded to JSON")
        return nil
    }

    /// Send a raw codable message over RTM to the channel
    /// - Parameters:
    ///   - message: Codable message to send over RTM
    ///   - channel: AgoraRtmChannel to send the message over
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendRaw<Value>(
        message: Value, channel: AgoraRtmChannel,
        callback: @escaping (AgoraRtmSendChannelMessageErrorCode) -> Void
    ) where Value: Codable {
        if let rawMsg = AgoraRtmController.createRawRtm(from: message) {
            channel.send(rawMsg, completion: callback)
            return
        }
        callback(.invalidMessage)
    }

    /// Send a raw codable message over RTM to a member
    /// - Parameters:
    ///   - message: Codable message to send over RTM
    ///   - channel: member, or RTM ID to send the message to
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendRaw<Value>(
        message: Value, member: String,
        callback: @escaping (AgoraRtmSendPeerMessageErrorCode) -> Void
    ) where Value: Codable {
        guard let rawMsg = AgoraRtmController.createRawRtm(from: message) else {
            callback(.imcompatibleMessage)
            return
        }
        self.rtmKit.send(rawMsg, toPeer: member, completion: callback)
    }

    /// Send a raw codable message over RTM to a member
    /// - Parameters:
    ///   - message: Codable message to send over RTM
    ///   - channel: member, or RTC User ID to send the message to
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendRaw<Value>(
        message: Value, user: UInt,
        callback: @escaping (AgoraRtmSendPeerMessageErrorCode) -> Void
    ) where Value: Codable {
        if let rtmId = self.rtcLookup[user] {
            self.sendRaw(message: message, member: rtmId, callback: callback)
        } else {
            callback(.peerUnreachable)
        }
    }
}
