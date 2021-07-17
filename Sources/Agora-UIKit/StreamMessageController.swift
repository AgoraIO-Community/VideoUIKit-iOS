//
//  StreamMessageController.swift
//  AgoraUIKit_macOS
//
//  Created by Max Cobb on 14/07/2021.
//

import AgoraRtcKit

public protocol StreamMessageContainer {
    var streamController: StreamMessageController? { get set }
}

open class StreamMessageController {
    var streamID: Int
    var streamStatus: Int32 = -1
    var engine: AgoraRtcEngineKit
    init(streamID: Int, config: AgoraDataStreamConfig, engine: AgoraRtcEngineKit) {
        self.streamID = streamID
        self.engine = engine
        self.streamStatus = engine.createDataStream(&self.streamID, config: config)
    }

    public enum MutableDevices: Int, CaseIterable {
        case camera
        case microphone
    }

    public enum DecodedStream {
        case mute(uid: UInt, mute: Bool, device: MutableDevices, force: Bool)
    }

    open func sendMuteRequest(to rtcID: UInt, mute: Bool, device: MutableDevices, force: Bool = false) {
        print("mute request")
        let sendString = "uikit:mute:\(rtcID):\(mute):\(device.rawValue):\(force)"
        print(sendString)
        if let stringData = sendString.data(using: .utf8) {
            self.engine.sendStreamMessage(self.streamID, data: stringData)
        }
    }

    open func muteDataFromStream(_ splitData: [String.SubSequence]) -> DecodedStream? {
        let rtcIDStr = splitData[2]
        let deviceStr = splitData[4]
        guard let device = MutableDevices(rawValue: Int(deviceStr) ?? -1),
              let rtcID = UInt(rtcIDStr),
              let mute = Bool(String(splitData[3])),
              let force = Bool(String(splitData[5])) else {
            return nil
        }
        return .mute(uid: rtcID, mute: mute, device: device, force: force)
    }

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
