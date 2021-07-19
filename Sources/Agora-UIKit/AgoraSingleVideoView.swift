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
            self.updateUserOptions()
        }
    }
    /// Is the microphone muted for this user.
    public var audioMuted: Bool = true {
        didSet {
            self.mutedFlag.isHidden = !audioMuted
            self.updateUserOptions()
        }
    }

    var streamContainer: StreamMessageContainer?

    /// Whether the options label should be visible or not.
    public var showOptions: Bool = true {
        didSet {
            self.userOptions?.isHidden = !self.showOptions
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

    enum UserOptions: String {
        case camera
        case microphone
    }

    /// Find the string for the option ready to request the remote user to mute or unmute their mic or camera
    /// - Parameters:
    ///   - option: Device to be muted or umuted
    ///   - isMuted: Boolean option to mute or unmute device
    /// - Returns: String to be displayed in the mute/unmute option
    open func userOptionsString(
        for option: StreamMessageController.MutingDevices, isMuted: Bool
    ) -> String {
        switch option {
        case .camera:
            return isMuted ? MPButton.unmuteCameraString : MPButton.muteCameraString
        case .microphone:
            return isMuted ? MPButton.unmuteMicString : MPButton.muteMicString
        }
    }

    func updateUserOptions() {
        #if os(macOS)
        guard let userOptions = self.userOptions as? NSPopUpButton else {
            return
        }
        userOptions.removeAllItems()
        self.addItems(to: userOptions)
        #endif
    }
    #if os(macOS)
    open func addItems(to userOptionsBtn: NSPopUpButton) {
        let actionItem = NSMenuItem()
        actionItem.attributedTitle = NSAttributedString(
            string: "􀣋",
            attributes: [ NSAttributedString.Key.foregroundColor: self.micFlagColor ]
        )
        userOptionsBtn.menu?.insertItem(actionItem, at: 0)
        StreamMessageController.MutableDevices.allCases.forEach { enumCase in
            var isMuted: Bool
            switch enumCase {
            case .camera:
                isMuted = self.videoMuted
            case .microphone:
                isMuted = self.audioMuted
            }
            userOptionsBtn.addItem(withTitle: self.userOptionsString(for: enumCase, isMuted: isMuted))
        }
    }
    #endif
    lazy var userOptions: MPView? = {
        #if os(iOS)
        let userOptionsBtn = MPButton.newToggleButton(
            unselected: MPButton.ellipsisSymbol
        )
        userOptionsBtn.layer.zPosition = 3
        userOptionsBtn.tintColor = .systemGray
        #else
        let userOptionsBtn = NSPopUpButton(frame: .zero, pullsDown: true)

//        userOptionsBtn.wantsLayer = true
//        userOptionsBtn.layer?.backgroundColor = .white
        (userOptionsBtn.cell as! NSButtonCell).backgroundColor = .selectedContentBackgroundColor
        self.addItems(to: userOptionsBtn)
        #endif
        self.addSubview(userOptionsBtn)
        #if os(iOS)
        userOptionsBtn.frame = CGRect(
            origin: CGPoint(x: 10, y: 10),
            size: CGSize(width: 40, height: 25)
        )
        userOptionsBtn.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        userOptionsBtn.addTarget(self, action: #selector(optionsBtnSelected), for: .touchUpInside)
        #else
        userOptionsBtn.isBordered = false
        userOptionsBtn.wantsLayer = true
        userOptionsBtn.layer?.backgroundColor = .clear
        userOptionsBtn.frame = CGRect(
            origin: CGPoint(x: 10, y: self.frame.height - 30),
            size: CGSize(width: 40, height: 25)
        )
        userOptionsBtn.autoresizingMask = [.minYMargin, .maxXMargin]
        userOptionsBtn.target = self
        userOptionsBtn.action = #selector(optionsBtnSelected)
        #endif
//        userOptionsBtn.isHidden = true
        return userOptionsBtn
    }()

    #if os(iOS)
    /// The options button has been selected
    /// - Parameter sender: Button that was selected
    @objc open func optionsBtnSelected(sender: UIButton) {
        let alert = UIAlertController(title: "Request Action", message: nil, preferredStyle: .actionSheet)
        StreamMessageController.MutingDevices.allCases.forEach { enumCase in
            var isMuted: Bool
            switch enumCase {
            case .camera:
                isMuted = self.videoMuted
            case .microphone:
                isMuted = self.audioMuted
            }
            alert.addAction(UIAlertAction(title: self.userOptionsString(for: enumCase, isMuted: isMuted), style: .default, handler: optionsActionSelected(sender:)))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.streamContainer?.presentAlert(alert: alert, animated: true)
    }

    /// Action selected such as mute/unmute microphone/camera.
    /// - Parameter sender: UIAlertAction that was selected.
    open func optionsActionSelected(sender: UIAlertAction) {
        guard let actionTitle = sender.title else { return }
        if let reqError = self.streamContainer?.streamController?.createRequest(to: self.uid, fromString: actionTitle),
           !reqError {
            AgoraVideoViewer.agoraPrint(.error, message: "invalid action title: \(actionTitle)")
        }
    }
    #else
    /// Options button has been selected, now display available requests
    /// - Parameter sender: Button that was selected
    @objc public func optionsBtnSelected(sender: NSPopUpButton) {
        guard let selectedType = UserOptions(rawValue: sender.selectedItem?.title ?? "") else {
            return
        }
        switch selectedType {
        case .camera:
            self.streamContainer?.streamController?.sendMuteRequest(to: self.uid, mute: true, device: .camera)
        case .microphone:
            self.streamContainer?.streamController?.sendMuteRequest(to: self.uid, mute: true, device: .microphone)
        default:
            return
        }
//        let pop = actionbutt
//
//        pop.addItem(NSMenuItem(title: "Mute User", action: #selector(muteRequest), keyEquivalent: "m"))
//        sender.addSubview(pop)
    }
    #endif

    @objc func muteRequest() {
    }
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
            origin: CGPoint(x: self.frame.width - 35, y: 10),
            size: CGSize(width: 25, height: 25)
        )
        muteFlag.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        #else
        muteFlag.isBordered = false
        muteFlag.wantsLayer = true
        muteFlag.layer?.backgroundColor = .clear
        muteFlag.frame = CGRect(
            origin: CGPoint(x: self.frame.width - 30, y: self.frame.height - 30),
            size: CGSize(width: 25, height: 25)
        )
        muteFlag.autoresizingMask = [.minYMargin, .minXMargin]
        #endif
        return muteFlag
    }()

    /// Create a new AgoraSingleVideoView to be displayed in your app
    /// - Parameters:
    ///   - uid: User ID of the `AgoraRtcVideoCanvas` inside this view
    ///   - micColor: Color to be applied when the local or remote user mutes their microphone
    ///   - showOptions: Whether we want to show options to mute/unmute this user
    ///   - streamContainer: Container to access the StreamMessageContainer.
    public init(uid: UInt, micColor: MPColor, showOptions: Bool = false, streamContainer: StreamMessageContainer? = nil) {
        self.canvas = AgoraRtcVideoCanvas()
        self.micFlagColor = micColor
        self.streamContainer = streamContainer
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
        self.setupOptions(visible: streamContainer != nil ? showOptions : false)
    }

    func setupOptions(visible showOptions: Bool) {
        self.showOptions = showOptions
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
