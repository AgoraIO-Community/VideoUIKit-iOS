//
//  StreamMessageController.swift
//  AgoraUIKit_macOS
//
//  Created by Max Cobb on 14/07/2021.
//

import AgoraRtcKit
import AgoraRtmKit

/// Protocol for being able to access the StreamMessageController and presenting alerts
public protocol SingleVideoViewDelegate {
    /// Stream Controller class for managing stream messages
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

/// Class for controlling the stream messages
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

    /// Structure that contains information about a mute request
    public struct MuteRequest: Codable {
        /// RTC ID that the request is intended for
        public var rtcId: UInt
        /// Whether the request is to mute or unmute a device
        public var mute: Bool
        /// Device to be muted or unmuted
        public var device: AgoraRtmController.MutingDevices.RawValue
        /// Whether this is a request or a forceful change
        public var isForceful: Bool

        /// Create a new Mute Request
        /// - Parameters:
        ///   - rtcId: RTC Id of the target remote user
        ///   - mute: Whether the request is to mute or unmute a device
        ///   - device: Device to be muted or unmuted
        ///   - isForceful: Whether this is a request or a forceful change
        public init(
            rtcId: UInt, mute: Bool,
            device: AgoraRtmController.MutingDevices, isForceful: Bool
        ) {
            self.rtcId = rtcId
            self.mute = mute
            self.device = device.rawValue
            self.isForceful = isForceful
        }
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
        self.rtmLogin() {_ in}
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
                   AgoraVideoViewer.agoraPrint(.debug, message: "could not fetch token: \(failErr)")
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
            AgoraVideoViewer.agoraPrint(.debug, message: "logged into rtm")
            for step in self.afterLoginSteps {
                step()
            }
            self.afterLoginSteps.removeAll()
            return
        case .unknown, .rejected, .invalidArgument, .invalidAppId,
             .invalidToken, .tokenExpired, .notAuthorized,
             .timeout, .loginTooOften, .loginNotInitialized:
            AgoraVideoViewer.agoraPrint(.debug, message: "could not log into rtm")
        @unknown default:
            AgoraVideoViewer.agoraPrint(.debug, message: "unknown login code")
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
            newChannel.join() {
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
            AgoraVideoViewer.agoraPrint(.debug, message: "joined channel!")
            self.sendPersonalData(to: channel)
            self.channels[name] = channel
        case .channelErrorFailure, .channelErrorRejected,
             .channelErrorInvalidArgument, .channelErrorTimeout,
             .channelErrorExceedLimit, .channelErrorAlreadyJoined,
             .channelErrorTooOften, .sameChannelErrorTooOften,
             .channelErrorNotInitialized, .channelErrorNotLoggedIn:
            AgoraVideoViewer.agoraPrint(.debug, message: "could not join channel")
        @unknown default:
            AgoraVideoViewer.agoraPrint(.debug, message: "join channel unknown response")
        }
    }

    /// Devices that can be muted/unmuted
    public enum MutingDevices: Int, CaseIterable {
        /// The device camera
        case camera
        /// The device microphone
        case microphone
    }


    /// Create and send request to user to mute/unmute a device
    /// - Parameters:
    ///   - uid: RTM User ID to send the request to
    ///   - str: String from the action label to
    /// - Returns: Boolean stating if the request was valid or not
    open func createRequest(
        to uid: UInt,
        fromString str: String
    ) -> Bool {
        switch str {
        case MPButton.unmuteCameraString:
            self.sendMuteRequest(to: uid, mute: false, device: .camera)
        case MPButton.muteCameraString:
            self.sendMuteRequest(to: uid, mute: true, device: .camera)
        case MPButton.unmuteMicString:
            self.sendMuteRequest(to: uid, mute: false, device: .microphone)
        case MPButton.muteMicString:
            self.sendMuteRequest(to: uid, mute: true, device: .microphone)
        default:
            return false
        }
        return true
    }

    /// Create and send request to mute/unmute a device
    /// - Parameters:
    ///   - rtcId: RTC User ID to send the request to
    ///   - mute: Whether the device should be muted or unmuted
    ///   - device: Type of device (camera/microphone)
    ///   - isForceful: Whether the request should force its way through, otherwise a request is made
    open func sendMuteRequest(to rtcId: UInt, mute: Bool, device: MutingDevices, isForceful: Bool = false) {
        let muteReq = MuteRequest(rtcId: rtcId, mute: mute, device: device, isForceful: isForceful)
        self.sendRaw(message: muteReq, user: rtcId) { sendStatus in
            if sendStatus == .ok {
                print("message was sent!")
            } else {
                print(sendStatus)
            }
        }
    }
}

