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
    #if os(iOS)
    fileprivate func platformContainerSizing(
        _ frameOriginX: inout CGFloat, _ frameOriginY: inout CGFloat, _ contWidth: CGFloat,
        _ resizeMask: inout UIView.AutoresizingMask, _ containerSize: inout CGSize
    ) {
        resizeMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        switch self.agoraSettings.buttonPosition {
        case .top:
            frameOriginY = 30
            resizeMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        case .left, .right:
            containerSize = CGSize(width: containerSize.height, height: containerSize.width)
            frameOriginY = (self.bounds.height - CGFloat(contWidth)) / 2
            if self.agoraSettings.buttonPosition == .left {
                frameOriginX = 30
                resizeMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
            } else {
                frameOriginX = self.bounds.width - self.agoraSettings.buttonSize - 20 - 10
                resizeMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin]
            }
        case .bottom: break
        }
    }
    #elseif os(macOS)

    fileprivate func platformContainerSizing(
        _ frameOriginX: inout CGFloat, _ frameOriginY: inout CGFloat, _ contWidth: CGFloat,
        _ resizeMask: inout NSView.AutoresizingMask, _ containerSize: inout CGSize
    ) {
        switch self.agoraSettings.buttonPosition {
        case .top, .bottom:
            frameOriginX = (self.bounds.width - CGFloat(contWidth)) / 2
            if self.agoraSettings.buttonPosition == .top {
                frameOriginY = self.bounds.height - self.agoraSettings.buttonSize - 20 - 10
                resizeMask = [.minXMargin, .maxXMargin, .minYMargin]
            } else {
                frameOriginY = 20
                resizeMask = [.minXMargin, .maxXMargin, .maxYMargin]
            }
        case .left, .right:
            containerSize = CGSize(width: containerSize.height, height: containerSize.width)
            frameOriginY = (self.bounds.height - CGFloat(contWidth)) / 2
            if self.agoraSettings.buttonPosition == .left {
                frameOriginX = 20
                resizeMask = [.minYMargin, .maxXMargin, .maxYMargin]
            } else {
                frameOriginX = self.bounds.width - self.agoraSettings.buttonSize - 20 - 10
                resizeMask = [.minYMargin, .minXMargin, .maxYMargin]
            }
        }
    }
    #endif

    fileprivate func positionButtonContainer(_ container: MPBlurView, _ contWidth: CGFloat, _ buttonMargin: CGFloat) {
        var containerSize = CGSize(width: contWidth, height: self.agoraSettings.buttonSize + buttonMargin * 2)
        var frameOriginX = (self.bounds.width - CGFloat(contWidth)) / 2
        var frameOriginY = self.bounds.height - self.agoraSettings.buttonSize - 20 - 10
        var resizeMask: MPView.AutoresizingMask = []
        platformContainerSizing(&frameOriginX, &frameOriginY, contWidth, &resizeMask, &containerSize)
        #if os(iOS)
        container.layer.cornerRadius = self.agoraSettings.buttonSize / 3
        container.clipsToBounds = true
        #elseif os(macOS)
        container.layer?.cornerRadius = self.agoraSettings.buttonSize / 3
        #endif
        container.frame = CGRect(origin: CGPoint(x: frameOriginX, y: frameOriginY), size: containerSize)
        container.autoresizingMask = resizeMask
    }

    /// Add all the relevant buttons.
    /// The buttons are set to add to their respective parent views
    /// Whenever called, so I'm discarding the result for most of them here.
    internal func addVideoButtons(to container: MPBlurView) {
        let builtinButtons = [
            self.getCameraButton(), self.getMicButton(), self.getFlipButton(), self.getBeautifyButton(),
            self.getScreenShareButton()
        ].compactMap { $0 }
        let buttons = builtinButtons + (self.delegate?.extraButtons() ?? [])
        let buttonSize = self.agoraSettings.buttonSize
        let buttonMargin = self.agoraSettings.buttonMargin

        if builtinButtons.isEmpty {
            return
        }
        buttons.enumerated().forEach({ (elem) in
            let button = elem.element
            #if os(iOS)
            container.contentView.addSubview(button)
            #elseif os(macOS)
            container.addSubview(button)
            #endif
            button.frame = CGRect(
                origin: CGPoint(x: buttonMargin, y: buttonMargin),
                size: CGSize(width: buttonSize, height: buttonSize)
            )
            switch self.agoraSettings.buttonPosition {
            case .top, .bottom:
                button.frame.origin.x += (buttonMargin + buttonSize) * CGFloat(elem.offset)
            case .left, .right:
                button.frame.origin.y += (buttonMargin + buttonSize) * CGFloat(elem.offset)
            }
            #if os(iOS)
            button.layer.cornerRadius = buttonSize / 2
            if elem.offset < builtinButtons.count {
                button.backgroundColor = self.agoraSettings.colors.buttonDefaultNormal
                button.tintColor = self.agoraSettings.colors.buttonTintColor
            }
            #elseif os(macOS)
            button.isBordered = false
            button.layer?.cornerRadius = buttonSize / 2
            if elem.offset < builtinButtons.count {
                button.layer?.backgroundColor = self.agoraSettings.colors.buttonDefaultNormal.cgColor
                button.contentTintColor = self.agoraSettings.colors.buttonTintColor
            }
            #endif
        })
        self.setCamAndMicButtons()
        let contWidth = CGFloat(buttons.count) * (buttonSize + buttonMargin) + buttonMargin
        positionButtonContainer(container, contWidth, buttonMargin)
    }

    internal func setCamAndMicButtons() {
        self.camButton?.isOn = !self.agoraSettings.cameraEnabled
        self.micButton?.isOn = !self.agoraSettings.micEnabled
        #if os(iOS)
        self.camButton?.backgroundColor = self.agoraSettings.cameraEnabled
            ? self.agoraSettings.colors.camButtonNormal : self.agoraSettings.colors.camButtonSelected
        self.micButton?.backgroundColor = self.agoraSettings.micEnabled
            ? self.agoraSettings.colors.micButtonNormal : self.agoraSettings.colors.micButtonSelected
        #elseif os(macOS)
        self.camButton?.layer?.backgroundColor = (
            self.agoraSettings.cameraEnabled
                ? self.agoraSettings.colors.camButtonNormal
                : self.agoraSettings.colors.camButtonSelected
        ).cgColor
        self.micButton?.layer?.backgroundColor = (
            self.agoraSettings.micEnabled
                ? self.agoraSettings.colors.micButtonNormal
                : self.agoraSettings.colors.micButtonSelected
        ).cgColor
        if let cambtn = self.camButton, cambtn.isOn, !cambtn.alternateTitle.isEmpty {
            swap(&cambtn.title, &cambtn.alternateTitle)
        }
        if let micbtn = self.micButton, micbtn.isOn, !micbtn.alternateTitle.isEmpty {
            swap(&micbtn.title, &micbtn.alternateTitle)
        }
        #endif
    }

    @discardableResult
    internal func getControlContainer() -> MPBlurView {
        if let controlContainer = self.controlContainer {
            return controlContainer
        }
        #if os(iOS)
        let container = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        #elseif os(macOS)
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
        self.addVideoButtons(to: container)
        return container
    }

    /// Get the button for enabling/disabling the camera
    /// - Returns: The button for enabling/disabling the camera if enabled, otherwise nil
    open func getCameraButton() -> MPButton? {
        if !self.agoraSettings.enabledButtons.contains(.cameraButton) { return nil }
        if let camButton = self.camButton { return camButton }

        let button = MPButton.newToggleButton(
            unselected: MPButton.videoSymbol, selected: MPButton.muteVideoSelectedSymbol
        )
        #if os(iOS)
        button.addTarget(self, action: #selector(toggleCam), for: .touchUpInside)
        #elseif os(macOS)
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
            unselected: MPButton.micSymbol, selected: MPButton.muteMicSelectedSymbol
        )
        #if os(iOS)
        button.addTarget(self, action: #selector(toggleMic), for: .touchUpInside)
        #elseif os(macOS)
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
        #elseif os(macOS)
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
        #elseif os(macOS)
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
        #elseif os(macOS)
        button.target = self
        button.action = #selector(toggleBeautify)
        #endif

        self.beautyButton = button
        return button
    }
}
