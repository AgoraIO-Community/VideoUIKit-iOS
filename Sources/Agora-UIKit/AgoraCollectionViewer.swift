//
//  AgoraCollectionViewer.swift
//  Agora-UIKit
//
//  Created by Max Cobb on 26/11/2020.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Collection View to display all connected users camera feeds
public class AgoraCollectionViewer: MPCollectionView {

    static let cellSpacing: CGFloat = 5
    public static var flowLayout: MPCollectionViewFlowLayout {
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
    #elseif os(macOS)
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

/// Item in the collection view to contain the user's video feed, as well as microphone signal.
open class AgoraCollectionItem: MPCollectionViewCell {
    #if os(iOS)
    /// Icon to be displayed when the user is taken to the main view
    var backgroundIcon = MPImageView(
        image: MPImage(systemName: MPButton.pinSymbol)
    )
    #elseif os(macOS)
    /// Icon to be displayed when the user is taken to the main view
    open var backgroundIcon: MPButton = {
        let icon = MPButton()
        icon.font = .systemFont(ofSize: NSFont.systemFontSize * 1.5)
        icon.attributedTitle = NSAttributedString(
            string: MPButton.pinSymbol
        )
        icon.isBordered = false
        icon.wantsLayer = true
        icon.layer?.backgroundColor = .clear
        icon.isEnabled = false
        return icon
    }()

    #endif
    /// View for the video frame.
    var agoraVideoView: AgoraSingleVideoView? {
        didSet {
            guard let avv = self.agoraVideoView else {
                return
            }
            #if os(iOS)
            avv.frame = self.bounds
            self.addSubview(avv)
            #elseif os(macOS)
            avv.frame = self.view.bounds
            self.view.addSubview(avv)
            #endif
        }
    }
    #if os(iOS)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backgroundIcon)
        self.backgroundIcon.frame = CGRect(
            origin: CGPoint(x: (self.bounds.width - 30) / 2, y: (self.bounds.height - 30) / 2),
            size: CGSize(width: 30, height: 30)
        )
        self.backgroundIcon.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin
        ]
    }

    /// Create view from NSCoder, not yet implemented.
    /// - Parameter coder: NSCoder to build the view from
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    #elseif os(macOS)
    override public func loadView() {
        self.view = NSView(frame: .zero)
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.view.addSubview(self.backgroundIcon)
        self.backgroundIcon.frame = CGRect(
            origin: CGPoint(x: (self.view.bounds.width - 50) / 2,
                            y: (self.view.bounds.height - 50) / 2),
            size: CGSize(width: 50, height: 50)
        )
        self.backgroundIcon.autoresizingMask = [.maxXMargin, .minXMargin, .maxYMargin, .minYMargin]
     }
    #endif

}

extension AgoraVideoViewer: MPCollectionViewDelegate, MPCollectionViewDataSource {

    #if os(iOS)
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - indexPath: The index path that specifies the location of the item.
    /// - Returns: A valid or new cell to be displayed.
    public func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionCell", for: indexPath
        ) as? AgoraCollectionItem ?? AgoraCollectionItem()
        cell.backgroundColor = UIColor.blue.withAlphaComponent(0.4)
        return cell
    }

    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: The collection view requesting this information.
    ///   - section: An index number identifying a section in collectionView. This index value is 0-based.
    /// - Returns: Number of sections.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.collectionViewVideos.count
        collectionView.isHidden = count == 0
        return count
    }

    /// Tells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that is adding the cell.
    ///   - cell: The cell object being added.
    ///   - indexPath: The index path of the data item that the cell represents.
    public func collectionView(
        _ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        self.displayItem(cell, at: indexPath)
    }

    /// Tells the delegate that the specified cell was removed from the collection view.
    /// - Parameters:
    ///   - collectionView: The collection view object that removed the cell.
    ///   - cell: The cell object that was removed.
    ///   - indexPath: The index path of the data item that the cell represented.
    public func collectionView(
        _ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard cell is AgoraCollectionItem else {
            fatalError("cell not valid")
        }
    }
    #elseif os(macOS)
    public func collectionView(
        _ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("collectionCell"), for: indexPath
        ) as? AgoraCollectionItem ?? AgoraCollectionItem()
        cell.view.wantsLayer = true
        cell.view.layer?.backgroundColor = NSColor.blue.withAlphaComponent(0.4).cgColor
        return cell
    }

    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.collectionViewVideos.count
        collectionView.isHidden = count == 0
        return count
    }
    public func collectionView(
        _ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem,
        forRepresentedObjectAt indexPath: IndexPath
    ) {
        self.displayItem(item, at: indexPath)
    }
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        self.collectionView(collectionView, didSelectItemAt: indexPaths.first!)
    }
    #endif

    internal func refreshCollectionData() {
        switch self.style {
        case .floating, .collection:
            if self.agoraSettings.showSelf {
                self.collectionViewVideos = Array(self.userVideoLookup.values)
            } else {
                self.collectionViewVideos = Array(self.userVideoLookup.filter { $0.key != self.userID}.values)
            }
        default:
            self.collectionViewVideos.removeAll()
        }
        self.floatingVideoHolder.reloadData()
    }

    /// Both AppKit and UIKit delegate methods call this function, to have it all in one place
    /// - Parameters:
    ///   - item: UICollectionViewCell or NSCollectionViewItem to be displayed.
    ///   - indexPath: indexPath of the cell or item.
    internal func displayItem(_ item: MPCollectionViewCell, at indexPath: IndexPath) {
        #if os(iOS)
        let newVid = self.collectionViewVideos[indexPath.row]
        #elseif os(macOS)
        let newVid = self.collectionViewVideos[indexPath.item]
        #endif
        guard let cell = item as? AgoraCollectionItem else {
            fatalError("cell not valid")
        }
        var myActiveSpeaker: UInt?
        switch self.style {
        case .floating:
            myActiveSpeaker = self.overrideActiveSpeaker ?? self.activeSpeaker ?? self.userID
        default:
            break
        }
        // grid view is taking care of active speaker
        if newVid.uid != myActiveSpeaker {
            cell.agoraVideoView = newVid
        }
        if self.userID == newVid.uid {
            self.agkit.setupLocalVideo(newVid.canvas)
        } else {
            self.agkit.setupRemoteVideo(newVid.canvas)
            if newVid.uid != myActiveSpeaker && self.agoraSettings.usingDualStream {
                self.agkit.setRemoteVideoStream(newVid.uid, type: .low)
            }
        }
    }

    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: The collection view object that is notifying you of the selection change.
    ///   - indexPath: The index path of the cell that was selected.
    public func collectionView(_ collectionView: MPCollectionView, didSelectItemAt indexPath: IndexPath) {
        #if os(iOS)
        guard let agoraColItem = collectionView.cellForItem(at: indexPath) as? AgoraCollectionItem else {
            return
        }
        #elseif os(macOS)
        guard let agoraColItem = collectionView.item(at: indexPath) as? AgoraCollectionItem else {
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
