//
//  CLTextField+validate.swift
//  CLEngine
//
//  Created by Thomas Lee on 18/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

extension CLTextField {
  
  public func updateValidation(valueCheck: (_:String) -> String?, defaultTooltipKey: String) {
    let tooltipKey = valueCheck(self.text)
    let isValid = tooltipKey == nil
    if isValid {
      self.tooltipText = Translator().translate(defaultTooltipKey)
    } else {
      self.tooltipText = Translator().translate(tooltipKey!)
    }
    self.tooltipLabel.setNeedsDisplay()
    self.tooltipLabel.setNeedsLayout()
    setValidationColors(forValidity: isValid)
  }

}

