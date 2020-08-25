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
@objc public class CLCheckbox: UIControl {

  private let parentLayer = CALayer()
  private let checkmarkLayer = CALayer()

  @IBInspectable
  public var scale: CGFloat = 1.0
  public var checkmarkImage: UIImage? = UIImage(named: "checkmark")

  override public var tintColor: UIColor! {
    didSet {}
  }
  @IBInspectable
  public var isChecked: Bool = false {
    didSet {
      setNeedsDisplay()
      sendActions(for: UIControl.Event.valueChanged)
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
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 5.0

    parentLayer.frame = self.bounds
    self.layer.addSublayer(parentLayer)

    checkmarkLayer.contentsGravity = CALayerContentsGravity.resizeAspect

    checkmarkLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    checkmarkLayer.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
    parentLayer.mask = checkmarkLayer

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.checkToggled))
    self.addGestureRecognizer(tapGesture)
  }

  @objc func checkToggled() {
    isChecked = !isChecked
  }

  @objc override public func draw(_ rect: CGRect) {
    super.draw(rect)
    self.layer.borderColor = tintColor.cgColor
    parentLayer.backgroundColor = tintColor.cgColor
    checkmarkLayer.contents = checkmarkImage?.cgImage
    parentLayer.isHidden = !isChecked
    checkmarkLayer.bounds = CGRect(x: 0,
                                   y: 0,
                                   width: parentLayer.bounds.width * scale,
                                   height: parentLayer.bounds.height * scale)
  }

}
