//
//  AgoraSingleVideoView.swift
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

/// View for the individual Agora Camera Feed.
public class AgoraSingleVideoView: MPView {
    /// Is the video turned off for this user.
    public var videoMuted: Bool = true {
        didSet {
            if oldValue != videoMuted {
                self.canvas.view?.isHidden = videoMuted
            }
        }
    }
    /// Is the microphone muted for this user.
    public var audioMuted: Bool = true {
        didSet {
            self.mutedFlag.isHidden = !audioMuted
        }
    }
    /// Unique ID for this user, used by the video feed.
    var uid: UInt {
        get { self.canvas.uid }
        set { self.canvas.uid = newValue }
    }
    /// Canvas used to render the Agora RTC Video.
    public var canvas: AgoraRtcVideoCanvas
    /// View that the AgoraRtcVideoCanvas is sending the video feed to
    var hostingView: MPView? {
        self.canvas.view
    }

    var micFlagColor: MPColor

    /// Icon to show if this user is muting their microphone
    lazy var mutedFlag: MPView = {
        #if os(iOS)
        let muteFlag = UIImageView(
            image: UIImage(
                systemName: MPButton.micSlashSymbol
            )
        )
        muteFlag.tintColor = self.micFlagColor
        #else
        let muteFlag = MPButton()
        muteFlag.font = .systemFont(ofSize: NSFont.systemFontSize * 1.5)
        muteFlag.attributedTitle = NSAttributedString(
            string: MPButton.micSlashSymbol,
            attributes: [ NSAttributedString.Key.foregroundColor: self.micFlagColor ]
        )
        #endif
        self.addSubview(muteFlag)
        #if os(iOS)
        muteFlag.frame = CGRect(
            origin: CGPoint(x: self.frame.width - 35, y: self.frame.height - 35),
            size: CGSize(width: 25, height: 25)
        )
        muteFlag.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        #else
        muteFlag.isBordered = false
        muteFlag.wantsLayer = true
        muteFlag.layer?.backgroundColor = .clear
        muteFlag.frame = CGRect(
            origin: CGPoint(x: self.frame.width - 30, y: 10),
            size: CGSize(width: 25, height: 25)
        )
        muteFlag.frame.origin = CGPoint(x: self.frame.width - 30, y: 10)
        muteFlag.autoresizingMask = [.maxYMargin, .minXMargin]
        #endif
        return muteFlag
    }()

    /// Create a new AgoraSingleVideoView to be displayed in your app
    /// - Parameters:
    ///   - uid: User ID of the `AgoraRtcVideoCanvas` inside this view
    ///   - micColor: Color to be applied when the local or remote user mutes their microphone
    public init(uid: UInt, micColor: MPColor) {
        self.canvas = AgoraRtcVideoCanvas()
        self.micFlagColor = micColor
        super.init(frame: .zero)
        self.setBackground()
        self.canvas.uid = uid
        let hostingView = MPView()
        hostingView.frame = self.bounds
        #if os(iOS)
        hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #else
        hostingView.autoresizingMask = [.width, .height]
        #endif
        self.canvas.view = hostingView
        self.addSubview(hostingView)
        self.setupMutedFlag()
    }

    private func setupMutedFlag() {
        self.audioMuted = true
    }

    internal func setBackground() {
        let backgroundView = MPView()
        #if os(iOS)
        backgroundView.backgroundColor = .secondarySystemBackground
        let bgButton = MPButton(type: .custom)
        bgButton.setImage(
            UIImage(
                systemName: MPButton.personSymbol,
                withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
            for: .normal
        )
        #else
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let bgButton = MPButton()
        bgButton.title = MPButton.personSymbol
        bgButton.isBordered = false
        bgButton.isEnabled = false
        #endif
        backgroundView.addSubview(bgButton)

        bgButton.frame = backgroundView.bounds
        self.addSubview(backgroundView)
        backgroundView.frame = self.bounds
        #if os(iOS)
        bgButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #else
        bgButton.autoresizingMask = [.width, .height]
        backgroundView.autoresizingMask = [.width, .height]
        #endif
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
