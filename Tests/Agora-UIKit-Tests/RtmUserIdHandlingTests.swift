//
//  RtmUserIdHandlingTests.swift
//  
//
//  Created by Max Cobb on 13/01/2023.
//

import XCTest
import AgoraRtcKit
@testable import AgoraUIKit

final class RtmUserIdHandlingTests: XCTestCase {

    func testNegativeUID() throws {
        let userData = AgoraVideoViewer.UserData(
            rtmId: "example-test-rtm-id", rtcId: -512,
            role: AgoraClientRole.broadcaster.rawValue
        )
        XCTAssertEqual(userData.rtcId, -512, "UserData rtcId should be -512")
        XCTAssertEqual(
            userData.iOSUInt, 4294966784,
            "UserData iOSUInt should be 4294966784"
        )
    }

    func testLargeUID() throws {
        let userData = AgoraVideoViewer.UserData(
            rtmId: "example-test-rtm-id", rtcId: 4294966784,
            role: AgoraClientRole.broadcaster.rawValue
        )
        XCTAssertEqual(
            userData.rtcId, Int(userData.iOSUInt ?? 0),
            "UserData rtcId should be the same as iOSUInt"
        )
    }
}
