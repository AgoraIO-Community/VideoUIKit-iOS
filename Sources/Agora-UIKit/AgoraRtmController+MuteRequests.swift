//
//  AgoraRtmController+MuteRequests.swift
//  
//
//  Created by Max Cobb on 29/07/2021.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension AgoraRtmController {
    /// Devices that can be muted/unmuted
    public enum MutingDevices: Int, CaseIterable {
        /// The device camera
        case camera = 0
        /// The device microphone
        case microphone = 1
    }

    /// Structure that contains information about a mute request
    public struct MuteRequest: Codable {
        /// Type of message being sent
        public var messageType: String? = "MuteRequest"
        /// RTC ID that the request is intended for
        public var rtcId: UInt
        /// Whether the request is to mute or unmute a device
        public var mute: Bool
        /// Device to be muted or unmuted
        public var device: AgoraRtmController.MutingDevices.RawValue
        /// Whether this is a request or a forceful change
        public var isForceful: Bool

        /// Create a new Mute Request
        /// - Parameters:
        ///   - rtcId: RTC Id of the target remote user
        ///   - mute: Whether the request is to mute or unmute a device
        ///   - device: Device to be muted or unmuted
        ///   - isForceful: Whether this is a request or a forceful change
        public init(
            rtcId: UInt, mute: Bool,
            device: AgoraRtmController.MutingDevices, isForceful: Bool
        ) {
            self.rtcId = rtcId
            self.mute = mute
            self.device = device.rawValue
            self.isForceful = isForceful
        }
    }

    /// Enum of request types being made.
    public enum GenericRequestType: String, Codable {
        /// Send this type when you are requesting a user's UserData
        case userdata
        /// Send this type when you are requesting a user's presence
        case ping
        /// Send this type back to a presence request (ping)
        case pong
    }

    /// Request to be sent over RTM that has no content other than the type
    public struct RtmGenericRequest: Codable {
        /// Type of generic request.
        public var type: GenericRequestType
    }

    /// Create and send request to user to mute/unmute a device
    /// - Parameters:
    ///   - uid: RTM User ID to send the request to
    ///   - str: String from the action label to
    /// - Returns: Boolean stating if the request was valid or not
    open func createRequest(
        to uid: UInt,
        fromString str: String
    ) -> Bool {
        switch str {
        case MPButton.unmuteCameraString:
            self.sendMuteRequest(to: uid, mute: false, device: .camera)
        case MPButton.muteCameraString:
            self.sendMuteRequest(to: uid, mute: true, device: .camera)
        case MPButton.unmuteMicString:
            self.sendMuteRequest(to: uid, mute: false, device: .microphone)
        case MPButton.muteMicString:
            self.sendMuteRequest(to: uid, mute: true, device: .microphone)
        default:
            return false
        }
        return true
    }

    /// Create and send request to mute/unmute a device
    /// - Parameters:
    ///   - rtcId: RTC User ID to send the request to
    ///   - mute: Whether the device should be muted or unmuted
    ///   - device: Type of device (camera/microphone)
    ///   - isForceful: Whether the request should force its way through, otherwise a request is made. Cannot forcefully unmute.
    open func sendMuteRequest(to rtcId: UInt, mute: Bool, device: MutingDevices, isForceful: Bool = false) {
        if isForceful == true, mute == false {
            AgoraVideoViewer.agoraPrint(.error, message: "Invalid mute request")
            return
        }
        let muteReq = MuteRequest(rtcId: rtcId, mute: mute, device: device, isForceful: isForceful)
        self.sendRaw(message: muteReq, user: rtcId) { sendStatus in
            if sendStatus == .ok {
                AgoraVideoViewer.agoraPrint(.verbose, message: "message was sent!")
            } else {
                AgoraVideoViewer.agoraPrint(.error, message: sendStatus)
            }
        }
    }

}

extension AgoraVideoViewer {
    /// Handle mute request, by showing popup or directly changing the device state
    /// - Parameter muteReq: Incoming mute request data
    open func handleMuteRequest(muteReq: AgoraRtmController.MuteRequest) {
        guard let device = AgoraRtmController.MutingDevices(rawValue: muteReq.device) else {
            return
        }
        if device == .camera, self.agoraSettings.cameraEnabled == !muteReq.mute { return }
        if device == .microphone, self.agoraSettings.micEnabled == !muteReq.mute { return }

        AgoraVideoViewer.agoraPrint(
            .error,
            message: "user \(muteReq.rtcId) (self) should \(muteReq.mute ? "" : "un")mute" +
                " their \(device) by \(muteReq.isForceful ? "force" : "request")"
        )
        func setDevice(_ sender: Any? = nil) {
            switch device {
            case .camera:
                self.setCam(to: !muteReq.mute)
            case .microphone:
                self.setMic(to: !muteReq.mute)
            }
        }
        if muteReq.isForceful {
            setDevice()
            return
        }
        let alertTitle = "\(muteReq.mute ? "" : "un")mute \(device)?"
        #if os(iOS)
        let alert = UIAlertController(
            title: alertTitle, message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: setDevice))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.presentAlert(alert: alert, animated: true)
        #elseif os(macOS)
        let alert = NSAlert()
        alert.addButton(withTitle: "Confirm")
        alert.addButton(withTitle: "Cancel")
        alert.messageText = alertTitle
        alert.alertStyle = .warning
        alert.beginSheetModal(for: self.window!) { modalResponse in
            if modalResponse.rawValue == 1000 {
                setDevice()
            }
        }
        #endif
    }

}
