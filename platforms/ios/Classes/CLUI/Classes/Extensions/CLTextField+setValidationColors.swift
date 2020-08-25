//
//  CLTextField+setValidationColors.swift
//  CLEngine
//
//  Created by Thomas Lee on 18/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

extension CLTextField {

  public func setValidationColors(forValidity isValid: Bool) {
    if isValid {
      setFieldColorsValid()
    } else if hasBeenUsed {
      setFieldColorsInvalid()
    } else {
      setFieldColorsNeutral()
    }
  }

  public func setFieldColorsNeutral() {
    let config = CrowdlabConfig.current
    let styleConfig = config.style
    underlineColor = styleConfig!.fieldColour
    tooltipColor = styleConfig!.tooltipColour
  }

  private func setFieldColorsInvalid() {
    let config = CrowdlabConfig.current
    let styleConfig = config.style
    underlineColor = styleConfig!.invalidColour
    tooltipColor = styleConfig!.invalidColour
  }

  private func setFieldColorsValid() {
    let config = CrowdlabConfig.current
    let styleConfig = config.style
    underlineColor = styleConfig!.validColour
    tooltipColor = styleConfig!.tooltipColour
  }
}

