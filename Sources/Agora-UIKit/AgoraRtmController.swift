//
//  AgoraRtmController.swift
//  AgoraUIKit_macOS
//
//  Created by Max Cobb on 14/07/2021.
//

import AgoraRtcKit
import AgoraRtmKit

/// Delegate for fetching data for our RTM Controller
public protocol RtmControllerDelegate: AnyObject {
    /// Instance of the RTC Engine being used
    var rtcEngine: AgoraRtcEngineKit { get }
    /// Struct for holding data about the connection to Agora service
    var agConnection: AgoraConnectionData { get set }
    /// Settings used for the display and behaviour
    var agSettings: AgoraSettings { get }
    /// Handle mute request, by showing popup or directly changing the device state
    /// - Parameter muteReq: Incoming mute request data
    func handleMuteRequest(muteReq: AgoraRtmController.MuteRequest)
    /// A pong request has just come back to the local user, indicating that someone is still present in RTM
    /// - Parameter peerId: RTM ID of the remote user that sent the pong request.
    func handlePongRequest(from peerId: String)
    /// Property used to access all the RTC connections to other broadcasters in an RTC channel
    var videoLookup: [UInt: AgoraSingleVideoView] { get }
    /// The role for the user. Either `.audience` or `.broadcaster`.
    var userRole: AgoraClientRole { get set }
    /// Delegate for the AgoraVideoViewer, used for some important callback methods.
    var agoraViewerDelegate: AgoraVideoViewerDelegate? { get }
}

public extension AgoraVideoViewer {
    var agoraViewerDelegate: AgoraVideoViewerDelegate? {
        return self.delegate
    }
}

extension AgoraVideoViewer: RtmControllerDelegate {
    public var agConnection: AgoraConnectionData {
        get { self.connectionData }
        set { self.connectionData = newValue }
    }
    public var rtcEngine: AgoraRtcEngineKit { self.agkit }
    public var agSettings: AgoraSettings { self.agoraSettings }
    public var videoLookup: [UInt: AgoraSingleVideoView] { self.userVideoLookup }
    public func handlePongRequest(from peerId: String) {
        self.delegate?.incomingPongRequest(from: peerId)
    }
}

/// Class for controlling the RTM messages
open class AgoraRtmController: NSObject {
    /// Instance of the RTC Engine being used
    var engine: AgoraRtcEngineKit { self.delegate.rtcEngine }
    /// Struct for holding data about the connection to Agora service
    var connectionData: AgoraConnectionData { self.delegate.agConnection }
    /// Settings used for the display and behaviour
    var agoraSettings: AgoraSettings { self.delegate.agSettings }
    /// Delegate for fetching data for our RTM Controller
    weak var delegate: RtmControllerDelegate!

    /// Status of the RTM Engine
    public enum RTMStatus {
        /// Initialisation failed
        case initFailed
        /// Login has not been attempted
        case offline
        /// RTM is initialising, process is not yet complete
        case initialising
        /// Currently attempting to log in
        case loggingIn
        /// RTM has logged in
        case loggedIn
        /// RTM is logged in, and connected to the current channel
        case connected
        /// RTM Login Failed
        case loginFailed(AgoraRtmLoginErrorCode)
    }
    /// Status of the RTM Engine
    public internal(set) var rtmStatus: RTMStatus = .initialising {
        didSet {
            self.delegate.agoraViewerDelegate?.rtmStateChanged(from: oldValue, to: self.rtmStatus)
        }
    }

