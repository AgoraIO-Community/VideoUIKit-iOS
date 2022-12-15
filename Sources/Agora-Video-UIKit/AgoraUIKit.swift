//
//  AgoraUIKit.swift
//  
//
//  Created by Max Cobb on 30/07/2021.
//

import Foundation
import AgoraRtcKit

/// Agora UIKit data structure. Access ``AgoraUIKit/AgoraUIKit/current`` for information
/// about your Video UI Kit version.
public struct AgoraUIKit: Codable {
    /// Instance of the current AgoraUIKit instance.
    public static var current: AgoraUIKit {
        AgoraUIKit(version: AgoraUIKit.version, platform: AgoraUIKit.platform, framework: AgoraUIKit.framework)
    }
    /// Platform that is being used: ios, macos, android, unknown
    public fileprivate(set) var platform: String
    /// Version of UIKit being used
    public fileprivate(set) var version: String
    /// Framework type of UIKit. "native", "flutter", "reactnative"
    public fileprivate(set) var framework: String
    /// Version of UIKit being used
    public static let version = "4.0.5"
    /// Framework type of UIKit. "native", "flutter", "reactnative"
    public static let framework = "native"
    #if os(iOS)
    /// Platform that is being used: ios, macos, android, unknown
    public static let platform = "ios"
    #elseif os(macOS)
    /// Platform that is being used: ios, macos, android, unknown
    public static let platform = "macos"
    #else
    /// Platform that is being used: ios, macos, android, unknown
    public static let platform = "unknown"
    #endif
    fileprivate init(version: String, platform: String, framework: String) {
        self.version = version
        self.platform = platform
        self.framework = framework
    }
    /// Get the Video UI Kit details in a pretty printed string format. Used for print statements.
    /// - Returns: String of the version, platform and framework.
    func prettyPrint() -> String {
        """
            version: \(version)
            platform: \(platform)
            framework: \(framework)
        """
    }
    /// Initialiser from a decoder. Used for internal purposes only
    /// - Parameter decoder: Decoder object that is used to set all the properties.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.platform = try container.decode(String.self, forKey: .platform)
        self.version = try container.decode(String.self, forKey: .version)
        self.framework = try container.decode(String.self, forKey: .framework)
    }
    /// Converts an unsigned UInt32 to a regular signed Int. This is to handle User Id's across multiple platforms.
    /// - Parameter uint: Unigned integer userId
    /// - Returns: Signed integer userId
    public static func uintToInt(_ uint: UInt) -> Int {
        Int(Int32(bitPattern: UInt32(uint)))
    }
    /// Converts a regular Int to an unsigned UInt32. This is to handle User Id's across multiple platforms.
    /// - Parameter userInt: Signed integer userId
    /// - Returns: Unsigned integer userId
    public static func intToUInt(_ userInt: Int) -> UInt {
        UInt(UInt32(bitPattern: Int32(userInt)))
    }
}
