//
//  AgoraVideoViewer+RtcEngineDelegateOverflow.swift
//  
//
//  Created by Max Cobb on 29/09/2021.
//

import AgoraRtcKit

extension AgoraVideoViewer {
    open func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineConnectionDidLost?(engine)
    }

    open func rtcEngineLocalAudioMixingDidFinish(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineLocalAudioMixingDidFinish?(engine)
    }

    open func rtcEngineRemoteAudioMixingDidStart(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineRemoteAudioMixingDidStart?(engine)
    }

    open func rtcEngineRemoteAudioMixingDidFinish(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineRemoteAudioMixingDidFinish?(engine)
    }

    open func rtcEngineVideoDidStop(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineVideoDidStop?(engine)
    }

    open func rtcEngineCameraDidReady(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineCameraDidReady?(engine)
    }

    open func rtcEngineTranscodingUpdated(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineTranscodingUpdated?(engine)
    }

    open func rtcEngineConnectionDidBanned(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineConnectionDidBanned?(engine)
    }

    open func rtcEngineAirPlayIsConnected(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineAirPlayIsConnected?(engine)
    }

    open func rtcEngineMediaEngineDidLoaded(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineMediaEngineDidLoaded?(engine)
    }

    open func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineConnectionDidInterrupted?(engine)
    }

    open func rtcEngineMediaEngineDidStartCall(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineMediaEngineDidStartCall?(engine)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didOccurWarning: warningCode)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didOccurError: errorCode)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didLeaveChannelWith: stats)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, networkTypeChangedToType type: AgoraNetworkType) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, networkTypeChangedToType: type)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, reportLocalVoicePitchFrequency pitchInHz: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, reportLocalVoicePitchFrequency: pitchInHz)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalAudioFrame elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstLocalAudioFrame: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didLocalPublishFallbackToAudioOnly isFallbackOrRecover: Bool) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didLocalPublishFallbackToAudioOnly: isFallbackOrRecover)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioRouteChanged routing: AgoraAudioOutputRouting) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioRouteChanged: routing)
    }

    #if os(iOS)
    open func rtcEngine(_ engine: AgoraRtcEngineKit, cameraFocusDidChangedTo rect: CGRect) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, cameraFocusDidChangedTo: rect)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, cameraExposureDidChangedTo rect: CGRect) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, cameraExposureDidChangedTo: rect)
    }
    #elseif os(macOS)
    public func rtcEngine(_ engine: AgoraRtcEngineKit, device deviceId: String, type deviceType: AgoraMediaDeviceType, stateChanged state: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, device: deviceId, type: deviceType, stateChanged: state)
    }
    #endif

    open func rtcEngine(_ engine: AgoraRtcEngineKit, reportRtcStats stats: AgoraChannelStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, reportRtcStats: stats)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, lastmileQuality quality: AgoraNetworkQuality) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, lastmileQuality: quality)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, lastmileProbeTest result: AgoraLastmileProbeResult) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, lastmileProbeTest: result)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStats stats: AgoraRtcLocalVideoStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, localVideoStats: stats)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioStats stats: AgoraRtcLocalAudioStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, localAudioStats: stats)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, remoteVideoStats stats: AgoraRtcRemoteVideoStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, remoteVideoStats: stats)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, remoteAudioStats stats: AgoraRtcRemoteAudioStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, remoteAudioStats: stats)
    }

    open func rtcEngineDidAudioEffectFinish(_ engine: AgoraRtcEngineKit, soundId: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngineDidAudioEffectFinish?(engine, soundId: soundId)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didReceive event: AgoraChannelMediaRelayEvent) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didReceive: event)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, streamUnpublishedWithUrl url: String) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, streamUnpublishedWithUrl: url)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didMicrophoneEnabled enabled: Bool) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didMicrophoneEnabled: enabled)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFramePublished elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstLocalVideoFramePublished: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, reportAudioVolumeIndicationOfSpeakers: speakers, totalVolume: totalVolume)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRegisteredLocalUser userAccount: String, withUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRegisteredLocalUser: userAccount, withUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didUpdatedUserInfo userInfo: AgoraUserInfo, withUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didUpdatedUserInfo: userInfo, withUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, connectionChangedTo: state, reason: reason)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstLocalVideoFrameWith: size, elapsed: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didVideoMuted: muted, byUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRemoteSubscribeFallbackToAudioOnly isFallbackOrRecover: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRemoteSubscribeFallbackToAudioOnly: isFallbackOrRecover, byUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, localAudioMixingStateDidChanged state: AgoraAudioMixingStateCode, reason: AgoraAudioMixingReasonCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, localAudioMixingStateDidChanged: state, reason: reason)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, channelMediaRelayStateDidChange state: AgoraChannelMediaRelayState, error: AgoraChannelMediaRelayError) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, channelMediaRelayStateDidChange: state, error: error)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameOfUid uid: UInt, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstRemoteAudioFrameOfUid: uid, elapsed: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameDecodedOfUid uid: UInt, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstRemoteAudioFrameDecodedOfUid: uid, elapsed: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioMuted muted: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioMuted: muted, byUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, streamPublishedWithUrl url: String, errorCode: AgoraErrorCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, streamPublishedWithUrl: url, errorCode: errorCode)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoEnabled enabled: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didVideoEnabled: enabled, byUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didLocalVideoEnabled enabled: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didLocalVideoEnabled: enabled, byUid: uid)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, rtmpStreamingEventWithUrl url: String, eventCode: AgoraRtmpStreamingEvent) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, rtmpStreamingEventWithUrl: url, eventCode: eventCode)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, virtualBackgroundSourceEnabled enabled: Bool, reason: AgoraVirtualBackgroundSourceStateReason) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, virtualBackgroundSourceEnabled: enabled, reason: reason)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, facePositionDidChangeWidth width: Int32, previewHeight height: Int32, faces: [AgoraFacePositionInfo]?) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, facePositionDidChangeWidth: width, previewHeight: height, faces: faces)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didApiCallExecute error: Int, api: String, result: String) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didApiCallExecute: error, api: api, result: result)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRejoinChannel: channel, withUid: uid, elapsed: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, videoSizeChangedOfUid uid: UInt, size: CGSize, rotation: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, videoSizeChangedOfUid: uid, size: size, rotation: rotation)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, networkQuality: uid, txQuality: txQuality, rxQuality: rxQuality)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, rtmpStreamingChangedToState url: String, state: AgoraRtmpStreamingState, errorCode: AgoraRtmpStreamingErrorCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, rtmpStreamingChangedToState: url, state: state, errorCode: errorCode)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, streamInjectedStatusOfUrl url: String, uid: UInt, status: AgoraInjectStreamStatus) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, streamInjectedStatusOfUrl: url, uid: uid, status: status)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: Data) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, receiveStreamMessageFromUid: uid, streamId: streamId, data: data)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstRemoteVideoFrameOfUid: uid, size: size, elapsed: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstRemoteVideoDecodedOfUid: uid, size: size, elapsed: elapsed)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, uploadLogResultRequestId requestId: String, success: Bool, reason: AgoraUploadErrorReason) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, uploadLogResultRequestId: requestId, success: success, reason: reason)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, superResolutionEnabledOfUid uid: UInt, enabled: Bool, reason: AgoraSuperResolutionStateReason) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, superResolutionEnabledOfUid: uid, enabled: enabled, reason: reason)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, audioTransportStatsOfUid uid: UInt, delay: UInt, lost: UInt, rxKBitRate: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, audioTransportStatsOfUid: uid, delay: delay, lost: lost, rxKBitRate: rxKBitRate)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, videoTransportStatsOfUid uid: UInt, delay: UInt, lost: UInt, rxKBitRate: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, videoTransportStatsOfUid: uid, delay: delay, lost: lost, rxKBitRate: rxKBitRate)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, audioQualityOfUid uid: UInt, quality: AgoraNetworkQuality, delay: UInt, lost: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, audioQualityOfUid: uid, quality: quality, delay: delay, lost: lost)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioPublishStateChange channel: String, oldState: AgoraStreamPublishState, newState: AgoraStreamPublishState, elapseSinceLastState: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioPublishStateChange: channel, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoPublishStateChange channel: String, oldState: AgoraStreamPublishState, newState: AgoraStreamPublishState, elapseSinceLastState: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didVideoPublishStateChange: channel, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioSubscribeStateChange channel: String, withUid uid: UInt, oldState: AgoraStreamSubscribeState, newState: AgoraStreamSubscribeState, elapseSinceLastState: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioSubscribeStateChange: channel, withUid: uid, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoSubscribeStateChange channel: String, withUid uid: UInt, oldState: AgoraStreamSubscribeState, newState: AgoraStreamSubscribeState, elapseSinceLastState: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didVideoSubscribeStateChange: channel, withUid: uid, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }

    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didOccurStreamMessageErrorFromUid: uid, streamId: streamId, error: error, missed: missed, cached: cached)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, contentInspectResult result: AgoraContentInspectResult) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, contentInspectResult: result)
    }
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didRequest info: AgoraRtcAudioFileInfo, error: AgoraAudioFileInfoError) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRequest: info, error: error)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, wlAccStats currentStats: AgoraWlAccStats, averageStats: AgoraWlAccStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, wlAccStats: currentStats, averageStats: averageStats)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, wlAccMessage reason: AgoraWlAccReason, action: AgoraWlAccAction, wlAccMsg: String) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, wlAccMessage: reason, action: action, wlAccMsg: wlAccMsg)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioDeviceTestVolume volumeType: AgoraAudioDeviceTestVolumeType, volume: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, reportAudioDeviceTestVolume: volumeType, volume: volume)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didClientRoleChangeFailed reason: AgoraClientRoleChangeFailedReason, currentRole: AgoraClientRole) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didClientRoleChangeFailed: reason, currentRole: currentRole)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, snapshotTaken channel: String, uid: UInt, filePath: String, width: Int, height: Int, errCode: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, snapshotTaken: channel, uid: uid, filePath: filePath, width: width, height: height, errCode: errCode)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didProxyConnected channel: String, withUid uid: UInt, proxyType: AgoraProxyType, localProxyIp: String, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didProxyConnected: channel, withUid: uid, proxyType: proxyType, localProxyIp: localProxyIp, elapsed: elapsed)
    }
}
