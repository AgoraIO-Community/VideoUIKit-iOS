//
//  AgoraUIKit.swift
//  
//
//  Created by Max Cobb on 30/07/2021.
//

import Foundation
import AgoraRtcKit

/// Agora UIKit data structure. Access `AgoraUIKit.current` for information
/// about your UIKit version.
public struct AgoraUIKit: Codable {
    /// Instance of the current AgoraUIKit instance.
    public static var current: AgoraUIKit {
        AgoraUIKit(version: AgoraUIKit.version, platform: AgoraUIKit.platform, framework: AgoraUIKit.framework)
    }
    /// Platform that is being used: ios, macos, android, unknown
    fileprivate(set) var platform: String
    /// Version of UIKit being used
    fileprivate(set) var version: String
    /// Framework type of UIKit. "native", "flutter", "reactnative"
    fileprivate(set) var framework: String
    /// Version of UIKit being used
    static let version = "1.8.4"
    /// Framework type of UIKit. "native", "flutter", "reactnative"
    static let framework = "native"
    #if os(iOS)
    /// Platform that is being used: ios, macos, android, unknown
    static let platform = "ios"
    #elseif os(macOS)
    /// Platform that is being used: ios, macos, android, unknown
    static let platform = "macos"
    #else
    /// Platform that is being used: ios, macos, android, unknown
    static let platform = "unknown"
    #endif
    fileprivate init(version: String, platform: String, framework: String) {
        self.version = version
        self.platform = platform
        self.framework = framework
    }
    func prettyPrint() -> String {
        """
            version: \(version)
            platform: \(platform)
            framework: \(framework)
        """
    }
    public static func uintToInt(_ uint: UInt) -> Int {
        Int(Int32(bitPattern: UInt32(uint)))
    }
    public static func intToUInt(_ userInt: Int) -> UInt {
        UInt(UInt32(bitPattern: Int32(userInt)))
    }
}
