//
//  PinEdges.swift
//  CLUIiOS
//
//  Created by Thomas Lee on 16/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  public func pinEdges(to other: UIView) {
    leadingAnchor.constraint(equalTo: other.leadingAnchor).isActive = true
    trailingAnchor.constraint(equalTo: other.trailingAnchor).isActive = true
    topAnchor.constraint(equalTo: other.topAnchor).isActive = true
    bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
  }

  public func reversePinEdges(to other: UIView) {
    other.pinEdges(to: self);
  }
}
