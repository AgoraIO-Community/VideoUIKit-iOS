//
//  AgoraVideoViewer.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
public typealias MPButton=UIButton
public typealias MPImage=UIImage
public typealias MPView = UIView
public typealias MPViewController = UIViewController
#elseif os(macOS)
import AppKit
public typealias MPButton=NSButton
public typealias MPImage=NSImage
public typealias MPView = NSView
public typealias MPViewController = NSViewController
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
    public init(appId: String, appToken: String? = nil) {
        self.appId = appId
        self.appToken = appToken
    }
}

@objc public protocol AgoraVideoViewerDelegate: AnyObject {
    @objc optional func joinedChannel(channel: String)
    @objc optional func leftChannel()
    @objc optional func tokenWillExpire(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String)
    @objc optional func tokenDidExpire(_ engine: AgoraRtcEngineKit)
    @objc optional func extraButtons() -> [MPButton]
}

open class AgoraVideoViewer: MPView {

    public var delegate: AgoraVideoViewerDelegate?

    public internal(set) var agoraSettings: AgoraSettings

    var videoRenderMode: AgoraVideoRenderMode {
        get { self.agoraSettings.videoRenderMode }
        set {
            self.agoraSettings.videoRenderMode = newValue
            self.userVideoLookup.values.forEach { $0.canvas.renderMode = newValue }
        }
    }
    public enum Style: Equatable {
        case grid
        case floating
        case custom(customFunction: (AgoraVideoViewer, EnumeratedSequence<[UInt: AgoraSingleVideoView]>, Int) -> Void)

        public static func ==(lhs: AgoraVideoViewer.Style, rhs: AgoraVideoViewer.Style) -> Bool {
            switch (lhs, rhs) {
            case (.grid, .grid), (.floating, .floating):
                return true
            default:
                return false
            }
        }
    }

    internal var parentViewController: MPViewController?
    public internal(set) var activeSpeaker: UInt? {
        didSet {
            self.reorganiseVideos()
        }
    }

    public var overrideActiveSpeaker: UInt? {
        didSet {
            if oldValue != overrideActiveSpeaker {
                self.reorganiseVideos()
            }
        }
    }

    /// Setting to zero will tell Agora to assign one for you
    lazy var userID: UInt = 0
    internal var connectionData: AgoraConnectionData

    public var userRole: AgoraClientRole = .broadcaster {
        didSet {
            self.agkit.setClientRole(self.userRole)
        }
    }

    internal var currentToken: String? {
        get { self.connectionData.appToken }
        set { self.connectionData.appToken = newValue }
    }

    lazy var floatingVideoHolder: MPCollectionView = {

        let collView = AgoraCollectionViewer()
        self.addSubview(collView)
        collView.delegate = self
        collView.dataSource = self
//        collView.translatesAutoresizingMaskIntoConstraints = false
        let floatPos = self.agoraSettings.floatPosition
        let smallerDim = 100 + 2 * AgoraCollectionViewer.cellSpacing
        switch floatPos {
        case .top, .bottom:
            collView.frame.size = CGSize(width: self.bounds.width, height: smallerDim)
            if floatPos == .top {
                #if os(macOS)
                collView.frame.origin = CGPoint(x: 0, y: self.bounds.height - smallerDim)
                collView.autoresizingMask = [.width, .maxYMargin]
                #else
                collView.frame.origin = .zero
                collView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
                #endif
            } else {
                #if os(macOS)
                collView.frame.origin = .zero
                collView.autoresizingMask = [.width, .minYMargin]
                #else
                collView.frame.origin = CGPoint(x: 0, y: self.bounds.height - smallerDim)
                collView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
                #endif
            }
        case .right, .left:
            (collView.collectionViewLayout as? MPCollectionViewFlowLayout)?.scrollDirection = .vertical
            collView.frame.size = CGSize(width: smallerDim, height: self.bounds.height)
            if floatPos == .left {
                collView.frame.origin = .zero
                #if os(macOS)
                collView.autoresizingMask = [.height, .maxXMargin]
                #else
                collView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
                #endif
            } else {
                collView.frame.origin = CGPoint(x: self.bounds.width - smallerDim, y: 0)
                #if os(macOS)
                collView.autoresizingMask = [.height, .minXMargin]
                #else
                collView.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
                #endif
            }
        }
        #if os(macOS)
        self.addSubview(collView, positioned: .above, relativeTo: nil)
        #else
        self.bringSubviewToFront(collView)
        #endif
        return collView
    }()

