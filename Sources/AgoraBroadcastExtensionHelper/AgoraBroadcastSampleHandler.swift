//
//  AgoraBroadcastSampleHandler.swift
//  AgoraBroadcastExtensionHelper
//
//  Created by Max Cobb on 21/10/2022.
//

import Foundation
import ReplayKit
import AgoraAppGroupDataHelper
import AgoraRtcKit

/// Struct that tells the broadcast extension what properties to use when joining the video stream.
/// Use ``AgoraBroadcastSampleHandler/getAppGroup()`` instead if possible.
public struct AgoraBroadcastExtData {
    /// Agora App ID. Fetched from Agora Console at [console.agora.io](https://console.agora.io)
    public var appId: String
    /// Channel that you want the broadcaster to join.
    public var channel: String
    /// Token to be used to join the channel with the given user ID.
    public var token: String?
    /// User ID for the screen sharing client.
    public var uid: UInt = 0

    /// Create a Broadcast Extension Data struct.
    /// - Parameters:
    ///   - appId: Agora App ID. Fetched from Agora Console at [console.agora.io](https://console.agora.io)
    ///   - channel: Channel that you want the broadcaster to join.
    ///   - token: Token to be used to join the channel with the given user ID.
    ///   - uid: User ID for the screen sharing client.
    public init(appId: String, channel: String, token: String? = nil, uid: UInt) {
        self.appId = appId
        self.channel = channel
        self.token = token
        self.uid = uid
    }
}

/// Use this class to broadcast your apps easily.
///
/// By default, no audio (app or microphone) data will be sent from screensharing.
/// To enable this, you will need to subclass ``AgoraSharingEngineHelper``, override
/// ``AgoraSharingEngineHelper/sendAudioAppBuffer(_:)`` and/or ``AgoraSharingEngineHelper/sendAudioMicBuffer(_:)``,
/// then set ``AgoraBroadcastSampleHandler/sharingEngineClass`` to your new class.
open class AgoraBroadcastSampleHandler: RPBroadcastSampleHandler {
    /// Override this method and return the string App Group.
    /// - Returns: App Group found in both the main app and broadcast extension.
    open func getAppGroup() -> String? { return nil }
    /// Override this method to return a struct containing the screen sharing client data
    /// - Returns: Connection data for the screen sharing client.
    open func getBroadcastData() -> AgoraBroadcastExtData? { return nil }

    /// If you want to sublcass ``AgoraSharingEngineHelper`` to change the behaviour,
    /// override this static property with the desired class.
    public static var sharingEngineClass: AgoraSharingEngineHelper.Type = AgoraSharingEngineHelper.self

    /// Print level that will be visible in the developer console, default ``AgoraBroadcastSampleHandler/LogLevel-swift.enum/warning``
    public static var logLevel: LogLevel = .warning
    /// Level for an internal print statement
    public enum LogLevel: Int {
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

    internal static func agoraPrint(
        _ tag: LogLevel, _ items: Any..., separator: String = " ", terminator: String = "\n"
    ) {
        if tag.rawValue <= AgoraBroadcastSampleHandler.logLevel.rawValue {
            print("[AgoraBroadcastSampleHandler \(tag.printString)]: ", items,
                  separator: separator, terminator: terminator)
        }
    }

    /// The last sent video buffer.
    public internal(set) var videoBufferCopy: CMSampleBuffer?
    /// Time in seconds of the last sent video frame since 1970.
    public internal(set) var lastSentVideoTs: TimeInterval?
    /// This timer is created with ``AgoraBroadcastSampleHandler/sendFrameIfFrozenTimer()``.
    /// It will send a frame if it's been too long since the last frame was sent. This stops the stream from being frozen when viewed from remote.
    /// Override ``AgoraBroadcastSampleHandler/sendFrameIfFrozenTimer()`` with another logic,
    /// or empty logic to remove.
    public internal(set) var frozenImageTimer: Timer?

    override open func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        if let appGroup = self.getAppGroup() {
            self.broadcastWithAppGroup(appGroup: appGroup)
            return
        } else if let broadcastData = self.getBroadcastData() {
            self.broadcastWith(
                appId: broadcastData.appId, channel: broadcastData.channel,
                token: broadcastData.token, uid: broadcastData.uid
            )
        } else {
            self.finishBroadcastWithError(AgoraBroadcastError.noBroadcastData)
        }
    }
    /// Start broadcasting with required properties. It is not recommended to call this method directly.
    /// Instead make sure that the app group is passed with overriding ``AgoraBroadcastSampleHandler/getAppGroup()``,
    /// Or the data are given with ``AgoraBroadcastSampleHandler/getBroadcastData()``.
    /// - Parameters:
    ///   - appId: Agora App ID. Fetched from Agora Console at [console.agora.io](https://console.agora.io)
    ///   - channel: Channel that you want the broadcaster to join.
    ///   - token: Token to be used to join the channel with the given user ID.
    ///   - uid: User ID for the screen sharing client.
    open func broadcastWith(appId: String, channel: String, token: String?, uid: UInt) {
        AgoraBroadcastSampleHandler.sharingEngineClass.initialize(appId: appId, delegate: self)
        AgoraBroadcastSampleHandler.sharingEngineClass.startScreenSharing(
            to: channel, with: token,
            uid: uid
        )
        self.sendFrameIfFrozenTimer()
    }

