//
//  CLSlider.swift
//  CLUI
//
//  Created by Thomas Lee on 02/05/2019.
//

import Foundation

public protocol CLSlider {
  var minValue: Float {get set}
  var maxValue: Float {get set}
  var currentValue: Float {get set}
  var minLabelText: String {get set}
  var maxLabelText: String {get set}
  var attributedMinLabelText: NSAttributedString {get set}
  var attributedMaxLabelText: NSAttributedString {get set}
  var steps: Array<Int> {get set}
}
