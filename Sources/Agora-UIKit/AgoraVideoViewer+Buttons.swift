//
//  AgoraVideoViewer+Buttons.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// This file mostly contains programatically created MPButtons,
// The buttons call the following methods found in AgoraVideoViewer+VideoControl.swift:
// leaveChannel, toggleCam, toggleMic, flipCamera, toggleBroadcast, toggleBeautify

extension AgoraVideoViewer {
    fileprivate func positionButtonContainer(_ container: MPBlurView, _ contWidth: CGFloat, _ buttonMargin: CGFloat) {
        #if os(iOS)
        container.frame = CGRect(
            origin: CGPoint(
                x: (self.bounds.width - CGFloat(contWidth)) / 2,
                y: (self.bounds.height - 60 - 20 - 10)
            ), size: CGSize(width: contWidth, height: 60 + buttonMargin * 2)
        )
        container.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        #else
        container.frame = CGRect(
            origin: CGPoint(x: (self.bounds.width - CGFloat(contWidth)) / 2, y: 10),
            size: CGSize(width: contWidth, height: 60 + 20))
        container.autoresizingMask = [.minXMargin, .maxXMargin, .maxYMargin]
        container.layer?.cornerRadius = 20
        #endif
    }

    /// Add all the relevant buttons.
    /// The buttons are set to add to their respective parent views
    /// Whenever called, so I'm discarding the result for most of them here.
    internal func addVideoButtons() {
        let container = self.getControlContainer()
        let buttons = [
            self.getCameraButton(), self.getMicButton(), self.getFlipButton(), self.getBeautifyButton(),
            self.getScreenShareButton()
        ].compactMap { $0 } + (self.delegate?.extraButtons?() ?? [])
        let buttonSize: CGFloat = 60
        let buttonMargin: CGFloat = 10

        buttons.enumerated().forEach({ (elem) in
            let button = elem.element
            #if os(iOS)
            container.contentView.addSubview(button)
            #else
            container.addSubview(button)
            #endif
            button.frame = CGRect(
                origin: CGPoint(x: buttonMargin, y: buttonMargin),
                size: CGSize(width: 60, height: 60)
            )
            switch self.agoraSettings.buttonPosition {
            case .top, .bottom:
                button.frame.origin.x += (buttonMargin + buttonSize) * CGFloat(elem.offset)
            case .left, .right:
                button.frame.origin.y += (buttonMargin + buttonSize) * CGFloat(elem.offset)
            }
            #if os(iOS)
            button.layer.cornerRadius = buttonSize / 2
            button.backgroundColor = .systemGray
            #else
            button.isBordered = false
            button.layer?.cornerRadius = buttonSize / 2
            button.layer?.backgroundColor = NSColor.systemGray.cgColor
            #endif
        })
        let contWidth = CGFloat(buttons.count) * (60 + buttonMargin) + buttonMargin
        positionButtonContainer(container, contWidth, buttonMargin)
    }

    internal func getControlContainer() -> MPBlurView {
        if let controlContainer = self.controlContainer {
            return controlContainer
        }
        #if os(iOS)
        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        #else
        let container = NSVisualEffectView()
        container.blendingMode = .withinWindow
        container.material = .menu
        container.wantsLayer = true
        #endif
        container.isHidden = true
        self.addSubview(container)
        #if os(iOS)
        container.isUserInteractionEnabled = true
        #endif
        self.controlContainer = container
        return container
    }

    /// Get the button for enabling/disabling the camera
    /// - Returns: The button for enabling/disabling the camera if enabled, otherwise nil
    open func getCameraButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.cameraButton) { return nil }
        if let camButton = self.camButton { return camButton }

        let button = MPButton.newToggleButton(unselected: MPButton.videoSymbol, selected: MPButton.videoSlashSymbol)
        #if os(iOS)
        button.addTarget(self, action: #selector(toggleCam), for: .touchUpInside)
        #else
        button.target = self
        button.action = #selector(self.toggleCam)
        #endif

        self.camButton = button
        return button
    }

    /// Get the button for muting/unmuting the microphone
    /// - Returns: The button for muting/unmuting the microphone if enabled, otherwise nil
    open func getMicButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.micButton) { return nil }
        if let micButton = self.micButton { return micButton }

        let button = MPButton.newToggleButton(
            unselected: MPButton.micSymbol, selected: MPButton.micSlashSymbol
        )
        #if os(iOS)
        button.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
        #else
        button.target = self
        button.action = #selector(toggleMic)
        #endif

        self.micButton = button
        return button
    }

    /// Get the button for sharing the current screen
    /// - Returns: The button for sharing screen if enabled, otherwise nil
    open func getScreenShareButton() -> MPButton? {
        #if os(iOS)
        return nil
        #else
        if !self.agoraSettings.enabledButtons.contains(.screenShareButton) { return nil }

        if let ssButton = self.screenShareButton { return ssButton }
        let button = MPButton.newToggleButton(
            unselected: MPButton.screenShareSymbol
        )
        button.target = self
        button.action = #selector(toggleScreenShare)
//        prepareSystemBroadcaster()
        self.screenShareButton = button
        return button
        #endif
    }

//    func prepareSystemBroadcaster() {
//        let frame = CGRect(x: 0, y:0, width: 60, height: 60)
//        let systemBroadcastPicker = RPSystemBroadcastPickerView(frame: frame)
//        systemBroadcastPicker.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
//        if let url = Bundle.main.url(forResource: "Agora-ScreenShare-Extension", withExtension: "appex", subdirectory: "PlugIns") {
//            if let bundle = Bundle(url: url) {
//                systemBroadcastPicker.preferredExtension = bundle.bundleIdentifier
//            }
//        }
//        self.addSubview(systemBroadcastPicker)
//    }

    /// Get the button for flipping the camera from front to rear facing
    /// - Returns: The button for flipping the camera if enabled, otherwise nil
    open func getFlipButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.flipButton) { return nil }
        if let flipButton = self.flipButton { return flipButton }
        #if os(iOS)
        let button = MPButton.newToggleButton(unselected: MPButton.cameraRotateSymbol)
        button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)

        self.flipButton = button
        return button
        #else
        return nil
        #endif
    }

    /// Get the button for enabling/disabling the beautify effect.
    /// - Returns: The button if enabled, otherwise nil
    open func getBeautifyButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.beautifyButton) { return nil }
        if let beautyButton = self.beautyButton {
            return beautyButton
        }

        let button = MPButton.newToggleButton(unselected: MPButton.wandSymbol)
        #if os(iOS)
        button.addTarget(self, action: #selector(toggleBeautify), for: .touchUpInside)
        #else
        button.target = self
        button.action = #selector(toggleBeautify)
        #endif

        self.beautyButton = button
        return button
    }
}
