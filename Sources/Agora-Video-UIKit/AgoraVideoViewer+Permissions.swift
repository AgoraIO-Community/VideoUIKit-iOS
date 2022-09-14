//
//  AgoraVideoViewer+Permissions.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

// This file just contains some helper functions for requesting
// Camera + Microphone permissions.

import AVFoundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension AgoraVideoViewer {
    /// Helper function to check if we currently have permission to use the camera and microphone
    /// - Parameters:
    ///   - requiredMediaTypes: Array of media devices required by the permissions (camera and microphone usually)
    ///   - alsoRequest: True if we want to also request permission, false if we just want
    ///                  the current permission (default true)
    ///   - callback: Method to call once the requests have been made - if alsoRequest set to true.
    /// - Returns: True if camera and microphone are authorised.
    public func checkForPermissions(
        _ requiredMediaTypes: [AVMediaType],
        alsoRequest: Bool = true,
        callback: ((Error?) -> Void)? = nil
    ) -> Bool {
        for mediaType in requiredMediaTypes where !self.checkPermissions(
            mediaType: mediaType, alsoRequest: alsoRequest, callback: callback
        ) {
            return false
        }
        return true
    }

    internal func checkPermissions(
        mediaType: AVMediaType,
        alsoRequest: Bool = true,
        callback: ((Error?) -> Void)? = nil
    ) -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized: break
        case .notDetermined:
            if alsoRequest {
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    if granted {
                        callback?(nil)
                    } else {
                        AgoraVideoViewer.errorVibe()
                        callback?(PermissionError.permissionDenied)
                    }
                }
            }
            return false
        default:
            if alsoRequest {
                cameraMicSettingsPopup { AgoraVideoViewer.goToSettingsPage() }
            }
            return false
        }
        return true
    }
    /// Error that may come back due to permissions failing
    public enum PermissionError: Error {
        /// User just refused permissions after Apple's popup
        case permissionDenied
        /// User has refused the permissions before
        case permissionAlreadyDenied
        /// User has not yet granted or refused permissions
        case notDetermined
    }

    /// Head to the device security page.
    static func goToSettingsPage() {
        #if os(iOS)
        UIApplication.shared.open(
            URL(string: UIApplication.openSettingsURLString)!,
            options: [:]
        )
        #elseif os(macOS)
        NSWorkspace.shared.open(
            URL(fileURLWithPath: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")
        )
        #endif
    }

    /// If using iOS, creates haptic feedback signaling an error occurred.
    static func errorVibe() {
        #if os(iOS)
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(.error)
        #endif
    }

    /// Show popup before system asks for permissions for microphone and camera.
    /// - Parameter successHandler: Completion block called only if the user accepts the popup.
    func cameraMicSettingsPopup(successHandler: @escaping () -> Void) {
        #if os(iOS)
        if self.delegate?.presentAlert == nil {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not present popup")
            // just assume the user accepted this popup and move on
            successHandler()
            return
        }
        let alertView = UIAlertController(
            title: "Camera and Microphone",
            message: "To become a host, you must enable the microphone and camera",
            preferredStyle: .alert
        )
        alertView.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { _ in
            AgoraVideoViewer.errorVibe()
        }))
        alertView.addAction(UIAlertAction(title: "Give Access", style: .default, handler: { _ in
            successHandler()
        }))
        DispatchQueue.main.async {
            self.delegate?.presentAlert(alert: alertView, animated: true, viewer: self)
        }
        #elseif os(macOS)
        let alertView = NSAlert()
        alertView.messageText = "Camera and Microphone"
        alertView.informativeText = "To become a host, you must enable the microphone and camera"
        alertView.addButton(withTitle: "OK")
        alertView.addButton(withTitle: "Cancel")
        let res = alertView.runModal()
        if res == .alertSecondButtonReturn {
            successHandler()
        } else {
            AgoraVideoViewer.errorVibe()
        }
        #endif
    }
}