extension AgoraRtmController: AgoraRtmDelegate, AgoraRtmChannelDelegate {
    /// The token used to connect to the current active channel has expired.
    /// - Parameter kit: Agora RTM Engine
    open func rtmKitTokenDidExpire(_ kit: AgoraRtmKit) {
        if let tokenURL = self.videoViewer.agoraSettings.tokenURL {
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
    open func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        if let rawMsg = message as? AgoraRtmRawMessage {
            self.decodeRawMessage(rawMsg: rawMsg, from: member.userId)
        }
    }

    /// Decode an incoming AgoraRtmRawMessage
    /// - Parameters:
    ///   - rawMsg: Incoming Raw message.
    ///   - peerId: Id of the peer this message is coming from
    open func decodeRawMessage(rawMsg: AgoraRtmRawMessage, from peerId: String) {
        if let decodedRaw = self.decodeStream(data: rawMsg.rawData, from: peerId) {
            switch decodedRaw {
            case .mute(let muteReq):
                self.videoViewer.handleMuteRequest(muteReq: muteReq)
            case .userData(let user):
                AgoraVideoViewer.agoraPrint(
                    .error, message: "Received user data: \(user.rtmId), \(String(describing: user.rtcId))"
                )
                self.rtmLookup[user.rtmId] = user
                if let rtcId = user.rtcId {
                    self.rtcLookup[rtcId] = user.rtmId
                }
            }
        }
    }

}

// MARK: Helper Methods
extension AgoraRtmController {
    /// Type of decoded stream coming from other users
    public enum DecodedRtmMessage {
        /// Mute is when a user is requesting another user to mute or unmute a device
        case mute(_: MuteRequest)
        /// DecodedRtmMessage type containing data about a user (local or remote)
        case userData(_: UserData)
    }
    func decodeStream(data: Data, from rtmId: String) -> DecodedRtmMessage? {
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

extension AgoraRtmController {

    /// Error types to expect from fetchToken on failing ot retrieve valid token.
    public enum TokenError: Error {
        /// No data returned from the token request
        case noData
        /// Data corrupted or in the wrong format
        case invalidData
        /// URL could not be created
        case invalidURL
    }

    /// Requests the token from our backend token service
    /// - Parameter urlBase: base URL specifying where the token server is located
    /// - Parameter channelName: Name of the channel we're requesting for
    /// - Parameter userId: User ID of the user trying to join (0 for any user)
    /// - Parameter callback: Callback method for returning either the string token or error
    public static func fetchRtmToken(
        urlBase: String, userId: String,
        callback: @escaping (Result<String, Error>) -> Void
    ) {
        guard let fullURL = URL(string: "\(urlBase)/rtm/\(userId)") else {
            callback(.failure(TokenError.invalidURL))
            return
        }
        var request = URLRequest(
            url: fullURL,
            timeoutInterval: 10
        )
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, _, err in
            guard let data = data else {
                if let err = err {
                    callback(.failure(err))
                } else {
                    callback(.failure(TokenError.noData))
                }
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON as? [String: Any], let token = responseDict["rtmToken"] as? String {
                callback(.success(token))
            } else {
                callback(.failure(TokenError.invalidData))
            }
        }

        task.resume()
    }

    func newTokenFetched(result: Result<String, Error>) {
        switch result {
        case .success(let token):
            self.updateToken(token)
        case .failure(let err):
            AgoraVideoViewer.agoraPrint(.debug, message: "Could not fetch rtm token: \(err)")
            break
        }
    }

    func updateToken(_ token: String) {
        self.rtmKit.renewToken(token) { token, renewStatus in
            switch renewStatus {
            case .ok:
               AgoraVideoViewer.agoraPrint(.debug, message: "token renewal success")
            case .failure, .invalidArgument, .rejected, .tooOften,
                 .tokenExpired, .invalidToken,
                 .notInitialized, .notLoggedIn:
                AgoraVideoViewer.agoraPrint(.debug, message: "cannot renew token: \(renewStatus): \(renewStatus.rawValue)")
            @unknown default:
                AgoraVideoViewer.agoraPrint(.debug, message: "cannot renew token (unknown): \(renewStatus): \(renewStatus.rawValue)")
           }
        }
    }
}

