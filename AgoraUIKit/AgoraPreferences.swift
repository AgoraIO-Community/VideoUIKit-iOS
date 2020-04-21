//
//  AgoraPreferences.swift
//  AgoraUIKit
//
//  Created by Jonathan  Fotland on 4/13/20.
//  Copyright © 2020 Jonathan Fotland. All rights reserved.
//

import Foundation
import AgoraRtcKit

/**
 Global Agora preferences.
 */
public class AgoraPreferences {
    /**
     Static preferences singleton. Used to get and set preferences for Agora.
     */
    public static let shared = AgoraPreferences()
    
    private init() {}
    
    /**
     Your Agora app ID. Can be acquired from console.agora.io.
     */
    public var appID: String = ""
    /**
     Your authentication token. Can be nil for projects created without token authorization.
     */
    public var token: String?
    
    private var agoraKit: AgoraRtcEngineKit? = nil
    
    /**
     Returns a handle to the AgoraRtcEngineKit.
     */
    public func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appID, delegate: nil)
        }
        
        return agoraKit!
    }
    
    /// Sets the video configuration.
    /// - Parameters:
    ///   - size: The video frame dimension (px) used to specify the video quality in the total number of pixels along a frame’s width and height. The default value is 640 x 360.
    ///   - frameRate: The frame rate of the video (fps). The default value is 15.
    ///   - bitrate: The bitrate of the video.
    ///   - orientationMode: The video orientation mode of the video.
    ///   - degradationPreference: The video encoding degradation preference under limited bandwidth.
    public func setVideoConfiguration(size: CGSize? = nil, frameRate: AgoraVideoFrameRate? = nil, bitrate: Int? = nil, orientationMode: AgoraVideoOutputOrientationMode? = nil, degradationPreference: AgoraDegradationPreference? = nil) {
        
        let config = AgoraVideoEncoderConfiguration()
        
        if let size = size {
            config.dimensions = size
        }
        if let frameRate = frameRate?.rawValue {
            config.frameRate = frameRate
        }
        if let bitrate = bitrate {
            config.bitrate = bitrate
        }
        if let orientation = orientationMode {
            config.orientationMode = orientation
        }
        if let degradation = degradationPreference {
            config.degradationPreference = degradation
        }

        setVideoConfiguration(config: config)
    }
    
    /// Sets the video configuration.
    /// - Parameter config: A configuration object describing the desired configuration settings.
    public func setVideoConfiguration(config: AgoraVideoEncoderConfiguration) {
        getAgoraEngine().setVideoEncoderConfiguration(config)
    }
}