    lazy var backgroundVideoHolder: MPView = {
        let rtnView = MPView()
        #if os(macOS)
        self.addSubview(rtnView, positioned: .below, relativeTo: nil)
        rtnView.wantsLayer = true
        rtnView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        #else
        self.addSubview(rtnView)
        self.sendSubviewToBack(rtnView)
        #endif
        rtnView.frame = self.bounds
        #if os(macOS)
        rtnView.autoresizingMask = [.width, .height]
        #else
        rtnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        return rtnView
    }()

    lazy public internal(set) var agkit: AgoraRtcEngineKit = {
        let engine = AgoraRtcEngineKit.sharedEngine(
            withAppId: connectionData.appId,
            delegate: self
        )
        engine.enableAudioVolumeIndication(1000, smooth: 3, report_vad: true)
        engine.setChannelProfile(.liveBroadcasting)
        engine.setClientRole(self.userRole)
        return engine
    }()

    public var style: AgoraVideoViewer.Style {
        didSet {
            if oldValue != self.style {
                AgoraVideoViewer.agoraPrint(.info, message: "changed style")
                self.reorganiseVideos()
            }
        }
    }

    public init(connectionData: AgoraConnectionData, viewController: MPViewController, style: AgoraVideoViewer.Style = .grid, agoraSettings: AgoraSettings = AgoraSettings()) {
        self.connectionData = connectionData
        self.parentViewController = viewController
        self.style = style
        self.agoraSettings = agoraSettings
        super.init(frame: .zero)
        self.addVideoButtons()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    internal var userVideoLookup: [UInt: AgoraSingleVideoView] = [:] {
        didSet {
            reorganiseVideos()
        }
    }

    internal var userVideosForGrid: [UInt: AgoraSingleVideoView] {
        if self.style == .floating {
            return self.userVideoLookup.filter { $0.key == (self.overrideActiveSpeaker ?? self.activeSpeaker ?? self.userID)}
        } else if self.style == .grid {
            return self.userVideoLookup
        } else {
            return [:]
        }
    }

    public func fills(view: MPView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        #if os(macOS)
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        #else
        self.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
        #endif
    }

    var controlContainer: MPView?
    var camButton: MPButton?
    var micButton: MPButton?
    var flipButton: MPButton?
    var beautyButton: MPButton?

    var beautyOptions: AgoraBeautyOptions = {
        let bOpt = AgoraBeautyOptions()
        bOpt.smoothnessLevel = 1
        bOpt.rednessLevel = 0.1
        return bOpt
    }()

    var remoteUserIDs: Set<UInt> = []

    @discardableResult
    internal func addLocalVideo() -> AgoraSingleVideoView? {
        if self.userID == 0 || self.userVideoLookup[self.userID] != nil {
            return self.userVideoLookup[self.userID]
        }
        let vidView = AgoraSingleVideoView(uid: self.userID)
        vidView.canvas.renderMode = self.agoraSettings.videoRenderMode
        self.agkit.setupLocalVideo(vidView.canvas)
        self.userVideoLookup[self.userID] = vidView
        return vidView
    }

    /// Shuffle around the videos if multiple people are hosting, grid formation.

    @discardableResult
    func addUserVideo(with userId: UInt, size: CGSize) -> AgoraSingleVideoView {
        if let remoteView = self.userVideoLookup[userId] {
            return remoteView
        }
        let remoteVideoView = AgoraSingleVideoView(uid: userId)
        remoteVideoView.canvas.renderMode = self.agoraSettings.videoRenderMode
        self.agkit.setupRemoteVideo(remoteVideoView.canvas)
        self.userVideoLookup[userId] = remoteVideoView
        if self.activeSpeaker == nil {
            self.activeSpeaker = userId
        }
        return remoteVideoView
    }

    func setRandomSpeaker() {
        if let randomNotMe = self.userVideoLookup.keys.shuffled().filter({ $0 != self.userID }).randomElement() {
            // active speaker has left, reassign activeSpeaker to a random member
            self.activeSpeaker = randomNotMe
        } else {
            self.activeSpeaker = nil
        }
    }

    func removeUserVideo(with userId: UInt) {
        guard let userSingleView = userVideoLookup[userId],
              let canView = userSingleView.canvas.view else {
            return
        }
        self.agkit.muteRemoteVideoStream(userId, mute: true)
        userSingleView.canvas.view = nil
        canView.removeFromSuperview()
        self.userVideoLookup.removeValue(forKey: userId)
        if let activeSpeaker = self.activeSpeaker, activeSpeaker == userId {
            self.setRandomSpeaker()
        }
    }
}
