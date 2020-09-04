//
//  AgoraVideoViewController.swift
//  AgoraDemo
//
//  Created by Jonathan Fotland on 9/23/19.
//  Copyright © 2019 Jonathan Fotland. All rights reserved.
//

import UIKit
import AgoraRtcKit

/**
 `AgoraVideoViewController` is a view controller capable of joining and managing a multi-party Agora video call. It handles joining and leaving a channel, as well as showing remote video feeds from other users in the call.
 */
open class AgoraVideoViewController: UICollectionViewController, VideoControlViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var controlView: VideoControlView?
    
    var userID: UInt = 0
    var userName: String? = nil
    var channelName = "default"
    var activeVideoIDs: [UInt] = []
    var numFeeds: Int {
        get {
            return activeVideoIDs.count
        }
    }
    
    var maxStreams = 4
    
    var showingVideo = true
    
    var muted = false
    
    var frontCamera = true
    
    /**
    The render mode of the video views. Defaults to RenderModeHidden.
     */
    public var videoRenderMode: AgoraVideoRenderMode = .hidden
    
    var shouldHideMuteButton = false {
        didSet(value) {
            controlView?.muteButton?.isHidden = value
        }
    }
    var shouldHideVideoButton = false {
        didSet(value) {
            controlView?.toggleVideoButton?.isHidden = value
        }
    }
    var shouldHideSwitchCameraButton = false {
        didSet(value) {
            controlView?.switchCameraButton?.isHidden = value
        }
    }
    
    /**
     Available locations for the video control panel.
     */
    public enum VideoControlLocation {
        /**
        Controls on top.
         */
        case top
        /**
         Controls on bottom.
         */
        case bottom
    }
    
    /**
     Location of the video controls, either top or bottom.
     */
    public var controlLocation = VideoControlLocation.bottom {
        didSet {
            updateControlLocation()
        }
    }
    
    
    /**
     How far from the edge of the screen to place the video controls. Minimum of 0. Defaults to 20.
    */
    public var controlOffset: CGFloat = 20 {
        didSet {
            if controlOffset < 0 {
                controlOffset = 0
            }
            updateControlLocation()
        }
    }
    
    var controlConstraint: NSLayoutConstraint?
    
    /**
     Convenience initializer. Uses the existing appID and token in `AgoraPreferences`.
     - Parameters:
        - channel: The name of the channel to join. All users who join the same channel will be placed in a single call with each other. The channel name cannot be empty, and channel names of at least 3 characters are recommended.
     */
    public convenience init(channel: String) {
        self.init(appID: AgoraPreferences.shared.appID, token: AgoraPreferences.shared.token, channel: channel)
    }
    
    /**
     Initializes a new AgoraVideoViewController.
     - Parameters:
        - appID: A static value that is used to connect to the Agora.io service. Get your Agora App Id from https://console.agora.io
        - token: A static value that is used to as the user's channel token. You can set either a dynamic token or a temp token. Generate a temp token using https://console.agora.io. Default is `nil`
        - channel: The name of the channel to join. All users who join the same channel will be placed in a single call with each other. The channel name cannot be empty, and channel names of at least 3 characters are recommended.
     */
    public init(appID: String, token: String? = nil, channel: String) {
        let layout = UICollectionViewFlowLayout()
        
        super.init(collectionViewLayout: layout)
        setParameters(appID: appID, token: token, channel: channel)
        addControlView()
        
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "videoCell")
        AgoraPreferences.shared.getAgoraEngine().delegate = self
    }
    
    /**
     Required init. Not implemented.
     */
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
    Sets the core parameters for a new AgoraVideoViewController. Redundant with init(appID:, token:, channel:).
     - Parameters:
        - appID: A static value that is used to connect to the Agora.io service. Get your Agora App Id from https://console.agora.io
        - token: A static value that is used to as the user's channel token. You can set either a dynamic token or a temp token. Generate a temp token using https://console.agora.io. Default is `nil`
        - channel: The name of the channel to join. All users who join the same channel will be placed in a single call with each other. The channel name cannot be empty, and channel names of at least 3 characters are recommended.
     */
    open func setParameters(appID: String, token: String? = nil, channel: String) {
        AgoraPreferences.shared.appID = appID
        AgoraPreferences.shared.token = token
        
        if channel == "" {
            lprint("Cannot join a channel with no name.", .Normal)
        }
        
        self.channelName = channel
        AgoraPreferences.shared.getAgoraEngine().delegate = self
    }
    
    /**
     Adds the control view created by loadControlView(). Call this function if you are using your own layout, but want to use the default control view.
     */
    open func addControlView() {
        if let controls = loadControlView() {
            controlView = controls
            controls.delegate = self
            view.addSubview(controls)
            controlConstraint = NSLayoutConstraint(item: controls, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            
            view.addConstraint(controlConstraint!)
            view.addConstraint(NSLayoutConstraint(item: controls, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: controls, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        }
    }
    
    /**
     Loads the video control view. Override to create your own video controls.
     */
    open func loadControlView() -> VideoControlView? {
        let nib = UINib(nibName: "VideoControlView", bundle: Bundle(for:AgoraVideoViewController.self))
        if let view = nib.instantiate(withOwner: self, options: nil).first as? VideoControlView {
            return view
        }
        return nil
    }
    
    /**
     Initializes and joins an Agora channel on first load.
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
        setupControls()
        setUpVideo()
        joinChannel()
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func updateControlLocation() {
        if let constraint = controlConstraint, let controls = controlView {
            view.removeConstraint(constraint)
            
            var attribute: NSLayoutConstraint.Attribute
            var offset: CGFloat
            switch controlLocation {
            case .top:
                attribute = .top
                offset = controlOffset
            case .bottom:
                attribute = .bottom
                offset = -controlOffset
            }
            
            controlConstraint = NSLayoutConstraint(item: controls, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: offset)
            
            view.addConstraint(controlConstraint!)
        }
    }
    
    func setupControls() {
        controlView?.setupControls(hideMute: shouldHideMuteButton,
                                   hideVideo: shouldHideVideoButton,
                                   hideSwitchCamera: shouldHideSwitchCameraButton)
    }
    
    func setUpVideo() {
        AgoraPreferences.shared.getAgoraEngine().enableVideo()
    }
    
    func joinChannel() {
        
        if let name = userName {
            AgoraPreferences.shared.getAgoraEngine().joinChannel(byUserAccount: name, token: AgoraPreferences.shared.token, channelId: channelName) { [weak self] (sid, uid, elapsed) in
                self?.userID = uid
                if self?.showingVideo == true {
                    self?.activeVideoIDs.insert(uid, at: 0)
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            }
        } else {
            AgoraPreferences.shared.getAgoraEngine().joinChannel(byToken: AgoraPreferences.shared.token, channelId: channelName, info: nil, uid: userID) { [weak self] (sid, uid, elapsed) in
                self?.userID = uid
                if self?.showingVideo == true {
                    self?.activeVideoIDs.insert(uid, at: 0)
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: Button event handlers
    
    /**
     Mutes or unmutes the local audio. Called when the mute button is pressed.
     */
    public func toggleLocalAudio() {
        AgoraPreferences.shared.getAgoraEngine().muteLocalAudioStream(!muted)

        muted = !muted
    }
    
    /**
     Mutes or unmutes the local video. Called when the disable video button is pressed.
     */
    public func toggleLocalVideo() {
        AgoraPreferences.shared.getAgoraEngine().enableLocalVideo(!showingVideo)
        
        showingVideo = !showingVideo
        
        if !showingVideo {
            activeVideoIDs = activeVideoIDs.filter { $0 != userID }
        } else {
            activeVideoIDs.insert(userID, at: 0)
        }
        collectionView?.reloadData()
    }
    
    /**
     Leaves the video channel and dismisses the view controller. Called when the hang up button is pressed.
     */
    public func leaveCall() {
        leaveChannel()
        if let navigation = navigationController {
            navigation.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     Toggles between the front and back cameras. Called when the switch camera button is pressed.
     */
    public func switchCamera() {
        AgoraPreferences.shared.getAgoraEngine().switchCamera()
        
        frontCamera = !frontCamera
    }
    
    func leaveChannel() {
        AgoraPreferences.shared.getAgoraEngine().leaveChannel(nil)
        activeVideoIDs.removeAll()
        collectionView?.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Customization options
    
    /**
     Makes the local user an audience member, with no local video or audio. Automatically sets the channel profile to .liveBroadcasting.
     */
    open func setIsAudience() {
        showingVideo = false
        muted = true
        AgoraPreferences.shared.getAgoraEngine().setChannelProfile(.liveBroadcasting)
        AgoraPreferences.shared.getAgoraEngine().setClientRole(.audience)
    }
    
    /**
     Sets the maximum number of video streams to show at once, including the local stream.
     
     - Parameters:
        - streams: The maximum number of streams to show, including the local stream. Cannot be set lower than 1. Default is 4.
     */
    public func setMaxStreams(streams: Int) {
        if streams < 1 {
            maxStreams = 1
        } else {
            maxStreams = streams
        }
    }
    
    /**
     Toggles whether to hide the button to switch cameras.
     
     - Parameters:
        - hidden: Whether to hide the button. Will hide the button if no parameter is passed.
     */
    public func hideSwitchCamera(hidden: Bool = true) {
        shouldHideSwitchCameraButton = hidden
        setupControls()
    }
    
    /**
     Toggles whether to hide the button to mute the local video feed.
     
     - Parameters:
        - hidden: Whether to hide the button. Will hide the button if no parameter is passed.
    */
    public func hideVideoMute(hidden: Bool = true) {
        shouldHideVideoButton = hidden
        setupControls()
    }
    
    /**
     Toggles whether to hide the button to mute the local audio feed.
    
     - Parameters:
        - hidden: Whether to hide the button. Will hide the button if no parameter is passed.
    */
    public func hideAudioMute(hidden: Bool = true) {
        shouldHideMuteButton = hidden
    }
    
    // MARK: Collection View Delegate Methods
    
    /**
     Handles showing the correct number of video streams. Default behavior displays up to four video streams at a time.
     */
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(maxStreams, numFeeds)
    }
    
    /**
     Handles the layout and setup of cells for displaying users' video streams.
     */
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        
        let uid = activeVideoIDs[indexPath.row]
        let isLocal = uid == userID
        
        if let videoCell = cell as? VideoCollectionViewCell {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.view = videoCell.contentView
            videoCanvas.renderMode = videoRenderMode
            if isLocal {
                AgoraPreferences.shared.getAgoraEngine().setupLocalVideo(videoCanvas)
            } else {
                AgoraPreferences.shared.getAgoraEngine().setupRemoteVideo(videoCanvas)
            }
        }
        
        return cell
    }
    
    /**
     Determines the size of each collection view cell.
     */
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if numFeeds == 1 {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else if numFeeds == 2 {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 2)
        } else if numFeeds == 3 {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 2)
            } else {
                return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.height / 2)
            }
        } else {
            return CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.height / 2)
        }
    }
}
