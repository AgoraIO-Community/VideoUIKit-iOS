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

    public var videoSource: AgoraVideoSourceProtocol? = nil
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

    /// If the camera is enabled. Set this before joining a channel to not require camera permissions
    /// and camera to not be activated at all.
    public var cameraEnabled: Bool = true

    /// Show the icon for remote user video feeds to request mute/unmute of devices
    public var showRemoteRequestOptions: Bool = true

    /// If the microphone is enabled. Set this before joining a channel to not require microphone permissions
    /// and mic to not be activated at all.
    public var micEnabled: Bool = true

    /// Maximum number of videos in the grid view before the low bitrate is adopted.
    public var gridThresholdHighBitrate: Int = 4

    /// Create a new AgoraSettings object
    public init() {}

    static private let defaultLowBitrateParam = """
      { "che.video.lowBitRateStreamParameter": {
        "width":160,"height":120,"frameRate":5,"bitRate":45
      }}
    """

    /// Size of buttons that will appear in the builtin button tray
    var buttonSize: CGFloat = 60
    /// Margin around each button in the builtin button tray
    var buttonMargin: CGFloat = 5
    #if os(iOS)
    /// Scale of the icons within the buttons in the builtin button tray
    static var buttonIconScale: UIImage.SymbolScale = .large
    #else
    /// Font size of the builtin buttons SF Symbol text
    static var buttonIconSize: CGFloat = 20
    #endif
}

/// Colors for views inside AgoraVideoViewer
public struct AgoraViewerColors {
    /// Color of the view that signals a user has their mic muted. Default `.systemBlue`
    public var micFlag: MPColor = .systemBlue
    /// Color of the mute mic button when in unselected state (not muted)
    public var micButtonNormal: MPColor = .systemGreen
    /// Color of the mute cam button when in unselected state (camera on)
    public var camButtonNormal: MPColor = .systemGreen
    /// Color of the mute mic button when in selected state (muted)
    public var micButtonSelected: MPColor = .systemRed
    /// Color of the mute cam button when in selected state (camera off)
    public var camButtonSelected: MPColor = .systemRed
    /// Color of the bar button when in unselected state
    public var buttonDefaultNormal: MPColor = .systemGray
    /// Color of the bar button when in selected state
    public var buttonDefaultSelected: MPColor = .systemRed
    /// Tint color of all buttons that appear in the bottom bar
    public var buttonTintColor: MPColor = .systemBlue
}
