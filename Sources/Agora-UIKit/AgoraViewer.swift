//
//  AgoraViewer.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 24/12/2020.
//

#if os(iOS)
import SwiftUI
import AgoraRtcKit

/// Add AgoraVideoViewer with SwiftUI
public struct AgoraViewer: UIViewRepresentable {
    public typealias UIViewType = AgoraVideoViewer

    public func makeUIView(context: Context) -> UIViewType {
        self.viewer
    }

    public func updateUIView(_ uiView: AgoraVideoViewer, context: Context) {
    }

    /// The AgoraVideoViewer for SwiftUI to show.
    public private(set) var viewer: UIViewType
    /// Style and organisation to be applied to all the videos in the AgoraVideoViewer
    public var style: AgoraVideoViewer.Style {
        get { self.viewer.style }
        set { self.viewer.style = newValue }
    }
    /// Settings and customisations such as position of on-screen buttons, collection view of all channel members, as well as agora video configuration.
    public var agoraSettings: AgoraSettings {
        self.viewer.agoraSettings
    }
    /// Delegate for the AgoraVideoViewer, used for some important callback methods.
    public var delegate: AgoraVideoViewerDelegate? {
        get { self.viewer.delegate }
        set { self.viewer.delegate = newValue }
    }

    /// Create an AgoraViewer, which represents an AgoraVideoViewer object.
    /// - Parameters:
    ///   - connectionData: Storing struct for holding data about the connection to Agora service.
    ///   - style: Style and organisation to be applied to all the videos in this AgoraVideoViewer.
    ///   - agoraSettings: Settings for this viewer. This can include style customisations and information of where to get new tokens from.
    ///   - delegate: Delegate for the AgoraVideoViewer, used for some important callback methods.
    public init(
        connectionData: AgoraConnectionData, style: AgoraVideoViewer.Style = .grid,
        agoraSettings: AgoraSettings = AgoraSettings(), delegate: AgoraVideoViewerDelegate? = nil
    ) {
        self.viewer = AgoraVideoViewer(
            connectionData: connectionData, style: style,
            agoraSettings: agoraSettings, delegate: delegate
        )
    }

    /// Join the Agora channel
    /// - Parameters:
    ///   - channel: Channel name to join.
    ///   - token: Valid token to join the channel.
    ///   - role: AgoraClientRole to join the channel as. Default: .broadcaster.
    public func join(channel: String, with token: String?, as role: AgoraClientRole) {
        self.viewer.join(channel: channel, with: token, as: role)
    }
}
#endif
