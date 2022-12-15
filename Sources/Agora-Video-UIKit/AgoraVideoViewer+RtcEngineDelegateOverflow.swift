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
    open func rtcEngine(_ engine: AgoraRtcEngineKit, networkTypeChanged type: AgoraNetworkType) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, networkTypeChanged: type)
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
    open func rtcEngine(_ engine: AgoraRtcEngineKit, facePositionDidChangeWidth width: Int32, previewHeight height: Int32, faces: [AgoraFacePositionInfo]?) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, facePositionDidChangeWidth: width, previewHeight: height, faces: faces)
    }
    #elseif os(macOS)
    open func rtcEngine(_ engine: AgoraRtcEngineKit, device deviceId: String, type deviceType: AgoraMediaDeviceType, stateChanged state: Int) {
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
    open func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStats stats: AgoraRtcLocalVideoStats, sourceType: AgoraVideoSourceType) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, localVideoStats: stats, sourceType: sourceType)
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
    open func rtcEngineDidAudioEffectFinish(_ engine: AgoraRtcEngineKit, soundId: Int32) {
        self.agoraSettings.rtcDelegate?.rtcEngineDidAudioEffectFinish?(engine, soundId: soundId)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didReceive event: AgoraChannelMediaRelayEvent) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didReceive: event)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, streamUnpublishedWithUrl url: String) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, streamUnpublishedWithUrl: url)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFramePublishedWithElapsed elapsed: Int, sourceType: AgoraVideoSourceType) {
            self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstLocalVideoFramePublishedWithElapsed: elapsed, sourceType: sourceType)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, reportAudioVolumeIndicationOfSpeakers: speakers, totalVolume: totalVolume)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didLocalUserRegisteredWithUserId uid: UInt, userAccount: String) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didLocalUserRegisteredWithUserId: uid, userAccount: userAccount)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didUserInfoUpdatedWithUserId uid: UInt, userInfo: AgoraUserInfo) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didUserInfoUpdatedWithUserId: uid, userInfo: userInfo)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int, sourceType: AgoraVideoSourceType) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstLocalVideoFrameWith: size, elapsed: elapsed, sourceType: sourceType)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRemoteSubscribeFallbackToAudioOnly isFallbackOrRecover: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRemoteSubscribeFallbackToAudioOnly: isFallbackOrRecover, byUid: uid)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, audioMixingStateChanged state: AgoraAudioMixingStateType, reasonCode: AgoraAudioMixingReasonCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, audioMixingStateChanged: state, reasonCode: reasonCode)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, channelMediaRelayStateDidChange state: AgoraChannelMediaRelayState, error: AgoraChannelMediaRelayError) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, channelMediaRelayStateDidChange: state, error: error)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameOfUid uid: UInt, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, firstRemoteAudioFrameOfUid: uid, elapsed: elapsed)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioMuted muted: Bool, byUid uid: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioMuted: muted, byUid: uid)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, streamPublishedWithUrl url: String, errorCode: AgoraErrorCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, streamPublishedWithUrl: url, errorCode: errorCode)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, rtmpStreamingChangedToState url: String, state: AgoraRtmpStreamingState, errCode: AgoraRtmpStreamingErrorCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, rtmpStreamingChangedToState: url, state: state, errCode: errCode)
    }
