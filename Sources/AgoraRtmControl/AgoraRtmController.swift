//
//  AgoraRtmController.swift
//  AgoraUIKit_macOS
//
//  Created by Max Cobb on 14/07/2021.
//

import AgoraRtmKit

/// Delegate for fetching data for our RTM Controller
public protocol RtmControllerDelegate: AnyObject {
    /// Called after AgoraRtmController joins a channel
    /// - Parameters:
    ///   - name: name of the channel joined
    ///   - channel: instance of joined `AgoraRtmChannel`
    ///   - code: Error codes related to joining a channel.
    func rtmChannelJoined(
        name: String, channel: AgoraRtmChannel,
        code: AgoraRtmJoinChannelErrorCode
    )

    /// Lookup remote user RTM ID based on their RTC ID
    var rtcLookup: [UInt: String] { get set }
    /// Get remote user data from their RTM ID
    var rtmLookup: [String: Codable] { get set }

    /// Delegate used for RTM
    var rtmDelegate: AgoraRtmDelegate? { get }
    /// Delegate used for RTM channel messages
    var rtmChannelDelegate: AgoraRtmChannelDelegate? { get }
    /// ID used by RTM
    var rtmId: String { get }
    /// ID used by RTC
    var rtcId: UInt? { get }
    /// App ID used, found on console.agora.io
    var appId: String { get }
    /// Token to connect to Agora RTM
    var rtmToken: String? { get set }
    /// URL for fetching Agora RTM tokens
    var tokenURL: String? { get set }
    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember)
    /// Method to catch messages incoming from RTM, used to decode them and run any relevant actions
    /// - Parameters:
    ///   - message: Message received from RTM
    ///   - peerId: ID of the user who sent the message
    func decodeMessage(message: AgoraRtmMessage, from peerId: String)
    /// State of the RTM Controller has changed
    /// - Parameters:
    ///   - oldState: Previous state of AgoraRtmController
    ///   - newState: New state of AgoraRtmController
    func rtmStateChanged(from oldState: AgoraRtmController.RTMStatus, to newState: AgoraRtmController.RTMStatus)
}

/// Class for controlling the RTM messages
open class AgoraRtmController: NSObject {

    /// Print level that will be visible in the developer console, default `.error`
    public static var printLevel: PrintType = .warning
    /// Level for an internal print statement
    public enum PrintType: Int {
        /// To use when an internal error has occurred
        case error = 0
        /// To use when something is not being used or running correctly
        case warning = 1
        /// To use for debugging issues
        case debug = 2
        /// To use when we want all the possible logs
        case verbose = 3
        var printString: String {
            switch self {
            case .error: return "ERROR"
            case .warning: return "WARNING"
            case .debug: return "DEBUG"
            case .verbose: return "INFO"
            }
        }
    }

    internal static func agoraPrint(_ tag: PrintType, message: Any) {
        if tag.rawValue <= AgoraRtmController.printLevel.rawValue {
            print("[AgoraRtmController \(tag.printString)]: \(message)")
        }
    }
    var rtmDelegate: AgoraRtmDelegate? { self.delegate.rtmDelegate }
    var rtmChannelDelegate: AgoraRtmChannelDelegate? { self.delegate.rtmChannelDelegate }
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
            self.delegate.rtmStateChanged(from: oldValue, to: self.rtmStatus)
        }
    }

    /// Reference to the Agora Real-time Messaging engine used by this class.
    public internal(set) var rtmKit: AgoraRtmKit
    /// RTM Channels created and joined by this RTM Controller
    public internal(set) var channels: [String: AgoraRtmChannel] = [:]
    /// Methods to be completed after login has finished (such as joining a channel)
    public internal(set) var afterLoginSteps: [() -> Void] = []

    public init?(delegate: RtmControllerDelegate) {
        self.delegate = delegate
        if let rtmKit = AgoraRtmKit(appId: delegate.appId, delegate: nil) {
            self.rtmKit = rtmKit
        } else { return nil }
        super.init()
        self.rtmStatus = .offline
        self.rtmKit.agoraRtmDelegate = self
        self.rtmLogin {_ in}
    }

    func rtmLogin(completion: @escaping (AgoraRtmLoginErrorCode) -> Void) {
        self.rtmStatus = .loggingIn
        if let tokenURL = self.delegate.tokenURL, let rtmId = self.delegate?.rtmId {
            AgoraRtmController.fetchRtmToken(urlBase: tokenURL, userId: rtmId) { fetchResult in
                switch fetchResult {
                case .success(let token):
                    self.rtmKit.login(byToken: token, user: rtmId
                    ) { errcode in
                        self.rtmLoggedIn(code: errcode)
                        completion(errcode)
                    }
                case .failure(let failErr):
                    completion(.invalidToken)
                    AgoraRtmController.agoraPrint(.error, message: "could not fetch token: \(failErr)")
                }
            }
        } else {
            self.rtmKit.login(
                byToken: self.delegate.rtmToken, user: self.delegate.rtmId
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
            AgoraRtmController.agoraPrint(.error, message: "could not log into rtm: \(code.rawValue)")
        @unknown default:
            AgoraRtmController.agoraPrint(.error, message: "unknown login code")
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
                    AgoraRtmController.agoraPrint(.error, message: "Could not login to rtm")
                }
            }
        case .loggingIn:
            self.afterLoginSteps.append { self.joinChannel(named: channel, callback: callback) }
        case .loginFailed(let loginErr):
            AgoraRtmController.agoraPrint(.error, message: "login failed: \(loginErr.rawValue)")
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
            AgoraRtmController.agoraPrint(.error, message: "Cannot log into a channel if RTM failed")
        }
    }

    /// Leave RTM channel by name.
    /// - Parameter channel: name of the channel you want to leave.
    open func leaveChannel(named channel: String) {
        if let rtmChannel = self.channels[channel] {
            rtmChannel.leave { leaveStatus in
                if leaveStatus == .ok {
                    AgoraRtmController.agoraPrint(.verbose, message: "Successfully left RTM channel")
                    self.channels.removeValue(forKey: channel)
                    return
                }
                AgoraRtmController.agoraPrint(
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
            self.channels[name] = channel
        case .channelErrorFailure, .channelErrorRejected, .channelErrorInvalidArgument,
             .channelErrorTimeout, .channelErrorExceedLimit, .channelErrorAlreadyJoined,
             .channelErrorTooOften, .sameChannelErrorTooOften, .channelErrorNotInitialized,
             .channelErrorNotLoggedIn:
            AgoraRtmController.agoraPrint(.error, message: "could not join channel: \(code.rawValue)")
        @unknown default:
            AgoraRtmController.agoraPrint(.error, message: "join channel unknown response: \(code.rawValue)")
        }
        self.delegate?.rtmChannelJoined(name: name, channel: channel, code: code)
    }
}
