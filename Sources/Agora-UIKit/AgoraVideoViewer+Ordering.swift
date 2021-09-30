//
//  AgoraVideoViewer+Ordering.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import Foundation
import CoreGraphics

extension AgoraVideoViewer {
    @discardableResult
    internal func addLocalVideo() -> AgoraSingleVideoView? {
        if self.userID == 0 || self.userVideoLookup[self.userID] != nil {
            return self.userVideoLookup[self.userID]
        }
        let vidView = AgoraSingleVideoView(
            uid: self.userID, micColor: self.agoraSettings.colors.micFlag
        )
        vidView.canvas.renderMode = self.agoraSettings.videoRenderMode
        self.agkit.setupLocalVideo(vidView.canvas)
        if !self.agSettings.externalVideoSettings.enabled {
            self.agkit.startPreview()
        }
        self.userVideoLookup[self.userID] = vidView
        return vidView
    }

    /// Create AgoraSingleVideoView for the requested userID
    /// - Parameters:
    ///   - userId: User ID of the feed to be displayed in the view
    /// - Returns: The newly created view, or an existing one for the same userID.
    @discardableResult
    open func addUserVideo(with userId: UInt) -> AgoraSingleVideoView {
        if let remoteView = self.userVideoLookup[userId] {
            return remoteView
        }
        let remoteVideoView = AgoraSingleVideoView(
            uid: userId, micColor: self.agoraSettings.colors.micFlag, delegate: self
        )
        remoteVideoView.canvas.renderMode = self.agoraSettings.videoRenderMode
        if self.rtmController?.rtcLookup.index(forKey: userId) != nil {
            remoteVideoView.showOptions = self.agoraSettings.showRemoteRequestOptions
        }
        self.agkit.setupRemoteVideo(remoteVideoView.canvas)
        self.userVideoLookup[userId] = remoteVideoView
        if self.activeSpeaker == nil {
            self.activeSpeaker = userId
        }
        return remoteVideoView
    }

    /// Randomly select an activeSpeaker that is not the local user
    open func setRandomSpeaker() {
        if let randomNotMe = self.userVideoLookup.keys.shuffled().filter({ $0 != self.userID }).randomElement() {
            // active speaker has left, reassign activeSpeaker to a random member
            self.activeSpeaker = randomNotMe
        } else {
            self.activeSpeaker = nil
        }
    }

    func removeUserVideo(with userId: UInt) {
        guard let userSingleView = userVideoLookup[userId],
              let canView = userSingleView.canvas.view else {
            return
        }
//        self.agkit.muteRemoteVideoStream(userId, mute: true)
        userSingleView.canvas.view = nil
        canView.removeFromSuperview()
        self.userVideoLookup.removeValue(forKey: userId)
        if let activeSpeaker = self.activeSpeaker, activeSpeaker == userId {
            self.setRandomSpeaker()
        }
    }
}

