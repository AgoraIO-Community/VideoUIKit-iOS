//
//  AgoraVideoViewer+Ordering.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

import Foundation

extension AgoraVideoViewer {
    /// Shuffle around the videos if multiple people are hosting, grid formation.
    internal func reorganiseVideos() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.reorganiseVideos()
            }
            return
        }
        self.floatingVideoHolder.reloadData()
        self.organiseGrid()

        switch self.style {
        case .grid, .floating:
            // these two cases are taken care of from floatingVideoHolder and organiseGrid above
            break
        case .custom(let orgCustom):
            // no custom setup yet
            orgCustom(self, self.userVideoLookup.enumerated(), self.userVideoLookup.count)
            break
        }
    }

    func organiseGrid() {
        if self.userVideosForGrid.isEmpty {
            return
        } else if self.userVideosForGrid.count == 2 {
            // when there are 2 videos we display them ontop of eachother
            for (idx, keyVals) in self.userVideosForGrid.enumerated() {
                let videoSessionView = keyVals.value
                self.backgroundVideoHolder.addSubview(videoSessionView)
//                videoSessionView.translatesAutoresizingMaskIntoConstraints = false
                videoSessionView.frame.size = CGSize(width: backgroundVideoHolder.frame.width, height: backgroundVideoHolder.frame.height / 2)
                videoSessionView.frame.origin = CGPoint(x: 0, y: idx == 0 ? 0 : backgroundVideoHolder.frame.height / 2)
                #if os(iOS)
                videoSessionView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
                #else
                videoSessionView.autoresizingMask = [.width, .height, .maxYMargin, .minYMargin, .maxXMargin, .minXMargin]
                #endif
            }
            return
        }
        let vidCounts = self.userVideosForGrid.count

        // I'm always applying an NxN grid, so if there are 12
        // We take on a grid of 4x4 (16).
        let maxSqrt = ceil(sqrt(CGFloat(vidCounts)))
        let multDim = 1 / maxSqrt
        for (idx, (_, videoSessionView)) in self.userVideosForGrid.enumerated() {
            self.backgroundVideoHolder.addSubview(videoSessionView)
            videoSessionView.frame.size = CGSize(width: backgroundVideoHolder.frame.width * multDim, height: backgroundVideoHolder.frame.height * multDim)
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
            #else
            videoSessionView.autoresizingMask = [.width, .height, .maxYMargin, .minYMargin, .maxXMargin, .minXMargin]
            #endif
        }
    }
}
