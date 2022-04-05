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
        var rtcId: UInt?
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
    public var rtcEngine: AgoraRtcEngineKit { self.agkit }
    public var videoLookup: [UInt: AgoraSingleVideoView] { self.userVideoLookup }

}
#if canImport(AgoraRtmController)
import AgoraRtmKit
import AgoraRtmController

extension AgoraVideoViewer: RtmControllerDelegate {

    public func rtmStateChanged(from: AgoraRtmController.RTMStatus, to: AgoraRtmController.RTMStatus) {
        self.delegate?.rtmStateChanged(from: from, to: to)
    }

    /// Decode an incoming AgoraRtmRawMessage
    /// - Parameters:
    ///   - rawMsg: Incoming Raw message.
    ///   - peerId: Id of the peer this message is coming from
    public func decodeRawMessage(rawMsg: AgoraRtmRawMessage, from peerId: String) {
        if let decodedRaw = AgoraVideoViewer.decodeRawRtmData(
            data: rawMsg.rawData, from: peerId
        ) {
            switch decodedRaw {
            case .mute(let muteReq):
                self.handleMuteRequest(muteReq: muteReq)
            case .userData(let user):
                AgoraVideoViewer.agoraPrint(
                    .verbose, message: "Received user data: \n\(user.prettyPrint())"
                )
                self.rtmLookup[user.rtmId] = user
                if let rtcId = user.rtcId {
                    self.rtcLookup[rtcId] = user.rtmId
                    self.videoLookup[rtcId]?
                        .showOptions = self.agoraSettings.showRemoteRequestOptions
                }
            case .dataRequest(let requestVal):
                switch requestVal.type {
                case .userData:
                    self.sendPersonalData(to: peerId)
                case .ping:
                    self.rtmController?.sendRaw(
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
    func personalData() -> some Codable {
        UserData(
            rtmId: self.rtmId,
            rtcId: self.rtcId == 0 ? nil : self.rtcId,
        username: self.connectionData?.username, role: self.userRole.rawValue
        )
    }
}
#endif
