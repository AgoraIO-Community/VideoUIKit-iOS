//
//  StreamMessageController.swift
//  AgoraUIKit_macOS
//
//  Created by Max Cobb on 14/07/2021.
//

import AgoraRtcKit

/// Protocol for being able to access the StreamMessageController and presenting alerts
public protocol StreamMessageContainer {
    /// Stream Controller class for managing stream messages
    var streamController: StreamMessageController? { get set }
    /// presentAlert is a way to show any alerts that want to display.
    /// These could be relating to video or audio unmuting requests.
    /// - Parameters:
    ///   - alert: Alert to be displayed
    ///   - animated: Whether the presentation should be animated or not
    func presentAlert(alert: UIAlertController, animated: Bool)
}

extension StreamMessageContainer {
    public func presentAlert(alert: UIAlertController, animated: Bool) {
        if self is UIViewController {
            (self as! UIViewController).present(alert, animated: animated)
        } else if self is AgoraVideoViewer {
            (self as! AgoraVideoViewer).delegate?.presentAlert(alert: alert, animated: animated)
        }
    }
}

/// Class for controlling the stream messages
open class StreamMessageController: NSObject {
    var streamID: Int
    var streamStatus: Int32 = -1
    var engine: AgoraRtcEngineKit
    init(streamID: Int, config: AgoraDataStreamConfig, engine: AgoraRtcEngineKit) {
        self.streamID = streamID
        self.engine = engine
        self.streamStatus = engine.createDataStream(&self.streamID, config: config)
    }

    /// Devices that can be muted/unmuted
    public enum MutingDevices: Int, CaseIterable {
        /// The device camera
        case camera
        /// The device microphone
        case microphone
    }

    /// Type of decoded stream coming from other users
    public enum DecodedStream {
        /// Mute is when a user is requesting another user to mute or unmute a device
        case mute(uid: UInt, mute: Bool, device: MutingDevices, isForceful: Bool)
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
    ///   - rtcID: RTC User ID to send the request to
    ///   - mute: Whether the device should be muted or unmuted
    ///   - device: Type of device (camera/microphone)
    ///   - isForceful: Whether the request should force its way through, otherwise a request is made
    open func sendMuteRequest(to rtcID: UInt, mute: Bool, device: MutingDevices, isForceful: Bool = false) {
        let sendString = "uikit:mute:\(rtcID):\(mute):\(device.rawValue):\(isForceful)"
        if let stringData = sendString.data(using: .utf8) {
            self.engine.sendStreamMessage(self.streamID, data: stringData)
        }
    }

    /// Turn split data stream string into a mute enum
    /// - Parameter splitData: Split string that contains the data
    /// - Returns: An instance of DecodedStream.mute containing the decoded data from input string array
    open func muteDataFromStream(_ splitData: [String.SubSequence]) -> DecodedStream? {
        let rtcIDStr = splitData[2]
        let deviceStr = splitData[4]
        guard let device = MutingDevices(rawValue: Int(deviceStr) ?? -1),
              let rtcID = UInt(rtcIDStr),
              let mute = Bool(String(splitData[3])),
              let force = Bool(String(splitData[5])) else {
            return nil
        }
        return .mute(uid: rtcID, mute: mute, device: device, isForceful: force)
    }

    /// Decode the incoming data stream to a DecodedStream enum
    /// - Parameters:
    ///   - data: Data direct from the incoming streamData
    ///   - uid: User ID that sent the request
    /// - Returns: Optional DecodedStream instance
    open func decodeStream(data: Data, from uid: UInt) -> DecodedStream? {
        guard let dataStr = String(data: data, encoding: .utf8) else {
            return nil
        }
        let splitData = dataStr.split(separator: ":")
        if splitData.count < 2 || splitData[0] != "uikit" {
            return nil
        }
        switch splitData[1] {
        case "mute":
            return muteDataFromStream(splitData)
        default:
            return nil
        }
    }
}
