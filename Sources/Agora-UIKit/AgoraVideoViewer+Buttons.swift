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
    /// Add all the relevant buttons.
    /// The buttons are set to add to their respective parent views
    /// Whenever called, so I'm discarding the result for most of them here.
    func addVideoButtons() {
        let container = self.getControlContainer()
        let buttons = [
            self.getCameraButton(), self.getMicButton(), self.getFlipButton(), self.getBeautifyButton()
        ].compactMap { $0 } + (self.delegate?.extraButtons?() ?? [])
        let buttonSize: CGFloat = 60
        buttons.enumerated().forEach({ (elem) in
            let button = elem.element
            container.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 60))
            switch self.agoraSettings.buttonPosition {
            case .top, .bottom:
                button.centerXAnchor.constraint(
                    equalTo: container.centerXAnchor,
                    constant: (CGFloat(elem.offset) + 0.5 - CGFloat(buttons.count) / 2) * (buttonSize + 10)
                ).isActive = true
            case .left, .right:
                button.centerYAnchor.constraint(
                    equalTo: container.centerYAnchor,
                    constant: (CGFloat(elem.offset) + 0.5 - CGFloat(buttons.count) / 2) * (buttonSize + 10)
                ).isActive = true
            }
            switch self.agoraSettings.buttonPosition {
            case .bottom:
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10).isActive = true
            case .top:
                button.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true
            case .right:
                button.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -10).isActive = true
            case .left:
                button.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 10).isActive = true
            }
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            #if os(iOS)
            button.layer.cornerRadius = buttonSize / 2
            button.backgroundColor = .systemGray
            #else
            button.isBordered = false
            button.layer?.cornerRadius = buttonSize / 2
            button.layer?.backgroundColor = NSColor.systemGray.cgColor
            #endif
        })
    }

    internal func getControlContainer() -> MPView {
        if let controlContainer = self.controlContainer {
            return controlContainer
        }
        let container = MPView()
        container.isHidden = true
        self.addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        [container.widthAnchor.constraint(equalTo: self.widthAnchor),
         container.heightAnchor.constraint(equalTo: self.heightAnchor)].forEach { $0.isActive = true }
        #if os(iOS)
        switch self.agoraSettings.buttonPosition {
        case .bottom:
            container.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        case .top:
            container.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        case .right:
            container.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor).isActive = true
            container.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        case .left:
            container.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor).isActive = true
            container.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        }
        container.isUserInteractionEnabled = true
        #else
        switch self.agoraSettings.buttonPosition {
        case .bottom:
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        case .top:
            container.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        case .right:
            container.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        case .left:
            container.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
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
