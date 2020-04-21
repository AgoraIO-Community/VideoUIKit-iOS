//
//  VideoControlView.swift
//  AgoraUIKit
//
//  Created by Jonathan  Fotland on 4/16/20.
//  Copyright © 2020 Jonathan Fotland. All rights reserved.
//

import UIKit

/**
 Protocol for handling button presses in the video control panel that need to trigger Agora functionality.
 */
public protocol VideoControlViewDelegate: NSObject {
    /**
    Handler for the mute button being pressed. Mutes or unmutes the local audio.
    */
    func muteButtonPressed()
    /**
    Handler for the toggle video button being pressed. Mutes or unmutes the local video.
    */
    func toggleVideoButtonPressed()
    /**
    Handler for the hang up button being pressed. Leaves the video channel and dismisses the view controller.
    */
    func hangUpButtonPressed()
    /**
    Handler for the switch camera button being pressed. Toggles between the front and back cameras.
    */
    func switchCameraButtonPressed()
}

/**
 `VideoControlView ` is a container for a set of buttons to control the functionality of the video call. By default, contains buttons to toggle the audio and video, switch camera, and hang up. Use `loadControlView()` in `AgoraVideoViewController` to add customizations.
 */
@IBDesignable
open class VideoControlView: UIView {

    @IBOutlet weak var muteButton: ToggleButton!
    @IBOutlet weak var hangUpButton: UIButton!
    @IBOutlet weak var toggleVideoButton: ToggleButton!
    @IBOutlet weak var switchCameraButton: ToggleButton!
    
    /**
     Delegate to handle actual functionality. Notified when buttons are pressed.
     */
    public weak var delegate: VideoControlViewDelegate?
    
    /**
     Shows or hides the desired non-essential buttons. Defaults to showing all buttons.
     - Parameters:
        - hideMute: Whether to hide the audio mute button.
        - hideVideo: Whether to hide the video mute button.
        - hideSwitchCamera: Whether to hide the button to toggle the camera.
     */
    public func setupControls(hideMute: Bool = false, hideVideo: Bool = false, hideSwitchCamera: Bool = false) {
        muteButton.isHidden = hideMute
        toggleVideoButton.isHidden = hideVideo
        switchCameraButton.isHidden = hideSwitchCamera
    }
    
    /**
    Handler for the mute button being pressed.
    */
    @IBAction public func didToggleMute(_ sender: Any) {
        delegate?.muteButtonPressed()
    }
    
    /**
    Handler for the toggle video button being pressed.
    */
    @IBAction public func didToggleVideo(_ sender: Any) {
        delegate?.toggleVideoButtonPressed()
    }
    
    /**
    Handler for the hang up button being pressed.
    */
    @IBAction public func didTapHangUp(_ sender: Any) {
        delegate?.hangUpButtonPressed()
    }

    /**
    Handler for the switch camera button being pressed.
    */
    @IBAction public func didSwitchCamera(_ sender: Any) {
        delegate?.switchCameraButtonPressed() 
    }
    
   

}
