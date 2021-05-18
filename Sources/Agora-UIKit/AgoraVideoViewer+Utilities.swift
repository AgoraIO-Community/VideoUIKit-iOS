//
//  AgoraVideoViewer+Utilities.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 27/11/2020.
//

import Foundation

public extension AgoraVideoViewer {
    /// Print level that will be visible in the developer console, default `.error`
    static var printLevel: PrintType = .warning
    /// Level for an internal print statement
    enum PrintType: Int {
        case error = 0
        case warning = 1
        case debug = 2
        case info = 3
        var printString: String {
            switch self {
            case .info: return "INFO"
            case .debug: return "DEBUG"
            case .warning: return "WARNING"
            case .error: return "ERROR"
            }
        }
    }
    internal static func agoraPrint(_ tag: PrintType, message: Any) {
        #if DEBUG
        if tag.rawValue <= AgoraVideoViewer.printLevel.rawValue {
            print("[AgoraVideoViewer \(tag.printString)]: \(message)")
        }
        #endif
    }
}
