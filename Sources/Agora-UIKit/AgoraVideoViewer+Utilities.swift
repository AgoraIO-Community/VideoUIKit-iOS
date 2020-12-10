//
//  AgoraVideoViewer+Utilities.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 27/11/2020.
//

import Foundation

internal extension AgoraVideoViewer {
    enum PrintType: String {
        case info = "INFO"
        case debug = "DEBUG"
        case error = "ERROR"
    }
    static func agoraPrint(_ tag: PrintType, message: Any) {
        #if DEBUG
        print("[AgoraVideoViewer \(tag.rawValue)]: \(message)")
        #endif
    }
}
