//
//  AgoraVideoViewer+Utilities.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 27/11/2020.
//

import Foundation

extension AgoraVideoViewer {
    /// Print level that will be visible in the developer console, default `.error`
    static var printLevel: PrintType = .error
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
        if tag.rawValue <= AgoraVideoViewer.printLevel.rawValue {
            print("[AgoraVideoViewer \(tag.printString)]: \(message)")
        }
    }

    /// Helper method to fill a view with this view
    /// - Parameter view: view to fill with self
    open func fills(view: MPView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
        self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        #else
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        #endif
    }
}
