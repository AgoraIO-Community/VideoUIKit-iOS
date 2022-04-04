//
//  AgoraRtmController+SendHelpers.swift
//  
//
//  Created by Max Cobb on 30/09/2021.
//

import AgoraRtmKit

// MARK: Helper Methods
extension AgoraRtmController {
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
        AgoraRtmController.agoraPrint(.error, message: "Message could not be encoded to JSON")
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
        if let rtmId = self.delegate.rtcLookup[user] {
            self.sendRaw(message: message, member: rtmId, callback: callback)
        } else {
            callback(.peerUnreachable)
        }
    }
}
