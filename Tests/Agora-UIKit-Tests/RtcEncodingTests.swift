//
//  RtcEncodingTests.swift
//  
//
//  Created by Max Cobb on 04/08/2021.
//

import XCTest
@testable import AgoraUIKit_iOS

final class RtcEncodingTests: XCTestCase {
    func testRtmToRtc() throws {
        let rtmValidUDID = "71ED0EF6-96E5-43D0-9F40-BAA31BB37F67"
        let encodedUDIDCorrect: UInt = 940313767
        let encodedUDID = AgoraConnectionData.uidFrom(vendor: rtmValidUDID)
        XCTAssertEqual(encodedUDID, encodedUDIDCorrect, "UDID did not encode correctly: \(encodedUDID)")

        let zeroesUDID = "71ED0EF6-00E0-11D0-0F00-BAA00BB00F67"
        let encodedZeroesUDID = AgoraConnectionData.uidFrom(vendor: zeroesUDID)
        let encodedZerosCorrect: UInt = 7161167
        XCTAssertEqual(encodedZeroesUDID, encodedZerosCorrect, "UDID did not encode correctly: \(encodedZeroesUDID)")

        let asciiUDID = "01ED0EF6-00E0-00D0-0F00-BAA00BB00F00"
        let encodedAsciiUDID = AgoraConnectionData.uidFrom(vendor: asciiUDID)
        let encodedAsciiUDIDCorrect: UInt = 89988904
        XCTAssertEqual(encodedAsciiUDID, encodedAsciiUDIDCorrect, "UDID did not encode correctly: \(encodedAsciiUDID)")

        // ASCII code for "F" is 70, mod 10 is 0, "FFF..." gives 0
        let effsTest = "FFFFFFFF"
        let encodedeffsTest = AgoraConnectionData.uidFrom(vendor: effsTest)
        let encodedeffsTestCorrect: UInt = 0
        XCTAssertEqual(encodedeffsTest, encodedeffsTestCorrect, "UDID did not encode correctly: \(encodedeffsTest)")
    }
}