    /// Reference to the Agora Real-time Messaging engine used by this class.
    public internal(set) var rtmKit: AgoraRtmKit
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
            AgoraVersions(rtm: AgoraRtmKit.getSDKVersion(), rtc: AgoraRtcEngineKit.getSdkVersion())
        }
        /// Version string of the RTM SDK
        var rtm: String
        /// Version string of the RTC SDK
        var rtc: String
        func prettyPrint() -> String {
            """
                rtc: \(rtc)
                rtm: \(rtm)
            """
        }
    }

    var personalData: UserData {
        UserData(
            rtmId: self.connectionData.rtmId,
            rtcId: self.connectionData.rtcId == 0 ? nil : self.connectionData.rtcId,
            username: self.connectionData.username, role: self.delegate.userRole.rawValue
        )
    }

    init?(delegate: RtmControllerDelegate) {
        self.delegate = delegate
        if let rtmKit = AgoraRtmKit(appId: delegate.agConnection.appId, delegate: nil) {
            self.rtmKit = rtmKit
        } else { return nil }
        super.init()
        self.rtmStatus = .offline
        self.rtmKit.agoraRtmDelegate = self
        self.rtmLogin {_ in}
    }

    func rtmLogin(completion: @escaping (AgoraRtmLoginErrorCode) -> Void) {
        self.rtmStatus = .loggingIn
        if let tokenURL = self.agoraSettings.tokenURL {
            AgoraRtmController.fetchRtmToken(urlBase: tokenURL, userId: self.connectionData.rtmId) { fetchResult in
                switch fetchResult {
                case .success(let token):
                    self.rtmKit.login(byToken: token, user: self.connectionData.rtmId
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
                byToken: self.connectionData.rtmToken, user: self.connectionData.rtmId
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
            self.rtmStatus = .loggedIn
            for step in self.afterLoginSteps { step() }
            self.afterLoginSteps.removeAll()
            return
        case .unknown, .rejected, .invalidArgument, .invalidAppId,
             .invalidToken, .tokenExpired, .notAuthorized,
             .timeout, .loginTooOften, .loginNotInitialized:
            AgoraVideoViewer.agoraPrint(.error, message: "could not log into rtm: \(code.rawValue)")
        @unknown default:
            AgoraVideoViewer.agoraPrint(.error, message: "unknown login code")
        }
        self.rtmStatus = .loginFailed(code)
    }

    /// Joins an RTM channel.
    /// - Parameters:
    ///   - channel: Channel name to join
    ///   - callback: Join completion with channel name, channel object and join status code.
    open func joinChannel(
        named channel: String,
        callback: (
            (String, AgoraRtmChannel, AgoraRtmJoinChannelErrorCode) -> Void
        )? = nil
    ) {
        switch rtmStatus {
        case .offline:
            self.rtmLogin { err in
                if err == .ok || err == .alreadyLogin {
                    self.joinChannel(named: channel, callback: callback)
                } else {
                    AgoraVideoViewer.agoraPrint(.error, message: "Could not login to rtm")
                }
            }
        case .loggingIn:
            self.afterLoginSteps.append { self.joinChannel(named: channel, callback: callback) }
        case .loginFailed(let loginErr):
            AgoraVideoViewer.agoraPrint(.error, message: "login failed: \(loginErr.rawValue)")
        case .loggedIn, .connected:
            guard let newChannel = self.rtmKit.createChannel(withId: channel, delegate: self) else {
                return
            }
            newChannel.join {
                callback?(channel, newChannel, $0)
                self.rtmChannelJoined(name: channel, channel: newChannel, code: $0)
            }
        case .initialising:
            self.afterLoginSteps.append {
                self.joinChannel(named: channel, callback: callback)
            }
        case .initFailed:
            AgoraVideoViewer.agoraPrint(.error, message: "Cannot log into a channel if RTM failed")
        }
    }

    /// Leave RTM channel by name.
    /// - Parameter channel: name of the channel you want to leave.
    open func leaveChannel(named channel: String) {
        if let rtmChannel = self.channels[channel] {
            rtmChannel.leave { leaveStatus in
                if leaveStatus == .ok {
                    AgoraVideoViewer.agoraPrint(.verbose, message: "Successfully left RTM channel")
                    self.channels.removeValue(forKey: channel)
                    return
                }
                AgoraVideoViewer.agoraPrint(
                    .error, message: "Could not leave RTM channel \(channel): \(leaveStatus.rawValue)"
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
            self.rtmStatus = .connected
            self.sendPersonalData(to: channel)
            self.channels[name] = channel
        case .channelErrorFailure, .channelErrorRejected, .channelErrorInvalidArgument,
             .channelErrorTimeout, .channelErrorExceedLimit, .channelErrorAlreadyJoined,
             .channelErrorTooOften, .sameChannelErrorTooOften, .channelErrorNotInitialized,
             .channelErrorNotLoggedIn:
            AgoraVideoViewer.agoraPrint(.error, message: "could not join channel: \(code.rawValue)")
        @unknown default:
            AgoraVideoViewer.agoraPrint(.error, message: "join channel unknown response: \(code.rawValue)")
        }
    }
}
