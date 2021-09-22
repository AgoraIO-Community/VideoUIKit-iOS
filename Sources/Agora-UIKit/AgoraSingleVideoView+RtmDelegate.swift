//
//  AgoraSingleVideoView+RtmDelegate.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 05/08/2021.
//

#if os(iOS)
import UIKit
#else
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
    func usernameLabel() -> MPLabel?
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
    public func usernameLabel() -> MPLabel? {
        if let vidViewer = self as? AgoraVideoViewer {
            switch vidViewer.agSettings.userLabelStyle {
            case .none:
                return nil
            case .username:
                return UILabel()
            }
        }
        return nil
    }
    public func usernamePosition() -> (
        vAlign: AgoraSettings.VerticalAlign, hAlign: AgoraSettings.HorizontalAlign
    ) {
        if let vidViewer = self as? AgoraVideoViewer {
            return vidViewer.agSettings.userLabelPosition
        }
        return (.bottom, .left)
    }
    public func getUsername(for uid: UInt, channel: String) -> String? {
        guard let rtmId = self.rtmController?.rtcLookup[uid],
              let rtmUsername = self.rtmController?.rtmLookup[rtmId]?.username
        else { return nil }
        return rtmUsername
    }
}
