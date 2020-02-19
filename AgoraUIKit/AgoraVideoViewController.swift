//
//  AgoraVideoViewController.swift
//  AgoraDemo
//
//  Created by Jonathan Fotland on 9/23/19.
//  Copyright © 2019 Jonathan Fotland. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit

/**
 `AgoraVideoViewController` is a view controller capable of joining and managing a multi-party Agora video call. It handles joining and leaving a channel, as well as showing remote video feeds from other users in the call.
 */
@IBDesignable
public class AgoraVideoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var hangUpButton: UIButton!
    @IBOutlet var toggleVideoButton: UIButton!
    @IBOutlet var switchCameraButton: UIButton!
    
    var appID = "YourAppIDHere"
    var agoraKit: AgoraRtcEngineKit?
    var tempToken: String? = nil
    var userID: UInt = 0
    var userName: String? = nil
    var channelName = "default"
    var remoteUserIDs: [UInt] = []
    var activeVideoIDs: [UInt] = []
    var numFeeds: Int {
        get {
            return activeVideoIDs.count
        }
    }
    
    /**
    Maximum streams to show at once. Defaults to 4.
     */
    public var maxStreams = 4
    
    var showingVideo = true
    
    var muted = false
    
    /**
     Creates a new AgoraVideoViewController.
     - Parameters:
        - appID: A static value that is used to connect to the Agora.io service. Get your Agora App Id from https://console.agora.io
        - token: A static value that is used to as the user's channel token. You can set either a dynamic token or a temp token. Generate a temp token usic https://console.agora.io. Default is `nil`
        - channel: The name of the channel to join. All users who join the same channel will be placed in a single call with each other. The channel name cannot be empty, and channel names of at least 3 characters are recommended.
     - Returns: A ready-to-use `AgoraVideoViewController`. Present it or push it onto a navigation stack to join a call.
     */
    public static func create(appID: String, token: String? = nil, channel: String) -> AgoraVideoViewController {
        
        if channel == "" {
            lprint("Cannot join a channel with no name.", .Normal)
        }
        
        let myBundle = Bundle(for: self)
        let myStoryboard = UIStoryboard(name: "AgoraVideoViewController", bundle: myBundle)

        let viewController = myStoryboard.instantiateInitialViewController() as! AgoraVideoViewController
        
        viewController.setParameters(appID: appID, token: token, channel: channel)
        
        return viewController
    }
    
    public func setParameters(appID: String, token: String? = nil, channel: String) {
        self.appID = appID
        self.tempToken = token
        self.channelName = channel
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
        setUpVideo()
        joinChannel()
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setUpVideo() {
        getAgoraEngine().enableVideo()
        
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = userID
//        videoCanvas.view = localVideoView
//        videoCanvas.renderMode = .fit
//        getAgoraEngine().setupLocalVideo(videoCanvas)
    }
    
    func joinChannel() {
        
        if let name = userName {
            getAgoraEngine().joinChannel(byUserAccount: name, token: tempToken, channelId: channelName) { [weak self] (sid, uid, elapsed) in
                self?.userID = uid
                self?.activeVideoIDs.insert(uid, at: 0)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        } else {
            getAgoraEngine().joinChannel(byToken: tempToken, channelId: channelName, info: nil, uid: userID) { [weak self] (sid, uid, elapsed) in
                self?.userID = uid
                self?.activeVideoIDs.insert(uid, at: 0)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    private func getAgoraEngine() -> AgoraRtcEngineKit {
        if agoraKit == nil {
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appID, delegate: self)
        }
        
        return agoraKit!
    }
    
    @IBAction public func didToggleMute(_ sender: Any) {
        getAgoraEngine().muteLocalAudioStream(!muted)

        muted = !muted
        
        if muted {
            muteButton.setImage(UIImage(named: "btn_mute_normal"), for: .normal)
            muteButton.setImage(UIImage(named: "btn_mute_pressed"), for: .selected)
        } else {
            muteButton.setImage(UIImage(named: "btn_unmute_normal"), for: .normal)
            muteButton.setImage(UIImage(named: "btn_unmute_pressed"), for: .selected)
        }
    }
    
    @IBAction public func didToggleVideo(_ sender: Any) {
        getAgoraEngine().enableLocalVideo(!showingVideo)
        
        showingVideo = !showingVideo
        
        if !showingVideo {
            activeVideoIDs = activeVideoIDs.filter { $0 != userID }
        } else {
            activeVideoIDs.insert(userID, at: 0)
        }
        collectionView.reloadData()
    }
    
    @IBAction public func didSwitchCamera(_ sender: Any) {
        getAgoraEngine().switchCamera()
    }
    
    @IBAction public func didTapHangUp(_ sender: Any) {
        leaveChannel()
        if let navigation = navigationController {
            navigation.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func leaveChannel() {
        getAgoraEngine().leaveChannel(nil)
        remoteUserIDs.removeAll()
        collectionView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

/**
 `AgoraVideoViewController` implements a `UICollectionView` to display the video streams of the users in the call.
 */
extension AgoraVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Collection View Delegate Methods
    
    /**
     Handles showing the correct number of video streams. Default behavior displays up to four video streams at a time.
     */
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(maxStreams, numFeeds)
    }
    
    /**
     Handles the layout and setup of cells for displaying users' video streams.
     */
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        
        let uid = activeVideoIDs[indexPath.row]
        let isLocal = uid == userID
        
        if let videoCell = cell as? VideoCollectionViewCell {
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.view = videoCell.videoView
            videoCanvas.renderMode = .hidden
            if isLocal {
                getAgoraEngine().setupLocalVideo(videoCanvas)
            } else {
                getAgoraEngine().setupRemoteVideo(videoCanvas)
            }
            
            
            if let userInfo = getAgoraEngine().getUserInfo(byUid: uid, withError: nil),
                let username = userInfo.userAccount {
                videoCell.nameplateView.isHidden = false
                videoCell.usernameLabel.text = username
            } else {
                videoCell.nameplateView.isHidden = true
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
