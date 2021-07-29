//
//  AgoraRtmController.swift
//  AgoraUIKit_macOS
//
//  Created by Max Cobb on 14/07/2021.
//

import AgoraRtcKit
import AgoraRtmKit

/// Protocol for being able to access the AgoraRtmController and presenting alerts
public protocol SingleVideoViewDelegate: AnyObject {
    /// RTM Controller class for managing RTM messages
    var rtmController: AgoraRtmController? { get set }
    #if os(iOS)
    /// presentAlert is a way to show any alerts that want to display.
    /// These could be relating to video or audio unmuting requests.
    /// - Parameters:
    ///   - alert: Alert to be displayed
    ///   - animated: Whether the presentation should be animated or not
    func presentAlert(alert: UIAlertController, animated: Bool)
    #endif
}

extension SingleVideoViewDelegate {
    #if os(iOS)
    public func presentAlert(alert: UIAlertController, animated: Bool) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.presentAlert(alert: alert, animated: animated)
            }
            return
        }
        if let viewCont = self as? UIViewController {
            viewCont.present(alert, animated: animated)
        } else if let vidViewer = self as? AgoraVideoViewer {
            vidViewer.delegate?.presentAlert(alert: alert, animated: animated)
        }
    }
    #endif
}

/// Class for controlling the RTM messages
open class AgoraRtmController: NSObject {
    var engine: AgoraRtcEngineKit { self.videoViewer.agkit }
    var connectionData: AgoraConnectionData { self.videoViewer.connectionData }
    var agoraSettings: AgoraSettings { self.videoViewer.agoraSettings }
    /// Status of the RTM Engine
    public enum LoginStatus {
        /// Login has not been attempted
        case offline
        /// Currently attempting to log in
        case loggingIn
        /// RTM has logged in
        case loggedIn
        /// RTM Login Failed
        case loginFailed(AgoraRtmLoginErrorCode)
    }
    /// Status of the RTM Engine
    public internal(set) var loginStatus: LoginStatus = .offline
    var videoViewer: AgoraVideoViewer
    var rtmKit: AgoraRtmKit
    /// Lookup remote user RTM ID based on their RTC ID
    public internal(set) var rtcLookup: [UInt: String] = [:]
    /// Get remote user data from their RTM ID
    public internal(set) var rtmLookup: [String: UserData] = [:]
    /// RTM Channels created and joined by this RTM Controller
    public internal(set) var channels: [String: AgoraRtmChannel] = [:]
    /// Methods to be completed after login has finished (such as joining a channel)
    public internal(set) var afterLoginSteps: [() -> Void] = []

    /// Data about a user (local or remote)
    public struct UserData: Codable {
        /// ID used in the RTM connection
        var rtmId: String
        /// ID used in the RTC (Video/Audio) connection
        var rtcId: UInt?
        /// Username to be displayed for remote users
        var username: String?
        /// Agora UIKit platform (iOS, Android, Flutter, React Native)
        var platform: String = "iOS"
    }

    var personalData: UserData {
        UserData(
            rtmId: self.connectionData.rtmId,
            rtcId: self.connectionData.rtcId,
            username: self.connectionData.username
        )
    }

    init?(agoraVideoViewer: AgoraVideoViewer) {
        self.videoViewer = agoraVideoViewer
        if let rtmKit = AgoraRtmKit(appId: agoraVideoViewer.connectionData.appId, delegate: nil) {
            self.rtmKit = rtmKit
        } else {
            return nil
        }
        super.init()
        self.rtmKit.agoraRtmDelegate = self
        self.rtmLogin {_ in}
    }

    func rtmLogin(completion: @escaping (AgoraRtmLoginErrorCode) -> Void) {
        self.loginStatus = .loggingIn
        if let tokenURL = self.agoraSettings.tokenURL {
            AgoraRtmController.fetchRtmToken(urlBase: tokenURL, userId: self.connectionData.rtmId) { fetchResult in
                switch fetchResult {
                case .success(let token):
                    self.rtmKit.login(
                        byToken: token, user: self.connectionData.rtmId
                    ) { errcode in
                        self.rtmLoggedIn(code: errcode)
                        completion(errcode)
                    }
                case .failure(let failErr):
                    completion(.invalidToken)
                   AgoraVideoViewer.agoraPrint(.error, message: "could not fetch token: \(failErr)")
                }
            }
        } else {
            self.rtmKit.login(
                byToken: self.connectionData.appToken, user: self.connectionData.rtmId
            ) { errcode in
                self.rtmLoggedIn(code: errcode)
                completion(errcode)
            }
        }
    }
    /// Callback for when the login attempt finishes
    /// - Parameter code: Error codes related to login.
    open func rtmLoggedIn(code: AgoraRtmLoginErrorCode) {
        switch code {
        case .ok, .alreadyLogin:
            self.loginStatus = .loggedIn
            for step in self.afterLoginSteps {
                step()
            }
            self.afterLoginSteps.removeAll()
            return
        case .unknown, .rejected, .invalidArgument, .invalidAppId,
             .invalidToken, .tokenExpired, .notAuthorized,
             .timeout, .loginTooOften, .loginNotInitialized:
            AgoraVideoViewer.agoraPrint(.error, message: "could not log into rtm")
        @unknown default:
            AgoraVideoViewer.agoraPrint(.error, message: "unknown login code")
        }
        self.loginStatus = .loginFailed(code)
    }

