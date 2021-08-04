//
//  AgoraUIKit.swift
//  
//
//  Created by Max Cobb on 30/07/2021.
//

import Foundation

public struct AgoraUIKit: Codable {
    public static var current: AgoraUIKit {
        AgoraUIKit(version: AgoraUIKit.version, platform: AgoraUIKit.platform, framework: AgoraUIKit.framework)
    }
    fileprivate(set) var platform: String
    fileprivate(set) var version: String
    fileprivate(set) var framework: String
    static let version = "1.5.0"
    static let framework = "native" // otherwise flutter, react native
    #if os(iOS)
    static let platform = "ios"
    #elseif os(macOS)
    static let platform = "macos"
    #else
    static let platform = "unknown"
    #endif
    fileprivate init(version: String, platform: String, framework: String) {
        self.version = version
        self.platform = platform
        self.framework = framework
    }
}
