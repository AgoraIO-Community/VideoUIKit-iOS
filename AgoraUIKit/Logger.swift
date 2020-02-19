//
//  Logger.swift
//  AgoraARKit
//
//  Created by Hermes Frangoudis on 1/23/20.
//  Copyright © 2020 Agora.io. All rights reserved.
//

/**
An enum to represent the avialable levels of verbosity for logging.
 */
public enum LogLevel: Int {
    case None = 0
    case Normal = 1
    case Verbose = 2
}
/**
 The verbosity setting for the amount of logs to display.
 */
public var logLevel: LogLevel = .Normal

/**
 A simple method to accepts a log message and the verbosity level at which to print it.
 - Parameters:
     - log: A message to output in the Xcode logs
     - level: The verbosity level used to determine whether or not to show the given log based on the active _"logLevel"_
 */
public func lprint(_ log: String, _ level: LogLevel = .Normal) {
    #if DEBUG
    // If the debug level of our dprint is >= to the selected level
    if (logLevel.rawValue >= level.rawValue) {
        print("[AgoraARKit]: ", log)
    }
    #endif
}
