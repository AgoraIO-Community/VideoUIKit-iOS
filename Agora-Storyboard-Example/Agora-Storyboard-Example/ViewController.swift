//
//  ViewController.swift
//  Agora-Storyboard-Example
//
//  Created by Max Cobb on 18/05/2021.
//

import UIKit
import AgoraUIKit_iOS

class ViewController: UIViewController {

    @IBOutlet weak var videoView: AgoraVideoViewer!
    @IBOutlet weak var styleToggle: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.join(channel: "test", as: .broadcaster)

        self.styleChange(self.styleToggle)
        self.view.bringSubviewToFront(self.styleToggle)
    }

    @IBAction func styleChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.videoView.style = .floating
        } else {
            self.videoView.style = .grid
        }
    }
}

