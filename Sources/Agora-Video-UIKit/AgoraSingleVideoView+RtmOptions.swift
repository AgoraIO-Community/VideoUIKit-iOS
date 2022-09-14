//
//  AgoraSingleVideoView+RtmOptions.swift
//  AgoraUIKit_iOS
//
//  Created by Max Cobb on 19/07/2021.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#if canImport(AgoraRtmControl)
import AgoraRtmControl
#endif
#endif

extension AgoraSingleVideoView {
    func updateUserOptions() {
        #if os(macOS) && canImport(AgoraRtmControl)
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
}

#if canImport(AgoraRtmControl)
extension AgoraSingleVideoView {

    /// Find the string for the option ready to request the remote user to mute or unmute their mic or camera
    /// - Parameters:
    ///   - option: Device to be muted or umuted
    ///   - isMuted: Boolean option to mute or unmute device
    /// - Returns: String to be displayed in the mute/unmute option
    @objc open func userOptionsString(
        for option: AgoraVideoViewer.MutingDevices, isMuted: Bool
    ) -> String {
        switch option {
        case .camera:
            return isMuted ? MPButton.unmuteCameraString : MPButton.muteCameraString
        case .microphone:
            return isMuted ? MPButton.unmuteMicString : MPButton.muteMicString
        }
    }

    #if os(macOS)
    @objc open func addItems(to userOptionsBtn: NSPopUpButton) {
        let actionItem = NSMenuItem()
        actionItem.attributedTitle = NSAttributedString(
            string: "􀣋",
            attributes: [ NSAttributedString.Key.foregroundColor: self.micFlagColor ]
        )
        userOptionsBtn.menu?.insertItem(actionItem, at: 0)
        AgoraVideoViewer.MutingDevices.allCases.forEach { enumCase in
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
        AgoraVideoViewer.MutingDevices.allCases.forEach { enumCase in
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
        if self.singleVideoViewDelegate != nil {
            self.singleVideoViewDelegate?.presentAlert(alert: alert, animated: true, viewer: self.userOptions ?? self)
        } else {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not present popup")
        }
    }

    /// Action selected such as mute/unmute microphone/camera.
    /// - Parameter sender: UIAlertAction that was selected.
    @objc public func optionsActionSelected(sender: UIAlertAction) {
        if let actionTitle = sender.title,
           let reqError = self.singleVideoViewDelegate?.createRequest(
            to: self.uid, fromString: actionTitle
           ), !reqError {
            AgoraVideoViewer.agoraPrint(.error, message: "invalid action title: \(actionTitle)")
        }
    }
    #elseif os(macOS)
    /// Options button has been selected, now display available requests
    /// - Parameter sender: Button that was selected
    @objc public func optionsBtnSelected(sender: NSPopUpButton) {
        if let actionTitle = sender.selectedItem?.title,
           let reqError = self.singleVideoViewDelegate?.createRequest(
            to: self.uid, fromString: actionTitle
           ), !reqError {
            AgoraVideoViewer.agoraPrint(.error, message: "invalid action title: \(actionTitle)")
        }
    }
    #endif

}
#endif
