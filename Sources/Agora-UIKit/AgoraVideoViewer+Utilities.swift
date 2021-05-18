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
        /// To use when an internal error has occurred
        case error = 0
        /// To use when something is not being used or running correctly
        case warning = 1
        /// To use for debugging issues
        case debug = 2
        /// To use when we want all the possible logs
        case verbose = 3
        var printString: String {
            switch self {
            case .verbose: return "INFO"
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
