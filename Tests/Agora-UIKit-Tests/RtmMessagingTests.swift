import XCTest
@testable import AgoraUIKit_iOS

final class RtmMessagesTests: XCTestCase {
    func testEncodeMuteReq() throws {
        let muteReq = AgoraRtmController.MuteRequest(
            rtcId: 999, mute: true, device: .camera, isForceful: true
        )
        guard let rawMsg = AgoraRtmController.createRawRtm(from: muteReq) else {
            XCTFail("MuteRequest should be encodable")
            return
        }
        XCTAssert(rawMsg.text == "AgoraUIKit", "Message text data should be AgoraUIKit")
        let msgText = String(data: rawMsg.rawData, encoding: .utf8)

        let unencodedJSON = try! JSONSerialization.jsonObject(
            with: rawMsg.rawData, options: .allowFragments
        ) as? Dictionary<String, Any>
        XCTAssert((unencodedJSON?["rtcId"] as! UInt) == muteReq.rtcId, "rtcId invalid!")
        XCTAssert((unencodedJSON?["mute"] as! Bool) == muteReq.mute, "mute invalid!")
        XCTAssert((unencodedJSON?["device"] as! Int) == muteReq.device, "device invalid!")
        XCTAssert((unencodedJSON?["isForceful"] as! Bool) == muteReq.isForceful, "mute invalid!")
        let msgTextValid = "{\"rtcId\":999,\"mute\":true,\"device\":0,\"isForceful\":true}"

        XCTAssertEqual(msgText, msgTextValid, "Message text not matching mstTextValid")
        guard let decodedMsg = AgoraRtmController.decodeRawRtmData(
                data: rawMsg.rawData, from: ""
        ) else {
            XCTFail("Failed to decode message")
            return
        }

        switch decodedMsg {
        case .userData(_):
            XCTFail("Should not decode to userData")
        case .mute(let decodedMuteReq):
            XCTAssert(decodedMuteReq.rtcId == muteReq.rtcId, "rtcId invalid!")
            XCTAssert(decodedMuteReq.mute == muteReq.mute, "mute invalid!")
            XCTAssert(decodedMuteReq.device == muteReq.device, "device invalid!")
            XCTAssert(decodedMuteReq.isForceful == muteReq.isForceful, "mute invalid!")
        }
    }
}
