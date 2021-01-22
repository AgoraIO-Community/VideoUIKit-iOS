//
//  MPButton+Extensions.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit

/// Settings used for the display and behaviour of AgoraVideoViewer
public struct AgoraSettings {
    /// URL to fetch tokens from. If supplied, this package will automatically fetch tokens
    /// when the Agora Engine indicates it will be needed.
    /// It will follow the URL pattern found in
    /// [AgoraIO-Community/agora-token-service](https://github.com/AgoraIO-Community/agora-token-service)
    public var tokenURL: String?
    /// OptionSet for selecting which buttons are visible in the AgoraVideoViewer
    public struct BuiltinButtons: OptionSet {
        public var rawValue: Int
        /// Option for displaying a button to toggle the camera on or off.
        public static let cameraButton = BuiltinButtons(rawValue: 1 << 0)
        /// Option for displaying a button to toggle the microphone on or off.
        public static let micButton = BuiltinButtons(rawValue: 1 << 1)
        /// Option for displaying a button to flip the camera between front and rear facing.
        public static let flipButton = BuiltinButtons(rawValue: 1 << 2)
        /// Option for displaying a button to toggle beautify feature on or off
        public static let beautifyButton = BuiltinButtons(rawValue: 1 << 3)
        /// Option for displaying screenshare button
        public static let screenShareButton = BuiltinButtons(rawValue: 1 << 4)
        /// Option to display all default buttons
        public static let all: BuiltinButtons = [cameraButton, micButton, flipButton, beautifyButton, screenShareButton]
        /// Initialiser for creating an option set
        /// - Parameter rawValue: Raw value to be applied, used for choosing the button options
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    /// Position, top, left, bottom or right.
    public enum Position {
        /// At the top of the view
        case top
        /// At the right of the view
        case right
        /// At the bottom of the view
        case bottom
        /// At the left of the view
        case left
    }
    /// The rendering mode of the video view for all videos within the view.
    public var videoRenderMode: AgoraVideoRenderMode = .fit
    /// Which buttons should be enabled in this AgoraVideoView.
    /// For example: `[.cameraButton, .micButton]`
    public var enabledButtons: BuiltinButtons = .all
    /// Where the buttons such as camera enable/disable should be positioned within the view.
    public var buttonPosition: Position = .bottom
    /// Where the floating collection view of video members be positioned within the view.
    public var floatPosition: Position = .top
    /// Agora's video encoder configuration.
    public var videoConfiguration: AgoraVideoEncoderConfiguration = AgoraVideoEncoderConfiguration()
    /// Colors for views inside AgoraVideoViewer
    public var colors: AgoraViewerColors = AgoraViewerColors()

    /// Full string for low bitrate stream parameter, including key of `che.video.lowBitRateStreamParameter`.
    /// Set this property before initialising AgoraVideoViewer.
    public var lowBitRateStream: String? = AgoraSettings.defaultLowBitrateParam

    /// Whether we are using dual stream mode, which helps to reduce Agora costs.
    public var usingDualStream: Bool {
        get { self.lowBitRateStream != nil }
        set {
            if newValue && self.lowBitRateStream != nil {
                return
            }
            self.lowBitRateStream = newValue ? AgoraSettings.defaultLowBitrateParam : nil
        }
    }

    /// Maximum number of videos in the grid view before the low bitrate is adopted.
    public var gridThresholdHighBitrate: Int = 4

    /// Create a new AgoraSettings object
    public init() {}

    static private let defaultLowBitrateParam = """
      { "che.video.lowBitRateStreamParameter": {
        "width":160,"height":120,"frameRate":5,"bitRate":45
      }}
    """
}

/// Colors for views inside AgoraVideoViewer
public struct AgoraViewerColors {
    /// Color of the view that signals a user has their mic muted. Default `.systemBlue`
    public var micFlag: MPColor = .systemBlue
}
