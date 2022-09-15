import XCTest
import AgoraRtcKit
#if canImport(AgoraRtmController) && canImport(AgoraUIKit_iOS)
import AgoraRtmKit
import AgoraRtmController
@testable import AgoraUIKit_iOS

final class RtmMessagesTests: XCTestCase {
    func testEncodeMuteReq() throws {
        let muteReq = AgoraVideoViewer.MuteRequest(
            rtcId: 999, mute: true, device: .camera, isForceful: true
        )
        guard let rawMsg = AgoraRtmController.createRtmMessage(from: muteReq) else {
            return XCTFail("MuteRequest should be encodable")
        }
        XCTAssert(rawMsg.text == "AgoraUIKit", "Message text data should be AgoraUIKit")
        let msgText = String(data: rawMsg.rawData, encoding: .utf8)

        guard let unencodedJSON = try? JSONSerialization.jsonObject(
            with: rawMsg.rawData, options: .allowFragments
        ) as? [String: Any] else {
            return XCTFail("Could not unencode data")
        }
        XCTAssertEqual((unencodedJSON["rtcId"] as? UInt), muteReq.rtcId, "rtcId invalid!")
        XCTAssertEqual((unencodedJSON["mute"] as? Bool), muteReq.mute, "mute invalid!")
        XCTAssertEqual((unencodedJSON["device"] as? Int), muteReq.device, "device invalid!")
        XCTAssertEqual((unencodedJSON["isForceful"] as? Bool), muteReq.isForceful, "mute invalid!")
        let msgTextValid = "{\"rtcId\":999,\"mute\":true,\"messageType\":"
                        + "\"MuteRequest\",\"device\":0,\"isForceful\":true}"

        XCTAssertEqual(msgText, msgTextValid, "Message text not matching mstTextValid")
        guard let decodedMsg = AgoraVideoViewer.decodeRtmData(
                data: rawMsg.rawData, from: ""
        ) else {
            return XCTFail("Failed to decode message")
        }

        switch decodedMsg {
        case .mute(let decodedMuteReq):
            XCTAssertEqual(decodedMuteReq.rtcId, muteReq.rtcId, "rtcId invalid!")
            XCTAssertEqual(decodedMuteReq.mute, muteReq.mute, "mute invalid!")
            XCTAssertEqual(decodedMuteReq.device, muteReq.device, "device invalid!")
            XCTAssertEqual(decodedMuteReq.isForceful, muteReq.isForceful, "mute invalid!")
        case .userData:
            XCTFail("Should not decode to userData")
        case .dataRequest:
            XCTFail("Should not decode to dataRequest")
        }
    }

    func testEncodeUserData() throws {
        let userData = AgoraVideoViewer.UserData(
            rtmId: "1234-5678", rtcId: 190, username: "username",
            role: AgoraClientRole.broadcaster.rawValue, agora: .current, uikit: .current
        )
        guard let rawMsg = AgoraRtmController.createRtmMessage(from: userData) else {
            return XCTFail("UserData should be encodable")
        }
        XCTAssert(rawMsg.text == "AgoraUIKit", "Message text data should be AgoraUIKit")
        let msgText = String(data: rawMsg.rawData, encoding: .utf8)

        guard let unencodedJSON = try? JSONSerialization.jsonObject(
            with: rawMsg.rawData, options: .allowFragments
        ) as? [String: Any] else {
            return XCTFail("Could not unencode data")
        }
        XCTAssertEqual((unencodedJSON["rtcId"] as? UInt), userData.rtcId, "rtcId invalid!")
        XCTAssertEqual((unencodedJSON["role"] as? Int), userData.role, "mute invalid!")
        XCTAssertEqual((unencodedJSON["username"] as? String), userData.username, "device invalid!")
        if let agoraData = unencodedJSON["agora"] as? [String: Any] {
            XCTAssertEqual((agoraData["rtc"] as? String), AgoraRtcEngineKit.getSdkVersion(), "rtcId invalid!")
            XCTAssertEqual((agoraData["rtm"] as? String), AgoraRtmKit.getSDKVersion(), "mute invalid!")
        } else { XCTFail("Could not parse agora version data") }
        let msgTextValid = "{\"uikit\":{"
                        + "\"platform\":\"ios\",\"version\":\"\(AgoraUIKit.version)\",\"framework\":\"native\"},"
                        + "\"role\":1,\"rtmId\":\"1234-5678\",\"username\":\"username\",\"agora\":{\"rtm\":"
                        + "\"\(AgoraRtmKit.getSDKVersion()!)\",\"rtc\":\"\(AgoraRtcEngineKit.getSdkVersion())\"},"
                        + "\"messageType\":\"UserData\",\"rtcId\":190}"

        XCTAssertEqual(msgText, msgTextValid, "Message text not matching msgTextValid")
        guard let decodedMsg = AgoraVideoViewer.decodeRtmData(data: rawMsg.rawData, from: "") else {
            return XCTFail("Failed to decode message")
        }

        switch decodedMsg {
        case .userData(let decodedUserData):
            XCTAssertEqual(decodedUserData.rtcId, userData.rtcId, "rtcId invalid!")
            XCTAssertEqual(decodedUserData.rtmId, userData.rtmId, "rtmId invalid!")
            XCTAssertEqual(decodedUserData.agora.rtc, AgoraRtcEngineKit.getSdkVersion(), "RTC version invalid!")
            XCTAssertEqual(decodedUserData.uikit.framework, "native", "RTC version invalid!")
        default:
            XCTFail("Should decode to userData")
        }
    }

