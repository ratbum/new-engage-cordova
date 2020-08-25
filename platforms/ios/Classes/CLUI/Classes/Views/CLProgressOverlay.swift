//
//  CLProgressOverlay.swift
//  CLUIiOS
//
//  Created by Thomas Lee on 16/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

public class CLProgressOverlay: UIView {

  public var activityIndicator: UIActivityIndicatorView!

  public override init(frame: CGRect) {
    super.init(frame: frame)
  }

  private func setupActivityIndicator() {
    activityIndicator = UIActivityIndicatorView()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()
    activityIndicator.style = .whiteLarge
    activityIndicator.isHidden = false
    addSubview(activityIndicator)

    activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }

  public init(targetSuperview: UIView) {
    let entireFrame = targetSuperview.frame
    super.init(frame: entireFrame)
    translatesAutoresizingMaskIntoConstraints = false
    isOpaque = false
    backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.75)
    setupActivityIndicator()
    targetSuperview.addSubview(self)
    pinEdges(to: targetSuperview)
  }

  override public func removeFromSuperview() {
    activityIndicator.removeFromSuperview()
    activityIndicator = nil
    super.removeFromSuperview()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
