//
//  ViewController.swift
//  Agora-AppKit-Example
//
//  Created by Max Cobb on 30/11/2020.
//

import Cocoa
import AgoraUIKit_macOS

class ViewController: NSViewController {

    var agoraView: AgoraVideoViewer?
    var segmentControl: NSSegmentedControl?
    override func viewDidLoad() {
        super.viewDidLoad()

        let agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: <#Agora App ID#>,
                appToken: <#Agora Token or nil#>
            ),
            style: .floating,
            delegate: self
        )

        agoraView.fills(view: self.view)

        agoraView.join(channel: "test", as: .broadcaster)

        self.agoraView = agoraView
        self.view.setFrameSize(NSSize(width: 1440, height: 790))
    }

    @objc func segmentedControlHit(segc: NSSegmentedControl) {
        let segmentedStyle = [
            AgoraVideoViewer.Style.floating,
            AgoraVideoViewer.Style.grid
        ][segc.indexOfSelectedItem]

        self.agoraView?.style = segmentedStyle
    }

}

extension ViewController: AgoraVideoViewerDelegate {
    func joinedChannel(channel: String) {
        if self.segmentControl != nil {
            return
        }
        let newControl = NSSegmentedControl(
            labels: ["floating", "grid"], trackingMode: .selectOne, target: self,
            action: #selector(segmentedControlHit)
        )
        newControl.selectedSegment = self.agoraView?.style == .floating ? 0 : 1
        self.view.addSubview(newControl)
        newControl.translatesAutoresizingMaskIntoConstraints = false
        [
            newControl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            newControl.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10)
        ].forEach { $0.isActive = true }
    }
}
