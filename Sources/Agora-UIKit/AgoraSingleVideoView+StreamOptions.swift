//
//  AgoraSingleVideoView+StreamOptions.swift
//  AgoraUIKit_iOS
//
//  Created by Max Cobb on 19/07/2021.
//

import Foundation

extension AgoraSingleVideoView {

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
            alert.addAction(UIAlertAction(
                                title: self.userOptionsString(for: enumCase, isMuted: isMuted),
                                style: .default,
                                handler: optionsActionSelected(sender:)
            ))
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
        }
    }
    #endif

}
