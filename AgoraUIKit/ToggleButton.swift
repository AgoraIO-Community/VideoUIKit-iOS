//
//  ToggleButton.swift
//  AgoraUIKit
//
//  Created by Jonathan Fotland on 4/21/20.
//

import UIKit

@IBDesignable
public class ToggleButton: UIButton {
    
    var isToggled: Bool = false {
        didSet {
            setImageForState()
        }
    }
    
    /// The image that will be shown when the button is toggled off.
    @IBInspectable public var offImage: UIImage? {
        didSet {
            if oldValue == nil {
                setImage(offImage, for: .normal)
            }
        }
    }
    
    /// The image that will be shown when the button is selected while off.
    @IBInspectable public var offSelectedImage: UIImage? {
        didSet {
            if oldValue == nil {
                setImage(offImage, for: .selected)
            }
        }
    }
    
    /// The image that will be shown when the button is toggled on.
    @IBInspectable public var onImage: UIImage?
    
    /// The image that will be shown when the button is selected while on.
    @IBInspectable public var onSelectedImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(frame: CGRect, offImage: UIImage?, onImage: UIImage?, offSelectedImage: UIImage? = nil, onSelectedImage: UIImage? = nil) {
        super.init(frame: frame)
        self.onImage = onImage
        self.offImage = offImage
        self.onSelectedImage = onSelectedImage
        self.offSelectedImage = offSelectedImage
        commonInit()
    }
    
    func commonInit() {
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        setImageForState()
    }
    
    /// Toggle the button state to the given boolean.
    public func setToggled(on: Bool) {
        isToggled = on
    }
    
    /// Toggle the button.
    @objc func toggle() {
        isToggled = !isToggled
    }
    
    /// Set the right image
    private func setImageForState() {
        if isToggled {
            guard let onImage = onImage else { return }
            setImage(onImage, for: .normal)
            if let onSelected = onSelectedImage {
                setImage(onSelected, for: .selected)
            }
        } else {
            guard let offImage = offImage else { return }
            setImage(offImage, for: .normal)
            if let offSelected = offSelectedImage {
                setImage(offSelected, for: .selected)
            }
        }
    }
    
}
