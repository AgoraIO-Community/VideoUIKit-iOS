//
//  VideoControlView.swift
//  AgoraUIKit
//
//  Created by Jonathan  Fotland on 4/16/20.
//  Copyright © 2020 Jonathan Fotland. All rights reserved.
//

import UIKit

public protocol VideoControlViewDelegate: NSObject {
    func muteButtonPressed()
    func toggleVideoButtonPressed()
    func hangUpButtonPressed()
    func switchCameraButtonPressed()
}

@IBDesignable
open class VideoControlView: UIView {

    @IBOutlet weak var muteButton: ToggleButton!
    @IBOutlet weak var hangUpButton: UIButton!
    @IBOutlet weak var toggleVideoButton: ToggleButton!
    @IBOutlet weak var switchCameraButton: ToggleButton!
    
    public weak var delegate: VideoControlViewDelegate?
    
    public func setupControls(hideMute: Bool = false, hideVideo: Bool = false, hideSwitchCamera: Bool = false) {
        muteButton.isHidden = hideMute
        toggleVideoButton.isHidden = hideVideo
        switchCameraButton.isHidden = hideSwitchCamera
    }
    
    @IBAction open func didToggleMute(_ sender: Any) {
        delegate?.muteButtonPressed()
    }
    
    @IBAction open func didToggleVideo(_ sender: Any) {
        delegate?.toggleVideoButtonPressed()
    }
    
    @IBAction open func didSwitchCamera(_ sender: Any) {
        delegate?.switchCameraButtonPressed() 
    }
    
    @IBAction open func didTapHangUp(_ sender: Any) {
        delegate?.hangUpButtonPressed()
    }

}
