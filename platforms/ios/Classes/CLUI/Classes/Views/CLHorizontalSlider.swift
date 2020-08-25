//
//  CLHorizontalSlider.swift
//  CLUI
//
//  Created by Thomas Lee on 11/04/2019.
//

import Foundation
import UIKit


class CLCurrentValueContainerView : UIView {
  override func draw(_ rect: CGRect) {
    let rectWidth = rect.width
    let rectHeight = rect.height

    // Find center of actual frame to set rectangle in middle
    let xf:CGFloat = (self.frame.width  - rectWidth)  / 2
    let yf:CGFloat = (self.frame.height - rectHeight) / 2

    let ctx: CGContext = UIGraphicsGetCurrentContext()!
    ctx.saveGState()

    let rect = CGRect(x: xf, y: yf, width: rectWidth, height: rectHeight)
    let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: 5).cgPath

    ctx.addPath(clipPath)
    ctx.setFillColor(UIColor.blue.cgColor)

    ctx.closePath()
    ctx.fillPath()
    ctx.restoreGState()
  }
}

protocol CLSliderDelegate {
  func currentLabel(on slider: CLHorizontalSlider, currentValue: Float) -> String
}

@IBDesignable
@objc public class CLHorizontalSlider: UIView, CLSlider, NibLoadable {

  @IBOutlet weak var minLabel: UILabel!
  @IBOutlet weak var maxLabel: UILabel!

  @IBOutlet weak var currentPositionLabel: UILabel!
  @IBOutlet weak var currentPositionContainer: CLCurrentValueContainerView!

  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var currentPositionContainerConstraint: NSLayoutConstraint!

  func nearestStep(value: Float) -> Float {
    var minDistance = Float.infinity
    var nearestValue = value
    for step in steps {
      let fstep = Float(step)
      let distance = Float.maximum(fstep, value) - Float.minimum(fstep, value)
      if distance < minDistance {
        minDistance = distance
        nearestValue = fstep
      }
    }
    return nearestValue
  }

  public var steps: Array<Int> = [] {
    didSet {
      minValue = Float(steps.first ?? 0)
      maxValue = Float(steps.last ?? 100)
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    translatesAutoresizingMaskIntoConstraints = false
    setupFromNib()
    setup()
  }
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupFromNib()
    setup()
  }

  var delegate: CLSliderDelegate?
  public var minValue: Float {
    get {
      return slider.minimumValue
    }
    set(newMin) {
      slider.minimumValue = newMin
    }
  }
  public var maxValue: Float {
    get {
      return slider.maximumValue
    }
    set(newMax) {
      slider.maximumValue = newMax
    }
  }
  public var currentValue: Float {
    get {
      return slider.value
    }
    set(newVal) {
      slider.value = newVal
      setSliderValueLabelPosition()
    }
  }
  public var minLabelText: String {
    get {
      return minLabel.text ?? ""
    }
    set(newText) {
      minLabel.text = newText
    }
  }
  public var maxLabelText: String {
    get {
      return maxLabel.text ?? ""
    }
    set(newText) {
      maxLabel.text = newText
    }
  }
  public var attributedMinLabelText: NSAttributedString {
    get {
      return minLabel.attributedText ?? NSAttributedString(string: "")
    }
    set(newText) {
      minLabel.attributedText = newText
    }
  }
  public var attributedMaxLabelText: NSAttributedString {
    get {
      return maxLabel.attributedText ?? NSAttributedString(string: "")
    }
    set(newText) {
      maxLabel.attributedText = newText
    }
  }

  @IBAction func sliderDragged(_ sender: UISlider) {
    if delegate == nil {
      currentValue = slider.value
      currentPositionLabel.text = String(Int(currentValue.rounded()))
    } else {
      currentPositionLabel.text = delegate?.currentLabel(on: self, currentValue: slider.value)
    }
  }

  @IBAction func valueChanged(_ sender: Any) {
    slider.value = Float(nearestStep(value: slider.value))
  }


  func setSliderValueLabelPosition() {
    let sliderValue = CGFloat(
      map(range: minValue...maxValue,
          domain: Float(slider.frame.minX)...Float(slider.frame.maxX),
          value: currentValue)
    )
    let halfWidth = slider.frame.width / 2

    let deviationFromMidX = sliderValue - halfWidth

    currentPositionContainerConstraint.constant = deviationFromMidX
  }

  func setValueFromSliderPosition() {
    currentValue = map(range: Float(slider.frame.minX)...Float(slider.frame.maxX),
                       domain: minValue...maxValue,
                       value: slider.value)
  }

  func map(range:ClosedRange<Float>, domain:ClosedRange<Float>, value:Float) -> Float {
    return (domain.upperBound - domain.lowerBound) *
      (value - range.lowerBound) /
      (range.upperBound - range.lowerBound)
      + domain.lowerBound
  }

  func setup() {
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .vertical)
    clipsToBounds = true
    slider.translatesAutoresizingMaskIntoConstraints = false

    currentPositionLabel.text = String(currentValue)
    minValue = 0
    maxValue = 10

    sizeToFit()
    slider.sizeToFit()
    setSliderValueLabelPosition()
  }

}
