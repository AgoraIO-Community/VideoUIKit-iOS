//
//  AgoraSingleVideoView+RtmDelegate.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 05/08/2021.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(AgoraRtmControl)
import AgoraRtmControl
#endif

/// Protocol for being able to access the AgoraRtmController and presenting alerts
public protocol SingleVideoViewDelegate: AnyObject {
    #if canImport(AgoraRtmControl)
    /// RTM Controller class for managing RTM messages
    var rtmController: AgoraRtmController? { get set }
    func createRequest(
        to uid: UInt,
        fromString str: String
    ) -> Bool
    func sendMuteRequest(to rtcId: UInt, mute: Bool, device: AgoraVideoViewer.MutingDevices, isForceful: Bool)

    #endif
    #if os(iOS)
    /// presentAlert is a way to show any alerts that want to display.
    /// These could be relating to video or audio unmuting requests.
    /// - Parameters:
    ///   - alert: Alert to be displayed
    ///   - animated: Whether the presentation should be animated or not
    func presentAlert(alert: UIAlertController, animated: Bool, viewer: UIView?)
    #endif
}

extension SingleVideoViewDelegate {
    #if os(iOS)
    public func presentAlert(alert: UIAlertController, animated: Bool, viewer: UIView?) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.presentAlert(alert: alert, animated: animated, viewer: viewer)
            }
            return
        }

        if let viewCont = self as? UIViewController {
            if let presenter = alert.popoverPresentationController, let viewer = viewer {
                presenter.sourceView = viewer
                presenter.sourceRect = viewer.bounds
            }
            viewCont.present(alert, animated: animated)
        } else if let vidViewer = self as? AgoraVideoViewer {
            vidViewer.delegate?.presentAlert(alert: alert, animated: animated, viewer: viewer)
        } else {
            AgoraVideoViewer.agoraPrint(.error, message: "Could not present popup")
        }
    }
    #endif
}