    /// This method will send a frame if it's been too long since the last frame was sent. This stops the stream from being frozen when viewed from remote.
    /// Override this method with another logic, or empty logic to remove.
    open func sendFrameIfFrozenTimer() {
        DispatchQueue.main.async {
            self.frozenImageTimer = Timer.scheduledTimer(
                withTimeInterval: 0.1, repeats: true
            ) {[weak self] _ in
                guard let weakSelf = self, let lastSentTs = weakSelf.lastSentVideoTs else { return }
                // if frame stopped sending for too long time, resend the last frame
                // to avoid stream being frozen when viewed from remote
                if Date().timeIntervalSince1970 - lastSentTs > 0.3 {
                    if let buffer = weakSelf.videoBufferCopy {
                        weakSelf.processSampleBuffer(buffer, with: .video)
                    }
                }
            }
        }
    }
    /// Start the broadcast with an app group provided.
    /// - Note: To use this, you must also provide at least appId and channel in UserDefaults.  AgoraAppGroupDataHelper is made to help with this.
    /// - Parameter appGroup: App Group given to the app and broadcast extension.
    open func broadcastWithAppGroup(appGroup: String) {
        if appGroup.isEmpty {
            self.finishBroadcastWithError(AgoraBroadcastError.invalidAppGroup)
            return
        }
        AgoraAppGroupDataHelper.appGroup = appGroup
        if let appId = AgoraAppGroupDataHelper.getString(for: .appId),
           let channel = AgoraAppGroupDataHelper.getString(for: .channel) {
            let uid = UInt(AgoraAppGroupDataHelper.getString(for: .uid) ?? "0") ?? 0
            self.broadcastWith(
                appId: appId, channel: channel,
                token: AgoraAppGroupDataHelper.getString(for: .token), uid: uid
            )
        } else {
            // You have to use App Group to pass information/parameter
            // from main app to extension
            AgoraBroadcastSampleHandler.agoraPrint(.error, "Tried using App Groups, but missing appID or channel")
            self.finishBroadcastWithError(AgoraBroadcastError.badAppGroupData)
        }
    }

    override open func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }

    override open func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }

    override open func broadcastFinished() {
        frozenImageTimer?.invalidate()
        frozenImageTimer = nil
        AgoraBroadcastSampleHandler.sharingEngineClass.stopScreenSharing()
    }

    override open func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        DispatchQueue.main.async { [weak self] in
            switch sampleBufferType {
            case .video:
                if let weakSelf = self {
                    weakSelf.videoBufferCopy = sampleBuffer
                    weakSelf.lastSentVideoTs = Date().timeIntervalSince1970
                }
                AgoraBroadcastSampleHandler.sharingEngineClass.sendVideoBuffer(sampleBuffer)
            case .audioApp:
                AgoraBroadcastSampleHandler.sharingEngineClass.sendAudioAppBuffer(sampleBuffer)
            case .audioMic:
                AgoraBroadcastSampleHandler.sharingEngineClass.sendAudioMicBuffer(sampleBuffer)
            @unknown default:
                break
            }
        }
    }

    override open func finishBroadcastWithError(_ error: Error) {
        if let err = error as? AgoraBroadcastError {
            err.printError()
        } else {
            AgoraBroadcastSampleHandler.agoraPrint(.error, "other error: \(error.localizedDescription)")
        }
        super.finishBroadcastWithError(error)
    }
}

extension AgoraBroadcastSampleHandler: AgoraRtcEngineDelegate {
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        switch errorCode {
        case .invalidChannelId:
            self.finishBroadcastWithError(
                AgoraBroadcastError.joinChannelFailed(reason: "\(errorCode.rawValue): Bad channel ID"))
        case .invalidToken, .tokenExpired:
            self.finishBroadcastWithError(
                AgoraBroadcastError.joinChannelFailed(reason: "\(errorCode.rawValue): Token invalid or expired"))
        case .invalidAppId:
            self.finishBroadcastWithError(
                AgoraBroadcastError.joinChannelFailed(reason: "\(errorCode.rawValue): Bad app ID"))
        case .joinChannelRejected:
            self.finishBroadcastWithError(
                AgoraBroadcastError.joinChannelFailed(reason: "\(errorCode.rawValue): Join channel rejected"))
        default:
            AgoraBroadcastSampleHandler.agoraPrint(.warning, "Error code thrown: \(errorCode.rawValue)")
        }
    }
}
