//
//  MPButton+Extensions.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit

public struct AgoraSettings {
    public var tokenURL: String?
    public struct BuiltinButtons: OptionSet {
        public var rawValue: Int
        public static let cameraButton = BuiltinButtons(rawValue: 1 << 0)
        public static let micButton = BuiltinButtons(rawValue: 1 << 1)
        public static let flipButton = BuiltinButtons(rawValue: 1 << 2)
        public static let beautifyButton = BuiltinButtons(rawValue: 1 << 3)
        public static let all: BuiltinButtons = [cameraButton, micButton, flipButton, beautifyButton]
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    public enum Position {
        case top
        case right
        case bottom
        case left
    }
    public var videoRenderMode: AgoraVideoRenderMode = .fit
    public var enabledButtons: BuiltinButtons = .all
    public var buttonPosition: Position = .bottom
    public var floatPosition: Position = .top
    public var videoConfiguration: AgoraVideoEncoderConfiguration = AgoraVideoEncoderConfiguration()
    public init() {}
}
