//
//  AgoraVideoViewer.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import AgoraRtcKit

/// Storing struct for holding data about the connection to Agora service
public struct AgoraConnectionData {
    /// Agora App ID from https://agora.io
    var appId: String
    /// Token to be used to connect to a channel, can be nil.
    var appToken: String?
    /// Channel the object is connected to. This cannot be set with the initialiser
    var channel: String?
    /// Create AgoraConnectionData object
    /// - Parameters:
    ///   - appId: Agora App ID from https://agora.io
    ///   - appToken: Token to be used to connect to a channel, can be nil.
    public init(appId: String, appToken: String? = nil) {
        self.appId = appId
        self.appToken = appToken
    }
}

/// An interface for getting some common delegate callbacks without needing to subclass.
public protocol AgoraVideoViewerDelegate: AnyObject {
    /// Local user has joined the channel of a given name
    /// - Parameter channel: Name of the channel local user has joined.
    func joinedChannel(channel: String)
    /// Local user has left the active channel.
    /// - Parameter channel: Name of the channel local user has left.
    func leftChannel(_ channel: String)
    /// The token used to connect to the current active channel will expire in 30 seconds.
    /// - Parameters:
    ///   - engine: Agora RTC Engine
    ///   - token: Current token that will expire.
    func tokenWillExpire(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String)
    /// The token used to connect to the current active channel has expired.
    /// - Parameter engine: Agora RTC Engine
    func tokenDidExpire(_ engine: AgoraRtcEngineKit)
    #if os(iOS)
    /// presentAlert is a way to show any alerts that the AgoraVideoViewer wants to display.
    /// These could be relating to video or audio permissions.
    /// - Parameters:
    ///   - alert: Alert to be displayed
    ///   - animated: Whether the presentation should be animated or not
    func presentAlert(alert: UIAlertController, animated: Bool)
    /// An array of any additional buttons to be displayed alongside camera, and microphone buttons
    func extraButtons() -> [UIButton]
    #else
    /// An array of any additional buttons to be displayed alongside camera, and microphone buttons
    func extraButtons() -> [NSButton]
    #endif
}

public extension AgoraVideoViewerDelegate {
    func joinedChannel(channel: String) {}
    func leftChannel(_ channel: String) {}
    func tokenWillExpire(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {}
    func tokenDidExpire(_ engine: AgoraRtcEngineKit) {}
    #if os(iOS)
    func presentAlert(alert: UIAlertController, animated: Bool) {
        if let viewCont = self as? UIViewController {
            viewCont.present(alert, animated: animated)
        }
    }
    func extraButtons() -> [UIButton] { [] }
    #else
    func extraButtons() -> [NSButton] { [] }
    #endif
}

/// View to contain all the video session objects, including camera feeds and buttons for settings
open class AgoraVideoViewer: MPView, StreamMessageContainer {

    /// Delegate for the AgoraVideoViewer, used for some important callback methods.
    public weak var delegate: AgoraVideoViewerDelegate?

    /// Settings and customisations such as position of on-screen buttons, collection view of all channel members,
    /// as well as agora video configuration.
    public internal(set) var agoraSettings: AgoraSettings

    /// Stream Controller class for managing stream messages
    public var streamController: StreamMessageController?

    /// The rendering mode of the video view for all active videos.
    var videoRenderMode: AgoraVideoRenderMode {
        get { self.agoraSettings.videoRenderMode }
        set {
            self.agoraSettings.videoRenderMode = newValue
            self.userVideoLookup.values.forEach { $0.canvas.renderMode = newValue }
        }
    }
    /// Style and organisation to be applied to all the videos in this view.
    public enum Style: Equatable {
        /// grid lays out all the videos in an NxN grid, regardless of how many there are.
        case grid
        /// floating keeps track of the active speaker, displays them larger and the others in a collection view.
        case floating
        /// collection only shows the collectionview, no other UI is visible, except video controls
        case collection
        /// Method for constructing a custom layout.
        case custom(customFunction: (AgoraVideoViewer, EnumeratedSequence<[UInt: AgoraSingleVideoView]>, Int) -> Void)

