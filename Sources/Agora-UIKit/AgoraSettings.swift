//
//  MPButton+Extensions.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import AgoraRtcKit
import AgoraRtmKit

/// Settings used for the display and behaviour of AgoraVideoViewer
public struct AgoraSettings {

    /// Delegate for Agora Rtc Engine callbacks
    public weak var rtcDelegate: AgoraRtcEngineDelegate?

    /// Delegate for Agora RTM callbacks
    public weak var rtmDelegate: AgoraRtmDelegate?

    /// Delegate for Agora RTM Channel callbacks
    public weak var rtmChannelDelegate: AgoraRtmChannelDelegate?

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

    /// Settings for applying external videos
    public struct ExternalVideoSettings {
        /// Create instance with all properties set to `true`
        public static let allTrue: ExternalVideoSettings = {
            ExternalVideoSettings(enabled: true, texture: true, encoded: true)
        }()
        /// Create instance with all properties set to `false`
        public static let allFalse: ExternalVideoSettings = {
            ExternalVideoSettings(enabled: false, texture: false, encoded: false)
        }()
        /// Determines whether to enable the external video source.
        /// - `true`: Use external video source.
        /// - `false`: Do not use external video source.
        public let enabled: Bool
        /// Determines whether to use textured video data.
        /// - `true`: Use the texture as an input.
        /// - `false`: Do not use the texture as an input.
        public let texture: Bool
        /// Determines whether the external video source is encoded.
        /// - `true`: The external video source is encoded.
        /// - `false`: The external video source is not encoded.
        public let encoded: Bool

        /// Create a settings object for applying external videos
        /// - Parameters:
        ///   - enabled: Determines whether to enable the external video source.
        ///   - texture: Determines whether to use textured video data.
        ///   - encoded: Determines whether the external video source is encoded.
        public init(enabled: Bool, texture: Bool, encoded: Bool) {
            self.enabled = enabled
            self.texture = texture
            self.encoded = encoded
        }
    }

    /// External video source settings parameters
    public var externalVideoSettings: ExternalVideoSettings = .allFalse

    @available(*, deprecated, renamed: "externalVideoSettings")
    public var externalVideoSource: ExternalVideoSettings {
        get { self.externalVideoSettings }
        set { self.externalVideoSettings = newValue }
    }

    /// Whether to show your own camera feed
    public var showSelf: Bool = true

    /// Settings for applying external videos
    public struct ExternalAudioSettings {
        /// Determines whether to enable the external audio source:
        /// - `true`: Enable the external audio source.
        /// - `false`: (default) Disable the external audio source.
        public let enabled: Bool

        /// The Sample rate (Hz) of the external audio source, which can set be as 8000, 16000, 32000, 44100, or 48000.
        public let sampleRate: Int

        /// The number of channels of the external audio source, which can be set as 1 or 2:
        /// - 1: Mono.
        /// - 2: Stereo.
        public let channels: Int

        /// Create a settings object for applying external videos
        /// - Parameters:
        ///   - enabled: Determines whether to enable the external audio source.
        ///   - sampleRate: The Sample rate (Hz) of the external audio source.
        ///   - channels: The number of channels of the external audio source.
        public init(enabled: Bool, sampleRate: Int, channels: Int) {
            self.enabled = enabled
            self.sampleRate = sampleRate
            self.channels = channels
        }
    }

    /// External audio source settings parameters
    public var externalAudioSettings: ExternalAudioSettings = .init(
        enabled: false, sampleRate: 8000, channels: 2
    )

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
    #elseif os(macOS)
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
