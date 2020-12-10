//
//  AgoraCollectionViewer.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 26/11/2020.
//

#if os(iOS)
import UIKit
public typealias MPEdgeInsets = UIEdgeInsets
public typealias MPCollectionView = UICollectionView
public typealias MPCollectionViewCell = UICollectionViewCell
public typealias MPCollectionViewLayout = UICollectionViewLayout
public typealias MPCollectionViewFlowLayout = UICollectionViewFlowLayout
public typealias MPCollectionViewDelegate = UICollectionViewDelegate
public typealias MPCollectionViewDataSource = UICollectionViewDataSource
#elseif os(macOS)
import AppKit
public typealias MPEdgeInsets = NSEdgeInsets
public typealias MPCollectionView = NSCollectionView
public typealias MPCollectionViewCell = NSCollectionViewItem
public typealias MPCollectionViewLayout = NSCollectionViewLayout
public typealias MPCollectionViewFlowLayout = NSCollectionViewFlowLayout
public typealias MPCollectionViewDelegate = NSCollectionViewDelegate
public typealias MPCollectionViewDataSource = NSCollectionViewDataSource
#endif

public class AgoraCollectionViewer: MPCollectionView {

    static let cellSpacing: CGFloat = 5
    static var flowLayout: MPCollectionViewFlowLayout {
        let flowLayout = MPCollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = MPEdgeInsets(
            top: AgoraCollectionViewer.cellSpacing,
            left: AgoraCollectionViewer.cellSpacing,
            bottom: AgoraCollectionViewer.cellSpacing,
            right: AgoraCollectionViewer.cellSpacing
        )
        flowLayout.minimumInteritemSpacing = AgoraCollectionViewer.cellSpacing
        return flowLayout
    }

    #if os(iOS)
    override init(frame: CGRect, collectionViewLayout layout: MPCollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        self.register(AgoraCollectionItem.self, forCellWithReuseIdentifier: "collectionCell")
    }
    #else
    init(frame: CGRect, collectionViewLayout layout: MPCollectionViewLayout) {
        super.init(frame: frame)
        self.collectionViewLayout = layout
        self.register(
            AgoraCollectionItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("collectionCell")
        )
        self.isSelectable = true
        self.allowsMultipleSelection = false
        self.backgroundColors = [NSColor.windowBackgroundColor.withAlphaComponent(0.7)]
    }
    #endif

    convenience init() {
        self.init(frame: .zero, collectionViewLayout: AgoraCollectionViewer.flowLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AgoraCollectionItem: MPCollectionViewCell {
    var agoraVideoView: AgoraSingleVideoView? {
        didSet {
            guard let avv = self.agoraVideoView else {
                return
            }
            #if os(macOS)
            avv.frame = self.view.bounds
            self.view.addSubview(avv)
            #else
            avv.frame = self.bounds
            self.addSubview(avv)
            #endif
        }
    }
    #if os(macOS)
    override func loadView() {
        self.view = NSView(frame: .zero)
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    #else
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #endif

}

extension AgoraVideoViewer: MPCollectionViewDelegate, MPCollectionViewDataSource {

    #if os(macOS)
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("collectionCell"), for: indexPath
        ) as! AgoraCollectionItem
        cell.view.wantsLayer = true
        cell.view.layer?.backgroundColor = NSColor.blue.withAlphaComponent(0.4).cgColor
        return cell
    }

    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.videosToShow.count
        collectionView.isHidden = count == 0
        return count
    }
    public func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        self.displayItem(item, at: indexPath)
    }
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        self.collectionView(collectionView, didSelectItemAt: indexPaths.first!)
    }

    #else
    public func collectionView(_ collectionView: MPCollectionView, cellForItemAt indexPath: IndexPath) -> MPCollectionViewCell {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! AgoraCollectionItem
        cell.backgroundColor = UIColor.blue.withAlphaComponent(0.4)
        return cell
    }

    public func collectionView(_ collectionView: MPCollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.videosToShow.count
        collectionView.isHidden = count == 0
        return count
    }
    public func collectionView(_ collectionView: MPCollectionView, willDisplay cell: MPCollectionViewCell, forItemAt indexPath: IndexPath) {
        self.displayItem(cell, at: indexPath)
    }

    public func collectionView(_ collectionView: MPCollectionView, didEndDisplaying cell: MPCollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let _ = cell as? AgoraCollectionItem else {
            fatalError("cell not valid")
        }
    }

    #endif

    var videosToShow: [AgoraSingleVideoView] {
        self.style == .floating ? Array(self.userVideoLookup.values) : []
    }

    /// Both AppKit and UIKit delegate methods call this function, to have it all in one place
    /// - Parameters:
    ///   - item: UICollectionViewCell or NSCollectionViewItem to be displayed.
    ///   - indexPath: indexPath of the cell or item.
    internal func displayItem(_ item: MPCollectionViewCell, at indexPath: IndexPath) {
        #if os(macOS)
        let newVid = self.videosToShow[indexPath.item]
        #else
        let newVid = self.videosToShow[indexPath.row]
        #endif
        guard let cell = item as? AgoraCollectionItem else {
            fatalError("cell not valid")
        }
        let myActiveSpeaker = self.overrideActiveSpeaker ?? self.activeSpeaker ?? self.userID
        // grid view is taking care of active speaker
        if newVid.uid != myActiveSpeaker {
            cell.agoraVideoView = newVid
        }
        if self.userID == newVid.uid {
            self.agkit.setupLocalVideo(newVid.canvas)
        } else {
            self.agkit.setupRemoteVideo(newVid.canvas)
        }
    }

    public func collectionView(_ collectionView: MPCollectionView, didSelectItemAt indexPath: IndexPath) {
        #if os(macOS)
        guard let agoraColItem = collectionView.item(at: indexPath) as? AgoraCollectionItem else {
            return
        }
        #else
        guard let agoraColItem = collectionView.cellForItem(at: indexPath) as? AgoraCollectionItem else {
            return
        }
        #endif
        if self.overrideActiveSpeaker == agoraColItem.agoraVideoView?.uid {
            self.overrideActiveSpeaker = nil
            return
        }
        self.overrideActiveSpeaker = agoraColItem.agoraVideoView?.uid
    }
}
