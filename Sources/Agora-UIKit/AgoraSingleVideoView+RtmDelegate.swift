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
    func userLabel() -> MPTextView?
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
    public func userLabel() -> MPTextView? {
        if let vidViewer = self as? AgoraVideoViewer {
            if vidViewer.agSettings.userLabelStyle != [] {
                let textView = MPTextView()
                #if os(iOS)
                textView.textContainerInset = .init(
                    top: 2, left: 1, bottom: 2, right: 1
                )
                textView.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.2)
                textView.textColor = .label
                textView.autoresizingMask = [
                    .flexibleRightMargin, .flexibleBottomMargin
                ]
                #else
                textView.textContainerInset = .init(width: 1, height: 4)
                textView.backgroundColor = .clear
                textView.textColor = .lightGray
                textView.autoresizingMask = [.maxXMargin, .minYMargin]
                #endif
                return textView
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
    public func getUserLabelContent(for uid: UInt, channel: String) -> String? {
        var rtnString = ""
        guard let rtmController = self.rtmController else {
            return nil
        }
        if rtmController.agoraSettings.userLabelStyle.contains(.username),
           let rtmId = self.rtmController?.rtcLookup[uid],
           let rtmUsername = self.rtmController?.rtmLookup[rtmId]?.username {
            rtnString = rtmUsername
        }
        return rtnString.isEmpty ? nil : rtnString
    }
}