    func testEncodeUserData() throws {
        let userData = AgoraRtmController.UserData(
            rtmId: "1234-5678", rtcId: 190, username: "username",
            role: AgoraClientRole.broadcaster.rawValue, agora: .current, uikit: .current
        )
        guard let rawMsg = AgoraRtmController.createRawRtm(from: userData) else {
            return XCTFail("UserData should be encodable")
        }
        XCTAssert(rawMsg.text == "AgoraUIKit", "Message text data should be AgoraUIKit")
        let msgText = String(data: rawMsg.rawData, encoding: .utf8)

        guard let unencodedJSON = try? JSONSerialization.jsonObject(
            with: rawMsg.rawData, options: .allowFragments
        ) as? [String: Any] else {
            return XCTFail("Could not unencode data")
        }
        XCTAssertEqual((unencodedJSON["rtcId"] as? UInt), userData.rtcId, "rtcId invalid!")
        XCTAssertEqual((unencodedJSON["role"] as? Int), userData.role, "mute invalid!")
        XCTAssertEqual((unencodedJSON["username"] as? String), userData.username, "device invalid!")
        if let agoraData = unencodedJSON["agora"] as? [String: Any] {
            XCTAssertEqual((agoraData["rtc"] as? String), AgoraRtcEngineKit.getSdkVersion(), "rtcId invalid!")
            XCTAssertEqual((agoraData["rtm"] as? String), AgoraRtmKit.getSDKVersion(), "mute invalid!")
        } else { XCTFail("Could not parse agora version data") }
        let msgTextValid = "{\"uikit\":{"
                        + "\"platform\":\"ios\",\"version\":\"\(AgoraUIKit.version)\",\"framework\":\"native\"},"
                        + "\"role\":1,\"rtmId\":\"1234-5678\",\"username\":\"username\",\"agora\":{\"rtm\":"
                        + "\"\(AgoraRtmKit.getSDKVersion()!)\",\"rtc\":\"\(AgoraRtcEngineKit.getSdkVersion())\"},"
                        + "\"messageType\":\"UserData\",\"rtcId\":190}"

        XCTAssertEqual(msgText, msgTextValid, "Message text not matching msgTextValid")
        guard let decodedMsg = AgoraRtmController.decodeRawRtmData(data: rawMsg.rawData, from: "") else {
            return XCTFail("Failed to decode message")
        }

        switch decodedMsg {
        case .userData(let decodedUserData):
            XCTAssertEqual(decodedUserData.rtcId, userData.rtcId, "rtcId invalid!")
            XCTAssertEqual(decodedUserData.rtmId, userData.rtmId, "rtmId invalid!")
            XCTAssertEqual(decodedUserData.agora.rtc, AgoraRtcEngineKit.getSdkVersion(), "RTC version invalid!")
            XCTAssertEqual(decodedUserData.uikit.framework, "native", "RTC version invalid!")
        default:
            XCTFail("Should decode to userData")
        }
    }
}
#endif
