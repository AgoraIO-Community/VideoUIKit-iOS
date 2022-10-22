//
//  AgoraBroadcastError.swift
//  AgoraBroadcastExtensionHelper
//
//  Created by Max Cobb on 20/10/2022.
//

import Foundation
import CoreMedia
import ReplayKit
import AgoraRtcKit

/// Error that will occur when the extension fails to broadcast the screen.
public enum AgoraBroadcastError: Error {
    /// Neither ``AgoraBroadcastSampleHandler/getAppGroup()``
    /// or ``AgoraBroadcastSampleHandler/getBroadcastData()``
    /// are returning valid data to start a video session.
    case noBroadcastData
    /// ``AgoraBroadcastSampleHandler/getAppGroup()`` is set,
    /// but not to a valid string for this use.
    case invalidAppGroup
    /// ``AgoraBroadcastSampleHandler/getAppGroup()`` is set and working,
    /// but missing appId or channel name.
    case badAppGroupData
    /// Channel join failed for another reason, check the associated value for more.
    case joinChannelFailed(reason: String)
    /// Useful method for printing out the error
    public func printError() {
        switch self {
        case .noBroadcastData:
            AgoraBroadcastSampleHandler.agoraPrint(.error, "Error thrown: Not enough broadcast data")
        case .invalidAppGroup:
            AgoraBroadcastSampleHandler.agoraPrint(.error, "Error thrown: invalid app group")
        case .badAppGroupData:
            AgoraBroadcastSampleHandler.agoraPrint(.error, "Error thrown: bad app group data")
        case .joinChannelFailed(let reason):
            AgoraBroadcastSampleHandler.agoraPrint(.error, "Error thrown: \(reason)")
        }

    }
}
