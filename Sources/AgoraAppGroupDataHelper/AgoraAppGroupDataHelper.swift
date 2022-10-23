//
//  AppGroupDataHelper.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 21/10/2022.
//

import Foundation

/// Struct to help transferring data between App Extensions
public struct AgoraAppGroupDataHelper {
    /// Default keys for properties to make fetching easier
    public enum Keys: String {
        case appId
        case channel
        case token
        case uid
    }
    /// Set the app group to this static property to initialise ``AgoraAppGroupDataHelper``.
    static public var appGroup: String? {
        didSet {
            if let appGroup = appGroup {
                self.sharedData = UserDefaults(suiteName: appGroup)
            } else {
                self.sharedData = nil
            }
        }
    }
    /// Get only property for data shared within an app group. Set ``AgoraAppGroupDataHelper/appGroup`` to initialise this.
    static public internal(set) var sharedData: UserDefaults?

    /// Returns the string associated with the specified key.
    /// - Parameter key: A key in the current user‘s defaults database.
    /// - Returns: For string values, the string associated with the specified key; for number values, the string value of the number. Returns nil if the default does not exist or is not a string or number value.
    static public func getString(for key: Keys) -> String? {
        self.sharedData?.string(forKey: key.rawValue)
    }
    /// Sets the value of the specified default key.
    /// - Parameters:
    ///   - value: The object to store in the defaults database
    ///   - key: The key with which to associate the value.
    static public func set(_ value: Any?, forKey key: Keys) {
        self.sharedData?.set(value, forKey: key.rawValue)
    }
}