    func joinChannel(
        named channel: String,
        callback: (
            (String, AgoraRtmChannel, AgoraRtmJoinChannelErrorCode) -> Void
        )? = nil
    ) {
        switch loginStatus {
        case .offline:
            self.rtmLogin { err in
                if err == .ok || err == .alreadyLogin {
                    self.joinChannel(named: channel, callback: callback)
                } else {
                    AgoraVideoViewer.agoraPrint(.error, message: "Could not login to rtm")
                }
            }
        case .loggingIn:
            self.afterLoginSteps.append {
                self.joinChannel(named: channel, callback: callback)
            }
        case .loginFailed(let loginErr):
            print("login failed: \(loginErr.rawValue)")
        case .loggedIn:
            guard let newChannel = self.rtmKit.createChannel(withId: channel, delegate: self) else {
                return
            }
            newChannel.join {
                callback?(channel, newChannel, $0)
                self.rtmChannelJoined(
                    name: channel, channel: newChannel, code: $0
                )
            }
        }
    }

    /// Called after AgoraRtmController joins a channel
    /// - Parameters:
    ///   - name: name of the channel joined
    ///   - channel: instance of joined `AgoraRtmChannel`
    ///   - code: Error codes related to joining a channel.
    open func rtmChannelJoined(
        name: String, channel: AgoraRtmChannel,
        code: AgoraRtmJoinChannelErrorCode
    ) {
        switch code {
        case .channelErrorOk:
            self.sendPersonalData(to: channel)
            self.channels[name] = channel
        case .channelErrorFailure, .channelErrorRejected,
             .channelErrorInvalidArgument, .channelErrorTimeout,
             .channelErrorExceedLimit, .channelErrorAlreadyJoined,
             .channelErrorTooOften, .sameChannelErrorTooOften,
             .channelErrorNotInitialized, .channelErrorNotLoggedIn:
            AgoraVideoViewer.agoraPrint(.error, message: "could not join channel: \(code.rawValue)")
        @unknown default:
            AgoraVideoViewer.agoraPrint(.error, message: "join channel unknown response: \(code.rawValue)")
        }
    }

}

// MARK: Helper Methods
extension AgoraRtmController {
    /// Type of decoded message coming from other users
    public enum DecodedRtmMessage {
        /// Mute is when a user is requesting another user to mute or unmute a device
        case mute(_: MuteRequest)
        /// DecodedRtmMessage type containing data about a user (local or remote)
        case userData(_: UserData)
    }
    func decodeRawRtmData(data: Data, from rtmId: String) -> DecodedRtmMessage? {
        let decoder = JSONDecoder()
        if let muteReq = try? decoder.decode(MuteRequest.self, from: data) {
            return .mute(muteReq)
        } else if let userData = try? decoder.decode(UserData.self, from: data) {
            return .userData(userData)
        }
        return nil
    }

    func sendPersonalData(to channel: AgoraRtmChannel) {
        self.sendRaw(message: self.personalData, channel: channel) { sendMsgState in
            switch sendMsgState {
            case .errorOk:
                break
            case .errorFailure, .errorTimeout, .tooOften,
                 .invalidMessage, .errorNotInitialized, .notLoggedIn:
                AgoraVideoViewer.agoraPrint(.error, message: "Could not send message to channel \(sendMsgState)")
            @unknown default:
                AgoraVideoViewer.agoraPrint(.error, message: "Could not send message to channel (unknown)")
            }
        }
    }

    func sendPersonalData(to member: String) {
        self.sendRaw(message: self.personalData, member: member) { sendMsgState in
            switch sendMsgState {
            case .ok:
                break
            case .failure, .timeout, .tooOften,
                 .invalidMessage, .notInitialized, .notLoggedIn, .peerUnreachable,
                 .cachedByServer, .invalidUserId, .imcompatibleMessage:
                AgoraVideoViewer.agoraPrint(.error, message: "Could not send message to channel \(sendMsgState)")
            @unknown default:
                AgoraVideoViewer.agoraPrint(.error, message: "Could not send message to channel (unknown)")
            }
        }
    }

    func sendRaw<Value>(
        message: Value, channel: String,
        callback: @escaping (AgoraRtmSendChannelMessageErrorCode) -> Void
    ) where Value: Codable {
        if let channel = self.channels[channel],
           let data = try? JSONEncoder().encode(message) {
            channel.send(
                AgoraRtmRawMessage(rawData: data, description: "AgoraUIKit"),
                completion: callback
            )
        }
    }

    func sendRaw<Value>(
        message: Value, channel: AgoraRtmChannel,
        callback: @escaping (AgoraRtmSendChannelMessageErrorCode) -> Void
    ) where Value: Codable {
        if let data = try? JSONEncoder().encode(message) {
            channel.send(
                AgoraRtmRawMessage(rawData: data, description: "AgoraUIKit"),
                completion: callback
            )
        }
    }

    func sendRaw<Value>(
        message: Value, member: String,
        callback: @escaping (AgoraRtmSendPeerMessageErrorCode) -> Void
    ) where Value: Codable {
        if let data = try? JSONEncoder().encode(message) {
            self.rtmKit.send(
                AgoraRtmRawMessage(rawData: data, description: "AgoraUIKit"),
                toPeer: member, completion: callback
            )
        }
    }

    func sendRaw<Value>(
        message: Value, user: UInt,
        callback: @escaping (AgoraRtmSendPeerMessageErrorCode) -> Void
    ) where Value: Codable {
        if let rtcUser = self.rtcLookup[user] {
            if let data = try? JSONEncoder().encode(message) {
                self.rtmKit.send(
                    AgoraRtmRawMessage(
                        rawData: data, description: "AgoraUIKit"
                    ), toPeer: rtcUser, completion: callback)
                return
            }
            callback(.imcompatibleMessage)
        }
        callback(.peerUnreachable)
    }

}
