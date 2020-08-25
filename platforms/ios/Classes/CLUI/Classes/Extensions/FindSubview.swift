//
//  FindSubview.swift
//  CLUIiOS
//
//  Created by Thomas Lee on 18/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
  func findSubview<T:UIView>(ofType type:T.Type, within searchTarget: UIView) -> T? {
    for subview in searchTarget.subviews {
      if subview is T {
        return (subview as! T)
      }
    }
    for subview in searchTarget.subviews {
      if let foundSubview = findSubview(ofType: type, within: subview) {
        return foundSubview
      }
    }
    return nil
  }
}
