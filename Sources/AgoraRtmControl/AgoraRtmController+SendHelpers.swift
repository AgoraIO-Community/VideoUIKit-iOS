//
//  AgoraRtmController+SendHelpers.swift
//  
//
//  Created by Max Cobb on 30/09/2021.
//

import Foundation
import AgoraRtmKit

// MARK: Helper Methods
extension AgoraRtmController {
    /// Send a codable message over RTM to the channel.
    /// - Parameters:
    ///   - message: Codable message to send over RTM.
    ///   - channel: String channel name to send the message to.
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendCodable<Value>(
        message: Value, channel: String,
        callback: @escaping (AgoraRtmSendChannelMessageErrorCode) -> Void
    ) where Value: Codable {
        if let channel = self.channels[channel],
           let data = try? JSONEncoder().encode(message),
           let jsonString = String(data: data, encoding: .utf8) {
            channel.send(
                AgoraRtmMessage(text: jsonString), completion: callback
            )
        }
    }

    /// Create message from codable object
    /// - Parameter codableObj: Codable object to be sent over the Real-time Messaging network.
    /// - Returns: AgoraRtmMessage that is ready to be sent across the Agora Real-time Messaging network.
    public static func createRtmMessage<Value>(from codableObj: Value) -> AgoraRtmMessage? where Value: Codable {
        if let data = try? JSONEncoder().encode(codableObj),
            let jsonString = String(data: data, encoding: .utf8) {
            return AgoraRtmMessage(text: jsonString)
        }
        AgoraRtmController.agoraPrint(.error, message: "Message could not be encoded to JSON String")
        return nil
    }

    /// Send a codable message over RTM to the channel
    /// - Parameters:
    ///   - message: Codable message to send over RTM
    ///   - channel: AgoraRtmChannel to send the message over
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendCodable<Value>(
        message: Value, channel: AgoraRtmChannel,
        callback: @escaping (AgoraRtmSendChannelMessageErrorCode) -> Void
    ) where Value: Codable {
        if let msg = AgoraRtmController.createRtmMessage(from: message) {
            channel.send(msg, completion: callback)
            return
        }
        callback(.invalidMessage)
    }

    /// Send a codable message over RTM to a member
    /// - Parameters:
    ///   - message: Codable message to send over RTM
    ///   - channel: member, or RTM ID to send the message to
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendCodable<Value>(
        message: Value, member: String,
        callback: @escaping (AgoraRtmSendPeerMessageErrorCode) -> Void
    ) where Value: Codable {
        guard let msg = AgoraRtmController.createRtmMessage(from: message) else {
            callback(.incompatibleMessage)
            return
        }
        self.rtmKit.send(msg, toPeer: member, completion: callback)
    }

    /// Send a codable message over RTM to a member
    /// - Parameters:
    ///   - message: Codable message to send over RTM
    ///   - channel: member, or RTC User ID to send the message to
    ///   - callback: Callback, to see if the message was sent successfully.
    public func sendCodable<Value>(
        message: Value, user: UInt,
        callback: @escaping (AgoraRtmSendPeerMessageErrorCode) -> Void
    ) where Value: Codable {
        if let rtmId = self.delegate.rtcLookup[user] {
            self.sendCodable(message: message, member: rtmId, callback: callback)
        } else {
            callback(.peerUnreachable)
        }
    }
}
