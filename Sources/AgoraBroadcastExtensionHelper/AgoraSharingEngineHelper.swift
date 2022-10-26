//
//  AgoraSharingEngineHelper.swift
//  AgoraBroadcastExtensionHelper
//
//  Created by Max Cobb on 20/10/2022.
//

import Foundation
import CoreMedia
import ReplayKit
import AgoraRtcKit

/// This is the class used to control the Agora RTC Engine from within an app extension.
/// Use this as a superclass and follow instructions in ``AgoraBroadcastSampleHandler``
/// to add your own custom logic.
open class AgoraSharingEngineHelper {
    @discardableResult
    /// Initialize the AgoraSharingEngineHelper
    /// - Parameter appId: appID to initialise the engine with.
    /// - Returns: AgoraRtcEngineKit instance
    public static func initialize(appId: String, delegate: AgoraRtcEngineDelegate? = nil) -> AgoraRtcEngineKit {
        let config = AgoraRtcEngineConfig()
        config.appId = appId
        config.channelProfile = .liveBroadcasting
        let agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: delegate)
        AgoraSharingEngineHelper.agoraEngine = agoraEngine
        agoraEngine.enableVideo()
        agoraEngine.setExternalVideoSource(true, useTexture: true, sourceType: .videoFrame)
        let videoConfig = AgoraVideoEncoderConfiguration(
            size: videoDimension,
            frameRate: .fps10,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .adaptative, mirrorMode: .auto
        )
        agoraEngine.setVideoEncoderConfiguration(videoConfig)

        agoraEngine.setAudioProfile(.default)
        agoraEngine.setExternalAudioSource(true, sampleRate: Int(audioSampleRate), channels: Int(audioChannels))
        agoraEngine.muteAllRemoteVideoStreams(true)
        agoraEngine.muteAllRemoteAudioStreams(true)
        return agoraEngine
    }

    /// Agora engine instance. Call ``AgoraSharingEngineHelper/initialize(appId:)`` to create this.
    static public internal(set) var agoraEngine: AgoraRtcEngineKit?

    // Set the audio configuration
    private static let audioSampleRate: UInt = 44100
    private static let audioChannels: UInt = 2

    // Get the screen size and orientation
    private static let videoDimension: CGSize = {
        let screenSize = UIScreen.main.currentMode!.size
        var boundingSize = CGSize(width: 540, height: 980)
        let vidWidth = boundingSize.width / screenSize.width
        let vidHeight = boundingSize.height / screenSize.height
        if vidHeight < vidWidth {
            boundingSize.width = boundingSize.height / screenSize.height * screenSize.width
        } else if vidWidth < vidHeight {
            boundingSize.height = boundingSize.width / screenSize.width * screenSize.height
        }
        return boundingSize
    }()

    /// Configure agoraEngine to use custom video with no audio, then join the channel.
    /// - Parameters:
    ///   - channel: Channel to join.
    ///   - token: Token to use on joining the channel.
    ///   - uid: User ID to use when joining the channel.
    ///   - joinSuccess: Callback that happens once the channel has been joined successfully.
    static func startScreenSharing(
        to channel: String, with token: String? = nil, uid: UInt = 0,
        joinSuccess: ((String, UInt, Int) -> Void)? = nil
    ) {
        guard let agoraEngine = agoraEngine else {
            fatalError("Call ScreenSharingAgoraEngine.initialize() before sharing!")
        }

        let channelMediaOptions = AgoraRtcChannelMediaOptions()
        channelMediaOptions.publishMicrophoneTrack = false
        channelMediaOptions.publishCameraTrack = false
        channelMediaOptions.publishCustomVideoTrack = true
        channelMediaOptions.publishCustomAudioTrack = true
        channelMediaOptions.autoSubscribeAudio = false
        channelMediaOptions.autoSubscribeVideo = false
        channelMediaOptions.clientRoleType = .broadcaster

        agoraEngine.joinChannel(
            byToken: token, channelId: channel, uid: uid,
            mediaOptions: channelMediaOptions, joinSuccess: joinSuccess
        )
    }

    /// Leave channel and then destroy the engine instance.
    static func stopScreenSharing() {
        agoraEngine?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }

    /// Retrieve the local video frame, figure out the orientation and duration of the buffer and send it to the channel.
    /// - Parameter sampleBuffer: The current buffer of media data.
    public static func sendVideoBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        var rotation: Int32 = 0
        if let orientationAttachment = CMGetAttachment(
            sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil
        ) as? NSNumber {
            if let orientation = CGImagePropertyOrientation(rawValue: orientationAttachment.uint32Value) {
                switch orientation {
                case .up, .upMirrored: rotation = 0
                case .down, .downMirrored: rotation = 180
                case .left, .leftMirrored: rotation = 90
                case .right, .rightMirrored: rotation = 270
                default:   break
                }
            }
        }
        let time = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 1000 * 1000)

        let frame = AgoraVideoFrame()
        frame.format = 12
        frame.time = time
        frame.textureBuf = videoFrame
        frame.rotation = rotation
        agoraEngine?.pushExternalVideoFrame(frame)
    }

    /// Override this method to capture and send audio from apps on the broadcaster's device.
    /// - Parameter sampleBuffer: The current buffer from an app on the broadcaster's device.
    public static func sendAudioAppBuffer(_ sampleBuffer: CMSampleBuffer) {

    }

    /// Override this method to capture and send audio from the broadcaster's microphone.
    /// - Parameter sampleBuffer: The current buffer from the local microphone.
    public static func sendAudioMicBuffer(_ sampleBuffer: CMSampleBuffer) {

    }

}
