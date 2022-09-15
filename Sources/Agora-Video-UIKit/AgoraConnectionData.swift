//
//  AgoraConnectionData.swift
//  
//
//  Created by Max Cobb on 04/08/2021.
//

import Foundation
#if os(iOS)
import UIKit.UIDevice
#elseif os(macOS)
import IOKit
#endif

/// Storing struct for holding data about the connection to Agora service
public struct AgoraConnectionData {
    /// Agora App ID from https://agora.io
    public var appId: String
    /// Token to be used to connect to a channel, can be nil.
    public var rtcToken: String?

    /// Token to be used to connect to a RTM channel, can be nil.
    public var rtmToken: String?
    /// Channel the object is connected to. This cannot be set with the initialiser.
    public var channel: String?
    /// Agora Real-time Communication Identifier (Agora Video/Audio SDK).
    public var rtcId: UInt
    /// Agora Real-time Messaging Identifier (Agora RTM SDK).
    public var rtmId: String
    /// Username to be shared of the local user.
    public var username: String?

    /// Logic to be applied when determining RTM and RTC Ids
    public enum IDLogic {
        /// Generate a random UDID for RTM that not be stored between sessions, use 0 for RTC
        case random
        /// Encoded RTC based on a provided RTM ID. If not RTM ID is provided one will be generated.
        case encodedRtc(rtmId: String)
        /// Use builtin identifierForVendor, calculate rtc ID on ``AgoraConnectionData/uidFrom(vendor:charSet:)``
        case vendorIdEncodedRtc
        /// Provide a combination of rtm and/or rtc Ids to be applied. the same logic as `.random`
        /// will be applied for any nil values
        case staticValues(rtmId: String?, rtcId: UInt?)
    }
    /// Generate an Agora RTC ID based on a String
    /// - Parameters:
    ///   - vendor: Input string, which determines the output ID
    ///   - charSet: charSet to use for fetching numbers, leave this undeclared.
    /// - Returns: UInt to be used when connecting to Agora RTC.
    public static func uidFrom(vendor: String, charSet: String = "0123456789") -> UInt {
        let baseUID = UInt(vendor.filter(charSet.contains).suffix(9)) ?? 0
        if baseUID > 100 {
            // baseUID returned a number over 100
            return baseUID
        }
        if charSet.count == 10 {
            // Ignore zeros, to see if that returns a number over 100
            return uidFrom(vendor: vendor, charSet: String(charSet.suffix(9)))
        }

        // Use each char's (ascii value % 10), to generate a number
        // stop when over 10m
        var rtnNum: UInt = 0
        let dashAscii = Character("-").asciiValue!
        for char in vendor {
            if char.isASCII, let asciiVal = char.asciiValue, asciiVal != dashAscii {
                rtnNum = rtnNum * 10 + UInt(asciiVal % 10)
            }
            if rtnNum > 10_000_000 { break }
        }
        return rtnNum
    }

    #if os(macOS)
    public static func fetchSerialMd5() -> String {
        // Get the platform expert
        let platformExpert: io_service_t = IOServiceGetMatchingService(
            kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")
        )

        // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(
            platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0
        )

        // Release the platform expert (we're responsible)
        IOObjectRelease(platformExpert)

        // Take the unretained value of the unmanaged-any-object
        // (so we're not responsible for releasing it)
        // and pass it back as a String or, if it fails, an empty string
        let vendorId = (serialNumberAsCFString?.takeUnretainedValue() as? String)!

        return MD5(vendorId)
    }
    #endif

    /// Create a new AgoraConnectionData object
    /// - Parameters:
    ///   - appId: Agora App ID from https://agora.io
    ///   - rtcToken: Token to be used to connect to a video channel, can be nil.
    ///   - rtmToken: Token to be used to connect to an RTM channel, can be nil.
    ///   - idLogic: Logic to be applied when determining RTM and RTC Ids
    public init(
        appId: String, rtcToken: String? = nil, rtmToken: String? = nil,
        idLogic: IDLogic = .vendorIdEncodedRtc
    ) {
        self.appId = appId
        self.rtcToken = rtcToken
        self.rtmToken = rtmToken
        switch idLogic {
        case .random:
            self.rtmId = UUID().uuidString
            self.rtcId = 0
        case .vendorIdEncodedRtc:
            #if os(iOS)
            guard let vendorId = UIDevice.current.identifierForVendor?.uuidString else {
                fatalError("Could not generate vendor Id")
            }
            #elseif os(macOS)
            let vendorId = AgoraConnectionData.fetchSerialMd5()
            #endif
            self.rtcId = AgoraConnectionData.uidFrom(vendor: vendorId)
            self.rtmId = vendorId
        case .encodedRtc(let rtmId):
            self.rtmId = rtmId
            self.rtcId = AgoraConnectionData.uidFrom(vendor: self.rtmId)
        case .staticValues(let rtmId, let rtcId):
            self.rtmId = rtmId ?? UUID().uuidString
            self.rtcId = rtcId ?? 0
        }
    }
}
