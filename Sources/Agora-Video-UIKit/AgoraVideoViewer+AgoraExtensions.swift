//
//  AgoraVideoViewer+AgoraExtensions.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 09/09/2021.
//

import AgoraRtcKit

extension AgoraVideoViewer {
    /// Enable/Disable extension. No different from the Agora SDK call.
    /// - Parameters:
    ///   - vendor: name for provider, e.g. agora.builtin.
    ///   - extension: name for extension, e.g. agora.beauty.
    ///   - enabled: enable or disable. - true: enable. - false: disable.
    /// - Returns: `0`: Success. `<0`: Failure.
    @discardableResult
    @objc open func enableExtension(withVendor vendor: String, extension extString: String, enabled: Bool) -> Int32 {
        return self.agkit.enableExtension(withVendor: vendor, extension: extString, enabled: enabled)
    }

    /// Set extension specific property. This method passes all properties without making any changes.
    /// - Parameters:
    ///   - vendor: name for provider, e.g. agora.builtin.
    ///   - extension: name for extension, e.g. agora.beauty.
    ///   - key: key for the property.
    ///   - value: string value to set.
    /// - Returns: `0` = Success. `<0` = Failure.
    @discardableResult
    @objc open func setExtensionProperty(
        _ vendor: String, extension extString: String, key: String, value: String
    ) -> Int32 {
        return self.agkit.setExtensionPropertyWithVendor(
            vendor, extension: extString, key: key,
            value: value
        )
    }

    /// Set extension specific property. Property value is a string and will be wrapped in quoatation marks
    /// - Parameters:
    ///   - vendor: name for provider, e.g. agora.builtin.
    ///   - extension: name for extension, e.g. agora.beauty.
    ///   - key: key for the property.
    ///   - codable: value to set for the property, must be encodable to a JSON string.
    /// - Returns: `0` = Success. `<0` = Failure.
    @discardableResult
    public func setExtensionProperty<T>(
        _ vendor: String, extension extString: String, key: String, codable: T
    ) -> Int32? where T: Encodable {
        guard let encodedData = try? JSONEncoder().encode(codable),
              let dataString = String(data: encodedData, encoding: .utf8)  else {
            return nil
        }

        return self.agkit.setExtensionPropertyWithVendor(
            vendor, extension: extString, key: key,
            value: dataString
        )
    }

    /// Set extension specific property. Property value is a string and will be wrapped in quoatation marks
    /// - Parameters:
    ///   - vendor: name for provider, e.g. agora.builtin.
    ///   - extension: name for extension, e.g. agora.beauty.
    ///   - key: key for the property.
    ///   - strValue: string value to set.
    /// - Returns: `0` = Success. `<0` = Failure.
    @discardableResult
    @objc open func setExtensionProperty(
        _ vendor: String, extension extString: String, key: String, strValue: String
    ) -> Int32 {
        return self.agkit.setExtensionPropertyWithVendor(
            vendor, extension: extString, key: key,
            value: "\"\(strValue)\""
        )
    }

    /// Set extension specific property. Property value is a string and will be wrapped in quoatation marks
    /// - Parameters:
    ///   - vendor: name for provider, e.g. agora.builtin.
    ///   - extension: name for extension, e.g. agora.beauty.
    ///   - key: key for the property.
    ///   - value: Boolean value to set.
    /// - Returns: `0` = Success. `<0` = Failure.
    @discardableResult
    public func setExtensionProperty(
        _ vendor: String, extension extString: String, key: String, value: Bool
    ) -> Int32 {
        return self.agkit.setExtensionPropertyWithVendor(
            vendor, extension: extString, key: key,
            value: value.description
        )
    }
}
