//
//  ViewController.swift
//  Agora-UIKit-Example
//
//  Created by Max Cobb on 26/11/2020.
//

import UIKit

import AgoraUIKit_iOS

class ViewController: UIViewController {

    var agoraView: AgoraVideoViewer?
    override func viewDidLoad() {
        super.viewDidLoad()

        let agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: "cff7258e55c24d0f99bbf93d10367d5f",
                appToken: nil
            ),
            viewController: self,
            style: .floating
        )

        self.view.backgroundColor = .tertiarySystemBackground
        agoraView.fills(view: self.view)

        agoraView.join(channel: "test")

        self.agoraView = agoraView

        let segControl = UISegmentedControl(items: ["floating", "grid"])
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: #selector(segmentedControlHit), for: .valueChanged)
        self.view.addSubview(segControl)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        [
            segControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segControl.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10)
        ].forEach { $0.isActive = true }
        self.view.bringSubviewToFront(segControl)
    }

    @objc func segmentedControlHit(segc: UISegmentedControl) {
        print(segc)
        let segmentedStyle = [
            AgoraVideoViewer.Style.floating,
            AgoraVideoViewer.Style.grid
        ][segc.selectedSegmentIndex]
        self.agoraView?.style = segmentedStyle
    }

}

