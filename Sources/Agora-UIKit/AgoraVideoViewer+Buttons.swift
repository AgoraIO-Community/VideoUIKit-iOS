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
        container.isHidden = true

        let buttons = [
            self.getCameraButton(), self.getMicButton(),
            self.getFlipButton(), self.getBeautifyButton()
        ].compactMap { $0 } + (self.delegate?.extraButtons?() ?? [])
        let buttonSize: CGFloat = 60
        buttons.enumerated().forEach({ (elem) in
            let button = elem.element
            container.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 60))
            [
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
                button.centerXAnchor.constraint(
                    equalTo: container.centerXAnchor,
                    constant: (CGFloat(elem.offset) + 0.5 - CGFloat(buttons.count) / 2) * (buttonSize + 10)
                ),
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize),
            ].forEach { $0.isActive = true }
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

    func getControlContainer() -> MPView {
        if let controlContainer = self.controlContainer {
            return controlContainer
        }
        let container = MPView()
        self.addSubview(container)

        container.translatesAutoresizingMaskIntoConstraints = false
        [
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            container.widthAnchor.constraint(equalTo: self.widthAnchor),
            container.heightAnchor.constraint(equalTo: self.heightAnchor)
        ].forEach { $0.isActive = true }
        #if os(iOS)
        container.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        container.isUserInteractionEnabled = true
        #else
        container.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        #endif

        self.controlContainer = container
        return container
    }

    open func getCameraButton() -> MPButton? {
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

    open func getMicButton() -> MPButton? {
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

    open func getFlipButton() -> MPButton? {
        if let flipButton = self.flipButton { return flipButton }
        #if os(macOS)
        return nil
        #else
        let button = MPButton.newToggleButton(unselected: MPButton.cameraRotateSymbol)
        button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)

        self.flipButton = button
        return button
        #endif
    }

    open func getBeautifyButton() -> MPButton? {
        if let beautyButton = self.beautyButton { return beautyButton }

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