        public static func == (lhs: AgoraVideoViewer.Style, rhs: AgoraVideoViewer.Style) -> Bool {
            switch (lhs, rhs) {
            case (.grid, .grid), (.floating, .floating): return true
            default: return false
            }
        }
    }

    /// The most recently active speaker in the session. This will only ever be set to remote users, not the local user.
    public internal(set) var activeSpeaker: UInt? {
        didSet { self.reorganiseVideos() }
    }

    /// This user will be the main focus when using `.floating` style.
    /// Assigned by clicking a user in the collection view.
    /// Can be set to local user.
    public var overrideActiveSpeaker: UInt? {
        didSet {
            if oldValue != overrideActiveSpeaker { self.reorganiseVideos() }
        }
    }

    /// Setting to zero will tell Agora to assign one for you once connected.
    public internal(set) lazy var userID: UInt = 0
    internal var connectionData: AgoraConnectionData!

    /// Gets and sets the role for the user. Either `.audience` or `.broadcaster`.
    public var userRole: AgoraClientRole = .audience {
        didSet { self.agkit.setClientRole(self.userRole) }
    }

    internal var currentToken: String? {
        get { self.connectionData.appToken }
        set { self.connectionData.appToken = newValue }
    }

    lazy internal var floatingVideoHolder: MPCollectionView = {
        let collView = AgoraCollectionViewer()
        self.addSubview(collView)
        collView.delegate = self
        collView.dataSource = self

        let floatPos = self.agoraSettings.floatPosition
        let smallerDim = 100 + 2 * AgoraCollectionViewer.cellSpacing
        switch floatPos {
        case .top, .bottom:
            (collView.collectionViewLayout as? MPCollectionViewFlowLayout)?.scrollDirection = .horizontal
            collView.frame.size = CGSize(width: self.bounds.width, height: smallerDim)
            if floatPos == .top {
                #if os(iOS)
                collView.frame.origin = .zero
                collView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
                #else
                collView.frame.origin = CGPoint(x: 0, y: self.bounds.height - smallerDim)
                collView.autoresizingMask = [.width, .minYMargin]
                #endif
            } else {
                #if os(iOS)
                collView.frame.origin = CGPoint(x: 0, y: self.bounds.height - smallerDim)
                collView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
                #else
                collView.frame.origin = .zero
                collView.autoresizingMask = [.width, .maxYMargin]
                #endif
            }
        case .right, .left:
            (collView.collectionViewLayout as? MPCollectionViewFlowLayout)?.scrollDirection = .vertical
            collView.frame.size = CGSize(width: smallerDim, height: self.bounds.height)
            if floatPos == .left {
                collView.frame.origin = .zero
                #if os(iOS)
                collView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                #else
                collView.autoresizingMask = [.height, .maxXMargin]
                #endif
            } else {
                collView.frame.origin = CGPoint(x: self.bounds.width - smallerDim, y: 0)
                #if os(iOS)
                collView.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
                #else
                collView.autoresizingMask = [.height, .minXMargin]
                #endif
            }
        }
        #if os(iOS)
        self.bringSubviewToFront(collView)
        #else
        self.addSubview(collView, positioned: .above, relativeTo: nil)
        #endif
        return collView
    }()

    /// View that holds all of the videos displayed in grid formation
    public internal(set) lazy var backgroundVideoHolder: MPView = {
        let rtnView = MPView()
        #if os(iOS)
        self.addSubview(rtnView)
        self.sendSubviewToBack(rtnView)
        #else
        self.addSubview(rtnView, positioned: .below, relativeTo: nil)
        rtnView.wantsLayer = true
        rtnView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        #endif
        rtnView.frame = self.bounds
        #if os(iOS)
        rtnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #else
        rtnView.autoresizingMask = [.width, .height]
        #endif
        // Had issues with `self.style == .collection`, so changed to switch case
        switch self.style {
        case .collection:
            rtnView.isHidden = true
        default:
            rtnView.isHidden = false
        }
        return rtnView
    }()

