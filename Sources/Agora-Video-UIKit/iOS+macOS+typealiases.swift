//
//  iOS+macOS+typealiases.swift
//  Agora-Video-UIKit
//
//  Created by Max Cobb on 25/11/2020.
//

#if os(iOS)
import UIKit
public typealias MPButton=UIButton
public typealias MPImage = UIImage
public typealias MPImageView = UIImageView
public typealias MPView = UIView
public typealias MPColor = UIColor
public typealias MPBlurView = UIVisualEffectView
public typealias MPViewController = UIViewController
public typealias MPEdgeInsets = UIEdgeInsets
public typealias MPCollectionView = UICollectionView
public typealias MPCollectionViewCell = UICollectionViewCell
public typealias MPCollectionViewLayout = UICollectionViewLayout
public typealias MPCollectionViewFlowLayout = UICollectionViewFlowLayout
public typealias MPCollectionViewDelegate = UICollectionViewDelegate
public typealias MPCollectionViewDataSource = UICollectionViewDataSource
#elseif os(macOS)
import AppKit
public typealias MPButton = NSButton
public typealias MPImage = NSImage
public typealias MPImageView = NSImageView
public typealias MPView = NSView
public typealias MPColor = NSColor
public typealias MPBlurView = NSVisualEffectView
public typealias MPViewController = NSViewController
public typealias MPEdgeInsets = NSEdgeInsets
public typealias MPCollectionView = NSCollectionView
public typealias MPCollectionViewCell = NSCollectionViewItem
public typealias MPCollectionViewLayout = NSCollectionViewLayout
public typealias MPCollectionViewFlowLayout = NSCollectionViewFlowLayout
public typealias MPCollectionViewDelegate = NSCollectionViewDelegate
public typealias MPCollectionViewDataSource = NSCollectionViewDataSource
#endif