//    open func rtcEngine(_ engine: AgoraRtcEngineKit, didApiCallExecute error: Int, api: String, result: String) {
//        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didApiCallExecute: error, api: api, result: result)
//    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, licenseValidationFailure error: AgoraLicenseVerifyCode) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, licenseValidationFailure: error)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, audioMixingPositionChanged position: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, audioMixingPositionChanged: position)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRejoinChannel: channel, withUid: uid, elapsed: elapsed)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, videoSizeChangedOf sourceType: AgoraVideoSourceType, uid: UInt, size: CGSize, rotation: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, videoSizeChangedOf: sourceType, uid: uid, size: size, rotation: rotation)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, networkQuality uid: UInt, txQuality: AgoraNetworkQuality, rxQuality: AgoraNetworkQuality) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, networkQuality: uid, txQuality: txQuality, rxQuality: rxQuality)
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
    open func rtcEngine(_ engine: AgoraRtcEngineKit, contentInspectResult result: AgoraContentInspectResult) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, contentInspectResult: result)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, remoteUserStateChangedOfUid uid: UInt, state: UInt) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, remoteUserStateChangedOfUid: uid, state: state)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, wlAccStats currentStats: AgoraWlAccStats, averageStats: AgoraWlAccStats) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, wlAccStats: currentStats, averageStats: averageStats)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, wlAccMessage reason: AgoraWlAccReason, action: AgoraWlAccAction, wlAccMsg: String) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, wlAccMessage: reason, action: action, wlAccMsg: wlAccMsg)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, rtmpStreamingEventWithUrl url: String, eventCode: AgoraRtmpStreamingEvent) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, rtmpStreamingEventWithUrl: url, eventCode: eventCode)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didClientRoleChangeFailed reason: AgoraClientRoleChangeFailedReason, currentRole: AgoraClientRole) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didClientRoleChangeFailed: reason, currentRole: currentRole)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didRhythmPlayerStateChanged state: AgoraRhythmPlayerState, errorCode: AgoraRhythmPlayerError) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didRhythmPlayerStateChanged: state, errorCode: errorCode)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, uploadLogResultRequestId requestId: String, success: Bool, reason: AgoraUploadErrorReason) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, uploadLogResultRequestId: requestId, success: success, reason: reason)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, snapshotTaken uid: UInt, filePath: String, width: Int, height: Int, errCode: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, snapshotTaken: uid, filePath: filePath, width: width, height: height, errCode: errCode)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didProxyConnected channel: String, withUid uid: UInt, proxyType: AgoraProxyType, localProxyIp: String, elapsed: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didProxyConnected: channel, withUid: uid, proxyType: proxyType, localProxyIp: localProxyIp, elapsed: elapsed)
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
    open func rtcEngineIntraRequestReceived(_ engine: AgoraRtcEngineKit) {
        self.agoraSettings.rtcDelegate?.rtcEngineIntraRequestReceived?(engine)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccur errorType: AgoraEncryptionErrorType) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didOccur: errorType)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, permissionError type: AgoraPermissionType) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, permissionError: type)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, uplinkNetworkInfoUpdate networkInfo: AgoraUplinkNetworkInfo) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, uplinkNetworkInfoUpdate: networkInfo)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, downlinkNetworkInfoUpdate networkInfo: AgoraDownlinkNetworkInfo) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, downlinkNetworkInfoUpdate: networkInfo)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioPublishStateChange channelId: String, oldState: AgoraStreamPublishState, newState: AgoraStreamPublishState, elapseSinceLastState: Int32) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioPublishStateChange: channelId, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoPublishStateChange channelId: String, sourceType: AgoraVideoSourceType, oldState: AgoraStreamPublishState, newState: AgoraStreamPublishState, elapseSinceLastState: Int32) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didVideoPublishStateChange: channelId, sourceType: sourceType, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioSubscribeStateChange channelId: String, uid: UInt32, oldState: AgoraStreamSubscribeState, newState: AgoraStreamSubscribeState, elapseSinceLastState: Int32) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didAudioSubscribeStateChange: channelId, uid: uid, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoSubscribeStateChange channelId: String, uid: UInt32, oldState: AgoraStreamSubscribeState, newState: AgoraStreamSubscribeState, elapseSinceLastState: Int32) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didVideoSubscribeStateChange: channelId, uid: uid, oldState: oldState, newState: newState, elapseSinceLastState: elapseSinceLastState)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, didOccurStreamMessageErrorFromUid: uid, streamId: streamId, error: error, missed: missed, cached: cached)
    }
    open func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
        self.agoraSettings.rtcDelegate?.rtcEngine?(engine, connectionChangedTo: state, reason: reason)
    }
    // MARK: - Deprecated
    open func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteAudioFrameDecodedOfUid uid: UInt, elapsed: Int) {}
}
