//
//  AgoraSingleVideoView+RtmOptions.swift
//  AgoraUIKit_iOS
//
//  Created by Max Cobb on 19/07/2021.
//

import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension AgoraSingleVideoView {

    /// Find the string for the option ready to request the remote user to mute or unmute their mic or camera
    /// - Parameters:
    ///   - option: Device to be muted or umuted
    ///   - isMuted: Boolean option to mute or unmute device
    /// - Returns: String to be displayed in the mute/unmute option
    open func userOptionsString(
        for option: AgoraRtmController.MutingDevices, isMuted: Bool
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
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.updateUserOptions()
            }
            return
        }
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
        AgoraRtmController.MutingDevices.allCases.forEach { enumCase in
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

    #if os(iOS)
    /// The options button has been selected
    /// - Parameter sender: Button that was selected
    @objc open func optionsBtnSelected(sender: UIButton) {
        let alert = UIAlertController(title: "Request Action", message: nil, preferredStyle: .actionSheet)
        AgoraRtmController.MutingDevices.allCases.forEach { enumCase in
            var isMuted: Bool
            switch enumCase {
            case .camera:
                isMuted = self.videoMuted
            case .microphone:
                isMuted = self.audioMuted
            }
            alert.addAction(
                UIAlertAction(
                    title: self.userOptionsString(for: enumCase, isMuted: isMuted),
                    style: .default,
                    handler: optionsActionSelected(sender:)
                )
            )
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.singleVideoViewDelegate?.presentAlert(alert: alert, animated: true)
    }

    /// Action selected such as mute/unmute microphone/camera.
    /// - Parameter sender: UIAlertAction that was selected.
    open func optionsActionSelected(sender: UIAlertAction) {
        if let actionTitle = sender.title,
           let reqError = self.singleVideoViewDelegate?.rtmController?.createRequest(
            to: self.uid, fromString: actionTitle
           ), !reqError {
            AgoraVideoViewer.agoraPrint(.error, message: "invalid action title: \(actionTitle)")
        }
    }
    #else
    /// Options button has been selected, now display available requests
    /// - Parameter sender: Button that was selected
    @objc public func optionsBtnSelected(sender: NSPopUpButton) {
        if let actionTitle = sender.selectedItem?.title,
           let reqError = self.singleVideoViewDelegate?.rtmController?.createRequest(
            to: self.uid, fromString: actionTitle
           ), !reqError {
            AgoraVideoViewer.agoraPrint(.error, message: "invalid action title: \(actionTitle)")
        }
    }
    #endif

}
