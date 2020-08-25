//
//  UIColor.swift
//  CLUIiOS
//
//  Created by Thomas Lee on 14/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  static public func colorFromRgbValue(_ rgbValue: Int) -> UIColor {
    return UIColor(displayP3Red: CGFloat((Float((rgbValue & 0xFF0000) >> 16))/255.0), green: CGFloat((Float((rgbValue & 0xFF00) >> 8))/255.0), blue: CGFloat((Float(rgbValue & 0xFF))/255.0), alpha: 1)
  }
}

