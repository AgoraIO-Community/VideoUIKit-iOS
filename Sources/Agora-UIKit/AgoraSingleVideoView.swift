//
//  AgoraSingleVideoView.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import AgoraRtcKit

public class AgoraSingleVideoView: MPView {
    var videoMuted: Bool = true {
        didSet {
            if oldValue != videoMuted {
                self.canvas.view?.isHidden = videoMuted
            }
        }
    }
    var audioMuted: Bool = true {
        didSet {
            self.mutedFlag.isHidden = !audioMuted
        }
    }
    var uid: UInt {
        get { self.canvas.uid }
        set { self.canvas.uid = newValue }
    }
    var canvas: AgoraRtcVideoCanvas
    var hostingView: MPView? {
        self.canvas.view
    }
    lazy var mutedFlag: MPView = {
        #if os(iOS)
        let muteFlag = MPButton(type: .custom)
        muteFlag.setImage(MPImage(systemName: MPButton.micSlashSymbol, withConfiguration: MPImage.SymbolConfiguration(scale: .large)), for: .normal)
        #else
        let muteFlag = MPButton()
        muteFlag.title = MPButton.micSlashSymbol
        #endif
        self.addSubview(muteFlag)
        muteFlag.frame = CGRect(origin: CGPoint(x: self.frame.width - 50, y: self.frame.height - 50), size: CGSize(width: 50, height: 50))
        #if os(iOS)
        muteFlag.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        #else
        muteFlag.autoresizingMask = [.maxYMargin, .minXMargin]
        #endif
        return muteFlag
    }()

    init(uid: UInt) {
        self.canvas = AgoraRtcVideoCanvas()
        super.init(frame: .zero)
        self.setBackground()
        self.canvas.uid = uid
        let hostingView = MPView()
        hostingView.frame = self.bounds
        #if os(macOS)
        hostingView.autoresizingMask = [.width, .height]
        #else
        hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        self.canvas.view = hostingView
        self.addSubview(hostingView)
        self.canvas.renderMode = .fit
        self.setupMutedFlag()
    }

    private func setupMutedFlag() {
        self.audioMuted = true
    }

    func setBackground() {
        let backgroundView = MPView()
        #if os(iOS)
        backgroundView.backgroundColor = .secondarySystemBackground
        let bgButton = MPButton(type: .custom)
        bgButton.setImage(
            UIImage(
                systemName: MPButton.personSymbol,
                withConfiguration: UIImage.SymbolConfiguration(scale: .large)),
            for: .normal
        )
        #else
        backgroundView.wantsLayer = true
        backgroundView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let bgButton = MPButton()
        bgButton.title = MPButton.personSymbol
        bgButton.isBordered = false
        bgButton.isEnabled = false
        #endif
        backgroundView.addSubview(bgButton)

        bgButton.frame = backgroundView.bounds
        self.addSubview(backgroundView)
        backgroundView.frame = self.bounds
        #if os(iOS)
        bgButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #else
        bgButton.autoresizingMask = [.width, .height]
        backgroundView.autoresizingMask = [.width, .height]
        #endif
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
