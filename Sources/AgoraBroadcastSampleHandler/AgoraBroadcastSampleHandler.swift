//
//  AgoraBroadcastSampleHandler.swift
//  screenSharer
//
//  Created by Max Cobb on 21/10/2022.
//

import ReplayKit
import AgoraAppGroupDataHelper

/// Use this class to broadcast your apps easily.
open class AgoraBroadcastSampleHandler: RPBroadcastSampleHandler {
    open func getAppGroup() -> String? { return nil }

    var bufferCopy: CMSampleBuffer?
    var lastSendTs: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    var timer: Timer?

    override open func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {

        guard let appGroup = self.getAppGroup() else {
            fatalError("Please override getAppGroup method and return a String")
        }
        AgoraAppGroupDataHelper.appGroup = appGroup
        if let appId = AgoraAppGroupDataHelper.getString(for: .appId), let channel = AgoraAppGroupDataHelper.getString(for: .channel) {

            AgoraSharingEngineHelper.initialize(appId: appId)

            let uid = UInt(AgoraAppGroupDataHelper.getString(for: .uid) ?? "0") ?? 0
            AgoraSharingEngineHelper.startScreenSharing(
                to: channel, with: AgoraAppGroupDataHelper.getString(for: .token),
                uid: uid
            )
        } else {
            // You have to use App Group to pass information/parameter
            // from main app to extension
            fatalError("No Agora AppID Provided")
        }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {[weak self] (timer: Timer) in
                guard let weakSelf = self else {return}
                let elapse = Int64(Date().timeIntervalSince1970 * 1000) - weakSelf.lastSendTs
                print("elapse: \(elapse)")
                // if frame stopped sending for too long time, resend the last frame
                // to avoid stream being frozen when viewed from remote
                if elapse > 300 {
                    if let buffer = weakSelf.bufferCopy {
                        weakSelf.processSampleBuffer(buffer, with: .video)
                    }
                }
            }
        }
    }


     override open func broadcastPaused() {
         // User has requested to pause the broadcast. Samples will stop being delivered.
     }

     override open func broadcastResumed() {
         // User has requested to resume the broadcast. Samples delivery will resume.
     }

     override open func broadcastFinished() {
         timer?.invalidate()
         timer = nil
         AgoraSharingEngineHelper.stopScreenSharing()
     }

     override open func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
         DispatchQueue.main.async {[weak self] in
             switch sampleBufferType {
             case .video:
                 if let weakSelf = self {
                     weakSelf.bufferCopy = sampleBuffer
                     weakSelf.lastSendTs = Int64(Date().timeIntervalSince1970 * 1000)
                 }
                 AgoraSharingEngineHelper.sendVideoBuffer(sampleBuffer)
             case .audioApp:
                 AgoraSharingEngineHelper.sendAudioAppBuffer(sampleBuffer)
                 break
             case .audioMic:
                 AgoraSharingEngineHelper.sendAudioMicBuffer(sampleBuffer)
                 break
             @unknown default:
                 break
             }
         }
     }

}
