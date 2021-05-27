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

        var agSettings = AgoraSettings()
        agSettings.enabledButtons = [.cameraButton, .micButton, .flipButton]
        let agoraView = AgoraVideoViewer(
            connectionData: AgoraConnectionData(
                appId: <#Agora App ID#>,
                appToken: <#Agora Token or nil#>
            ),
            style: .floating,
            agoraSettings: agSettings,
            delegate: self
        )

        self.view.backgroundColor = .tertiarySystemBackground
        agoraView.fills(view: self.view)

        agoraView.join(channel: "test", as: .broadcaster)

        self.agoraView = agoraView

        self.showSegmentedView()
    }

    func showSegmentedView() {
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

extension ViewController: AgoraVideoViewerDelegate {

    func extraButtons() -> [UIButton] {
        let button = UIButton()
        button.setImage(UIImage(
            systemName: "bolt.fill",
            withConfiguration: UIImage.SymbolConfiguration(scale: .large)
        ), for: .normal)
        button.backgroundColor = .systemGray
        button.addTarget(self, action: #selector(self.clickedBolt), for: .touchUpInside)
        return [button]
    }

    @objc func clickedBolt(sender: UIButton) {
        print("zap!")
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? .systemYellow : .systemGray
    }

    func presentAlert(alert: UIAlertController, animated: Bool) {
        self.present(alert, animated: animated)
    }
}

