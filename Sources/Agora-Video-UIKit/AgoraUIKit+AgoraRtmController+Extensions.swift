//
//  AgoraUIKit+AgoraRtmController+Extensions.swift
//  
//
//  Created by Max Cobb on 04/04/2022.
//

import AgoraRtcKit
#if canImport(AgoraRtmKit)
import AgoraRtmKit
#endif

extension AgoraVideoViewer {
    /// Data about a user (local or remote)
    public struct UserData: Codable {
        /// Type of message being sent
        var messageType: String? = "UserData"
        /// ID used in the RTM connection
        var rtmId: String
        /// ID used in the RTC (Video/Audio) connection
        var rtcId: Int?
        /// Username to be displayed for remote users
        var username: String?
        /// Role of the user (broadcaster or audience)
        var role: AgoraClientRole.RawValue
        /// Properties about the Agora SDK versions this user is using
        var agora: AgoraVersions = .current
        /// Agora UIKit platform (iOS, Android, Flutter, React Native)
        var uikit: AgoraUIKit = .current
        func prettyPrint() -> String {
            """
            rtm: \(rtmId)
            rtc: \(rtcId ?? 0)
            username: \(username ?? "nil")
            role: \(role)
            agora: \n\(agora.prettyPrint())
            uikit: \n\(uikit.prettyPrint())
            """
        }
        var iOSUInt: UInt? {
            if let rtcId = rtcId {
                return AgoraUIKit.intToUInt(rtcId)
            }
            return nil
        }
    }

    /// Data about the Agora SDK versions a user is using (local or remote)
    public struct AgoraVersions: Codable {
        /// Versions of the local users current RTM and RTC SDKs
        static var current: AgoraVersions {
            var version = AgoraVersions()
            #if canImport(AgoraRtmKit)
            version.rtm = AgoraRtmKit.getSDKVersion()
            #endif
            version.rtc = AgoraRtcEngineKit.getSdkVersion()
            return version
        }
        /// Version string of the RTM SDK
        var rtm: String?
        /// Version string of the RTC SDK
        var rtc: String?
        func prettyPrint() -> String {
            """
                rtc: \(rtc ?? "none found")
                rtm: \(rtm ?? "none found")
            """
        }
    }

    public var agConnection: AgoraConnectionData {
        get { self.connectionData }
        set { self.connectionData = newValue }
    }
    /// AgoraRtcEngineKit being used by this AgoraVideoViewer.
    public var rtcEngine: AgoraRtcEngineKit { self.agkit }
    /// Property used to access all the RTC connections to other broadcasters in an RTC channel.
    public var videoLookup: [UInt: AgoraSingleVideoView] { self.userVideoLookup }

}
#if canImport(AgoraRtmControl)
import AgoraRtmKit
import AgoraRtmControl

extension AgoraVideoViewer: RtmControllerDelegate {

    public func rtmStateChanged(
        from oldState: AgoraRtmController.RTMStatus, to newState: AgoraRtmController.RTMStatus
    ) { self.delegate?.rtmStateChanged(from: oldState, to: newState) }

    /// Decode an incoming AgoraRtmMessage
    /// - Parameters:
    ///   - message: Incoming RTM message.
    ///   - peerId: Id of the peer this message is coming from
    public func decodeMessage(message: AgoraRtmMessage, from peerId: String) {
        var messageData: Data!
        if let message = message as? AgoraRtmRawMessage {
            messageData = message.rawData
        } else if let msgData = message.text.data(using: .utf8) {
            messageData = msgData
        } else {
            return
        }
        if let decodedMsg = AgoraVideoViewer.decodeRtmData(
            data: messageData, from: peerId
        ) { self.handleDecodedMessage(decodedMsg, from: peerId) }
    }

    func handleDecodedMessage(_ rtmAction: DecodedRtmAction, from peerId: String) {
        switch rtmAction {
        case .mute(let muteReq):
            self.handleMuteRequest(muteReq: muteReq, from: peerId)
        case .userData(let user):
            AgoraVideoViewer.agoraPrint(
                .verbose, message: "Received user data: \n\(user.prettyPrint())"
            )
            self.rtmLookup[user.rtmId] = user
            if let rtcId = user.iOSUInt {
                self.rtcLookup[rtcId] = user.rtmId
                self.videoLookup[rtcId]?
                    .showOptions = self.agoraSettings.showRemoteRequestOptions
            }
        case .dataRequest(let requestVal):
            switch requestVal.type {
            case .userData:
                self.sendPersonalData(to: peerId)
            case .ping:
                self.rtmController?.sendCodable(
                    message: RtmDataRequest(type: .pong), member: peerId
                ) {_ in }
            case .pong:
                AgoraVideoViewer.agoraPrint(
                    .verbose, message: "Received pong from \(peerId)"
                )
                self.handlePongRequest(from: peerId)
            }
        }
    }

    // MARK: RtmControllerDelegate Properties

    /// Agora Real-time Messaging Identifier (Agora RTM SDK).
    public var rtmId: String { self.connectionData.rtmId }
    /// Agora Real-time Communication Identifier (Agora Video/Audio SDK).
    public var rtcId: UInt? { self.connectionData.rtcId }
    /// Agora App ID from https://agora.io
    public var appId: String { self.connectionData.appId }
    /// Token to be used to connect to a RTM channel, can be nil.
    public var rtmToken: String? {
        get { self.connectionData.rtmToken }
        set { self.connectionData.rtmToken = newValue }
    }

    public func handlePongRequest(from peerId: String) {
        self.delegate?.incomingPongRequest(from: peerId)
    }
    public func rtmChannelJoined(
        name: String, channel: AgoraRtmChannel, code: AgoraRtmJoinChannelErrorCode
    ) {
        if code == .channelErrorOk {
            self.sendPersonalData(to: channel)
        }
        self.delegate?.rtmChannelJoined(name: name, channel: channel, code: code)
    }
    public var rtmDelegate: AgoraRtmDelegate? { self.agoraSettings.rtmDelegate }
    public var rtmChannelDelegate: AgoraRtmChannelDelegate? { self.agoraSettings.rtmChannelDelegate }
    public func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        self.sendPersonalData(to: member.userId)
    }

    /// The local user's ``UserData`` object.
    /// - Returns: ``UserData`` object of the local user.
    public func personalData() -> some Codable {
        let safeRtcId = AgoraUIKit.uintToInt(self.rtcId ?? 0)
        return UserData(
            rtmId: self.rtmId,
            rtcId: safeRtcId == 0 ? nil : Int(safeRtcId),
            username: self.connectionData?.username,
            role: self.userRole.rawValue
        )
    }
}
#endif
