//
//  AgoraVideoViewer+Permissions.swift
//  Agora-UIKit
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
    ///   - alsoRequest: True if we want to also request permission, false if we just want
    ///                  the current permission (default true)
    ///   - callback: Method to call once the requests have been made - if alsoRequest set to true.
    /// - Returns: True if camera and microphone are authorised.
    public func checkForPermissions(alsoRequest: Bool = true, callback: (() -> Void)? = nil) -> Bool {
        if !self.checkCameraPermissions(alsoRequest: alsoRequest, callback: callback) ||
            !self.checkMicPermissions(alsoRequest: alsoRequest, callback: callback) {
            return false
        }
        return true
    }

    func checkMicPermissions(alsoRequest: Bool = true, callback: (() -> Void)? = nil) -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: break
        case .notDetermined:
            if alsoRequest {
                AgoraVideoViewer.requestMicrophoneAccess { success in
                    if success {
                        callback?()
                    } else {
                        AgoraVideoViewer.errorVibe()
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

    func checkCameraPermissions(alsoRequest: Bool = true, callback: (() -> Void)? = nil) -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: break
        case .notDetermined:
            if alsoRequest {
                AgoraVideoViewer.requestCameraAccess { success in
                    if success {
                        callback?()
                    } else {
                        AgoraVideoViewer.errorVibe()
                    }
                }
            }
            return false
        default:
            if alsoRequest {
                cameraMicSettingsPopup {
                    AgoraVideoViewer.goToSettingsPage()
                }
            }
            return false
        }
        return true
    }

    /// Request access to use the camera.
    /// - Parameter handler: A block to be called once permission is granted or denied.
    public static func requestCameraAccess(handler: ((Bool) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            handler?(granted)
        }
    }

    /// Request access to use the microphone.
    /// - Parameter handler: A block to be called once permission is granted or denied.
    public static func requestMicrophoneAccess(handler: ((Bool) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            handler?(granted)
        }
    }

    /// Head to the device security page.
    static func goToSettingsPage() {
        #if os(iOS)
        UIApplication.shared.open(
            URL(string: UIApplication.openSettingsURLString)!,
            options: [:]
        )
        #else
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
            AgoraVideoViewer.agoraPrint(.error, message: "Could not present settings popup")
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
            self.delegate?.presentAlert?(alert: alertView, animated: true)
        }
        #else
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
