//
//  CLCheckbox.swift
//  CLUIiOS
//
//  Created by Thomas Lee on 29/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
@objc public class CLSilhouette: UIView {

  private let parentLayer = CALayer()
  private let imageLayer = CALayer()

  @IBInspectable
  public var scale: CGFloat = 1.0
  public var silhouetteImage: UIImage?

  override public var tintColor: UIColor! {
    didSet {
      parentLayer.backgroundColor = tintColor.cgColor
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup() 
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    self.layer.frame = self.bounds

    parentLayer.frame = self.bounds
    self.layer.addSublayer(parentLayer)

    imageLayer.contentsGravity = CALayerContentsGravity.resizeAspect

    imageLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    imageLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
    parentLayer.mask = imageLayer
  }

  @objc override public func draw(_ rect: CGRect) {
    super.draw(rect)
    self.layer.borderColor = tintColor.cgColor
    imageLayer.contents = silhouetteImage?.cgImage
    imageLayer.bounds = CGRect(x: 0,
                                   y: 0,
                                   width: parentLayer.bounds.width * scale,
                                   height: parentLayer.bounds.height * scale)
  }

}
