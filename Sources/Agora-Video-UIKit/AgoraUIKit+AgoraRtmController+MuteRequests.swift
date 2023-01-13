//
//  AgoraUIKit+AgoraRtmController+MuteRequests.swift
//  
//
//  Created by Max Cobb on 04/04/2022.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(AgoraRtmControl)
import AgoraRtmControl
#endif

extension AgoraVideoViewer {
    /// Devices that can be muted/unmuted
    @objc public enum MutingDevices: Int, CaseIterable {
        /// The device camera
        case camera = 0
        /// The device microphone
        case microphone = 1
        var strVal: String {
            switch self {
            case .camera:
                return "camera"
            case .microphone:
                return "micropohne"
            }
        }
    }

    /// Structure that contains information about a mute request
    public struct MuteRequest: Codable {
        /// Type of message being sent
        public var messageType: String? = "MuteRequest"
        /// RTC ID that the request is intended for
        public var rtcId: Int
        /// Whether the request is to mute or unmute a device
        public var mute: Bool
        /// Device to be muted or unmuted
        public var device: MutingDevices.RawValue
        /// Whether this is a request or a forceful change
        public var isForceful: Bool

        /// Create a new Mute Request
        /// - Parameters:
        ///   - rtcId: RTC Id of the target remote user
        ///   - mute: Whether the request is to mute or unmute a device
        ///   - device: Device to be muted or unmuted
        ///   - isForceful: Whether this is a request or a forceful change
        public init(
            rtcId: Int, mute: Bool,
            device: MutingDevices, isForceful: Bool
        ) {
            self.rtcId = rtcId
            self.mute = mute
            self.device = device.rawValue
            self.isForceful = isForceful
        }
        var iOSUInt: UInt? {
            return AgoraUIKit.intToUInt(self.rtcId)
        }
    }

    /// Enum of request types being made.
    public enum DataRequestType: String, Codable {
        /// Send this type when you are requesting a user's UserData
        case userData
        /// Send this type when you are requesting a user's presence
        case ping
        /// Send this type back to a presence request (ping)
        case pong
    }

    /// Request to be sent over RTM that has no content other than the type
    public struct RtmDataRequest: Codable {
        /// Type of message being sent
        public var messageType: String? = "RtmDataRequest"
        /// Type of data request.
        public var type: DataRequestType
    }

    #if canImport(AgoraRtmControl)
    /// Create and send request to mute/unmute a device
    /// - Parameters:
    ///   - rtcId: RTC User ID to send the request to
    ///   - mute: Whether the device should be muted or unmuted
    ///   - device: Type of device (camera/microphone)
    ///   - isForceful: Whether the request should force its way through, otherwise a request is made. Cannot forcefully unmute.
    @objc open func sendMuteRequest(to rtcId: UInt, mute: Bool, device: MutingDevices, isForceful: Bool = false) {
        if isForceful == true, mute == false {
            AgoraVideoViewer.agoraPrint(.error, message: "Invalid mute request")
            return
        }
        // This is to make sure the user ID is understood across platforms.
        let safeRtcId = AgoraUIKit.uintToInt(rtcId)
        let muteReq = MuteRequest(rtcId: safeRtcId, mute: mute, device: device, isForceful: isForceful)
        self.rtmController?.sendCodable(message: muteReq, user: rtcId) { sendStatus in
            if sendStatus == .ok {
                AgoraVideoViewer.agoraPrint(.verbose, message: "message was sent!")
            } else {
                AgoraVideoViewer.agoraPrint(.error, message: sendStatus)
            }
        }
    }
    #endif

}

#if canImport(AgoraRtmControl)
extension SingleVideoViewDelegate {
    /// Create and send request to user to mute/unmute a device
    /// - Parameters:
    ///   - uid: RTM User ID to send the request to
    ///   - str: String from the action label to
    /// - Returns: Boolean stating if the request was valid or not
    public func createRequest(
        to uid: UInt,
        fromString str: String
    ) -> Bool {
        switch str {
        case MPButton.unmuteCameraString:
            self.sendMuteRequest(to: uid, mute: false, device: .camera, isForceful: false)
        case MPButton.muteCameraString:
            self.sendMuteRequest(to: uid, mute: true, device: .camera, isForceful: false)
        case MPButton.unmuteMicString:
            self.sendMuteRequest(to: uid, mute: false, device: .microphone, isForceful: false)
        case MPButton.muteMicString:
            self.sendMuteRequest(to: uid, mute: true, device: .microphone, isForceful: false)
        default:
            return false
        }
        return true
    }
}
#endif

extension AgoraVideoViewer {
    /// Handle mute request, by showing popup or directly changing the device state
    /// - Parameter muteReq: Incoming mute request data
    public func handleMuteRequest(muteReq: MuteRequest, from peerId: String) {
        guard var device = MutingDevices(rawValue: muteReq.device) else { return }
        if let peerData = self.rtmLookup[peerId] as? AgoraVideoViewer.UserData,
           peerData.uikit.framework == "flutter",
           // Flutter 1.1.1 and below had camera and microphone swapped.
           "1.1.1".compare(peerData.uikit.version) != .orderedAscending,
           let newDevice = MutingDevices(rawValue: (muteReq.device + 1) % 2) {
            device = newDevice
        }
        if device == .camera, self.agoraSettings.cameraEnabled == !muteReq.mute { return }
        if device == .microphone, self.agoraSettings.micEnabled == !muteReq.mute { return }

        AgoraVideoViewer.agoraPrint(
            .error,
            message: "user \(muteReq.rtcId) (self) should \(muteReq.mute ? "" : "un")mute" +
                " their \(device.strVal) by \(muteReq.isForceful ? "force" : "request")"
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
        let alertTitle = "\(muteReq.mute ? "" : "un")mute \(device.strVal)?"
        #if os(iOS)
        let alert = UIAlertController(
            title: alertTitle, message: nil,
            preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: setDevice))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.presentAlert(alert: alert, animated: true, viewer: self)
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