extension AgoraVideoViewer {
    /// Shuffle around the videos if multiple people are hosting, grid formation.
    internal func reorganiseVideos() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.reorganiseVideos()
            }
            return
        }
        self.refreshCollectionData()
        self.floatingVideoHolder.isHidden = self.collectionViewVideos.isEmpty
        self.organiseGrid()

        switch self.style {
        case .grid, .floating, .collection:
            // these two cases are taken care of from floatingVideoHolder and organiseGrid above
            break
        case .custom(let orgCustom):
            // no custom setup yet
            orgCustom(self, self.userVideoLookup.enumerated(), self.userVideoLookup.count)
        }
    }

    /// Display grid when there are only two video members
    fileprivate func gridForTwo() {
        // when there are 2 videos we display them ontop of eachother
        for (idx, keyVals) in self.userVideosForGrid.enumerated() {
            let videoSessionView = keyVals.value
            self.backgroundVideoHolder.addSubview(videoSessionView)
            videoSessionView.frame.size = CGSize(
                width: backgroundVideoHolder.frame.width,
                height: backgroundVideoHolder.frame.height / 2
            )
            videoSessionView.frame.origin = CGPoint(x: 0, y: idx == 0 ? 0 : backgroundVideoHolder.frame.height / 2)
            #if os(iOS)
            videoSessionView.autoresizingMask = [
                .flexibleWidth, .flexibleHeight,
                .flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin
            ]
            #elseif os(macOS)
            videoSessionView.autoresizingMask = [
                .width, .height, .maxYMargin, .minYMargin, .maxXMargin, .minXMargin
            ]
            #endif
            if self.agoraSettings.usingDualStream && self.userID != keyVals.key {
                self.agkit.setRemoteVideoStream(
                    keyVals.key,
                    type: self.agoraSettings.gridThresholdHighBitrate > 2 ? .high : .low
                )
            }
        }
    }

    fileprivate func formulateGrid(_ multDim: CGFloat, _ maxSqrt: CGFloat, _ vidCounts: Int) {
        for (idx, (videoID, videoSessionView)) in self.userVideosForGrid.enumerated() {
            self.backgroundVideoHolder.addSubview(videoSessionView)
            videoSessionView.frame.size = CGSize(
                width: backgroundVideoHolder.frame.width * multDim,
                height: backgroundVideoHolder.frame.height * multDim
            )
            if idx == 0 {
                videoSessionView.frame.origin = .zero
            } else {
                let posY = trunc(CGFloat(idx) / maxSqrt) * ((1 - multDim) * backgroundVideoHolder.frame.height)
                if (idx % Int(maxSqrt)) == 0 {
                    // New row, so go to the far left, and align the top of this
                    // view with the bottom of the previous view.
                    videoSessionView.frame.origin = CGPoint(x: 0, y: posY)
                } else {
                    // Go to the end of current row
                    videoSessionView.frame.origin = CGPoint(
                        x: CGFloat(idx % Int(maxSqrt)) / maxSqrt * backgroundVideoHolder.frame.width,
                        y: posY
                    )
                }
            }
            #if os(iOS)
            videoSessionView.autoresizingMask = [
                .flexibleLeftMargin, .flexibleRightMargin,
                .flexibleTopMargin, .flexibleBottomMargin,
                .flexibleWidth, .flexibleHeight
            ]
            #elseif os(macOS)
            videoSessionView.autoresizingMask = [.width, .height, .maxYMargin, .minYMargin, .maxXMargin, .minXMargin]
            #endif
            if self.agoraSettings.usingDualStream && videoID != self.userID {
                self.agkit.setRemoteVideoStream(
                    videoID,
                    type: vidCounts <= self.agoraSettings.gridThresholdHighBitrate ? .high : .low
                )
            }
        }
    }

    fileprivate func setVideoHolderPosition() {
        switch self.agoraSettings.floatPosition {
        case .top, .bottom:
            backgroundVideoHolder.frame.size = CGSize(
                width: self.bounds.width,
                height: self.bounds.height - (100 + 2 * AgoraCollectionViewer.cellSpacing)
            )
            if self.agoraSettings.floatPosition == .top {
                #if os(iOS)
                backgroundVideoHolder.frame.origin = CGPoint(x: 0, y: 100 + 2 * AgoraCollectionViewer.cellSpacing)
                #elseif os(macOS)
                backgroundVideoHolder.frame.origin = .zero
                #endif
            } else {
                #if os(iOS)
                backgroundVideoHolder.frame.origin = .zero
                #elseif os(macOS)
                backgroundVideoHolder.frame.origin = CGPoint(x: 0, y: 100 + 2 * AgoraCollectionViewer.cellSpacing)
                #endif
            }

        case .left, .right:
            backgroundVideoHolder.frame.size = CGSize(
                width: self.bounds.width - (100 + 2 * AgoraCollectionViewer.cellSpacing),
                height: self.bounds.height
            )
            if self.agoraSettings.floatPosition == .left {
                backgroundVideoHolder.frame.origin = CGPoint(
                    x: 100 + 2 * AgoraCollectionViewer.cellSpacing, y: 0
                )
            } else {
                backgroundVideoHolder.frame.origin = .zero
            }
        }
    }

    func organiseGrid() {
        if self.userVideosForGrid.isEmpty {
            return
        }
        if floatingVideoHolder.isHidden {
            self.backgroundVideoHolder.frame = self.bounds
        } else {
            setVideoHolderPosition()
        }
        #if os(iOS)
        self.backgroundVideoHolder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #elseif os(macOS)
        self.backgroundVideoHolder.autoresizingMask = [.width, .height]
        #endif

        if self.userVideosForGrid.count == 2 {
            gridForTwo()
            return
        }
        let vidCounts = self.userVideosForGrid.count

        // I'm always applying an NxN grid, so if there are 12
        // We take on a grid of 4x4 (16).
        let maxSqrt = ceil(sqrt(CGFloat(vidCounts)))
        let multDim = 1 / maxSqrt
        formulateGrid(multDim, maxSqrt, vidCounts)
    }
}
