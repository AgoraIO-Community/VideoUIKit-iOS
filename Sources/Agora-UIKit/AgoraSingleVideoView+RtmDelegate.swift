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

/// Protocol for being able to access the AgoraRtmController and presenting alerts
public protocol SingleVideoViewDelegate: AnyObject {
    /// RTM Controller class for managing RTM messages
    var rtmController: AgoraRtmController? { get set }
    #if os(iOS)
    /// presentAlert is a way to show any alerts that want to display.
    /// These could be relating to video or audio unmuting requests.
    /// - Parameters:
    ///   - alert: Alert to be displayed
    ///   - animated: Whether the presentation should be animated or not
    func presentAlert(alert: UIAlertController, animated: Bool)
    #endif
}

extension SingleVideoViewDelegate {
    #if os(iOS)
    public func presentAlert(alert: UIAlertController, animated: Bool) {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.presentAlert(alert: alert, animated: animated)
            }
            return
        }
        if let viewCont = self as? UIViewController {
            viewCont.present(alert, animated: animated)
        } else if let vidViewer = self as? AgoraVideoViewer {
            vidViewer.delegate?.presentAlert(alert: alert, animated: animated)
        }
    }
    #endif
}