    /// AgoraRtcEngineKit being used by this AgoraVideoViewer.
    lazy public internal(set) var agkit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(
            withAppId: connectionData.appId, delegate: self
        )
        engine.enableAudioVolumeIndication(1000, smooth: 3, report_vad: true)
        engine.setChannelProfile(.liveBroadcasting)
        if self.agoraSettings.usingDualStream {
            engine.enableDualStreamMode(true)
            if let bitrateStream = self.agoraSettings.lowBitRateStream {
                engine.setParameters(bitrateStream)
            }
        }
        engine.setClientRole(self.userRole)
        return engine
    }()

    /// Style and organisation to be applied to all the videos in this AgoraVideoViewer.
    public var style: AgoraVideoViewer.Style = .floating {
        didSet {
            if oldValue != self.style {
                switch self.style {
                case .collection: self.backgroundVideoHolder.isHidden = true
                default: self.backgroundVideoHolder.isHidden = false
                }
                self.reorganiseVideos()
            }
        }
    }

    /// Creates an AgoraVideoViewer object, to be placed anywhere in your application.
    /// - Parameters:
    ///   - connectionData: Storing struct for holding data about the connection to Agora service.
    ///   - style: Style and organisation to be applied to all the videos in this AgoraVideoViewer.
    ///   - agoraSettings: Settings for this viewer. This can include style customisations and information of where to get new tokens from.
    ///   - delegate: Delegate for the AgoraVideoViewer, used for some important callback methods.
    public init(
        connectionData: AgoraConnectionData, style: AgoraVideoViewer.Style = .grid,
        agoraSettings: AgoraSettings = AgoraSettings(), delegate: AgoraVideoViewerDelegate? = nil
    ) {
        self.agoraSettings = agoraSettings
        self.connectionData = connectionData
        self.style = style
        self.delegate = delegate
        super.init(frame: .zero)
    }

    // MARK: Storyboard Settings

    /// Used by storyboard to set the AgoraVideoViewer appID.
    @IBInspectable var appID: String = "" {
        didSet {
            if self.connectionData == nil {
                self.connectionData = AgoraConnectionData(appId: appID)
            }
        }
    }
    /// Used by storyboard to set the AgoraVideoViewer style. Valid values are "floating", "grid", "collection"
    @IBInspectable var styleString: String = "" {
        didSet {
            switch self.styleString {
            case "floating":
                self.style = .floating
            case "grid":
                self.style = .grid
            case "collection":
                self.style = .collection
            default:
                fatalError("Invalid style \(self.styleString)")
            }
        }
    }

    /// Used by storyboard to set the AgoraSettings tokenURL
    @IBInspectable var tokenURL: String = "" {
        didSet {
            self.agoraSettings.tokenURL = tokenURL
        }
    }
    /// Create view from NSCoder, this initialiser requires an appID key with a String value.
    /// - Parameter coder: NSCoder to build the view from
    public required init?(coder: NSCoder) {
        self.agoraSettings = AgoraSettings()
        super.init(coder: coder)
    }

    internal var userVideoLookup: [UInt: AgoraSingleVideoView] = [:] {
        didSet { reorganiseVideos() }
    }

    internal var userVideosForGrid: [UInt: AgoraSingleVideoView] {
        if self.style == .floating {
            return self.userVideoLookup.filter {
                $0.key == (self.overrideActiveSpeaker ?? self.activeSpeaker ?? self.userID)
            }
        } else if self.style == .grid {
            return self.userVideoLookup
        } else {
            return [:]
        }
    }

    /// Container for the buttons (such as mute, flip camera etc.)
    public var controlContainer: MPBlurView?
    var camButton: MPButton?
    var micButton: MPButton?
    var flipButton: MPButton?
    var beautyButton: MPButton?
    var screenShareButton: MPButton?

    /// Default beautification settings
    open var beautyOptions: AgoraBeautyOptions = {
        let bOpt = AgoraBeautyOptions()
        bOpt.smoothnessLevel = 1
        bOpt.rednessLevel = 0.1
        return bOpt
    }()

    var remoteUserIDs: Set<UInt> = []
}
