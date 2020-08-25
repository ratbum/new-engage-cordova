//
//  CLOptionView.swift
//  CLEngine
//
//  Created by Thomas Lee on 20/09/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import UIKit


public class CLOption<T: Comparable> {
  var value: T
  var labelText: String = ""
  var image: UIImage
  var inactiveColour: UIColor
  var activeColor: UIColor
  var accessibilityIdentifier: String?

  public init(value: T,
              labelText: String,
              image: UIImage,
              inactiveColour: UIColor,
              activeColor: UIColor,
              accessibilityIdentifier: String? = nil) {
    self.value = value
    self.labelText = labelText
    self.image = image
    self.activeColor = activeColor
    self.inactiveColour = inactiveColour
    self.accessibilityIdentifier = accessibilityIdentifier
  }
}

public protocol CLOptionViewDelegate{
  func optionViewChanged(index: Int)
}

public class CLOptionView<T: Comparable>: UIView, NibLoadable {

  @IBOutlet var contentView: UIView!
  @IBOutlet var optionCollection: [UIView]!

  public var delegate: CLOptionViewDelegate?

  private var _options: [CLOption<T>] = [] as! [CLOption<T>]
  private var _selectedIndex: Int?

  public var selectedIndex: Int? {
    return _selectedIndex
  }

  public var selectedOption: CLOption<T>? {
    get {
      if _selectedIndex == nil {
        return nil
      }
      return _options[_selectedIndex!]
    }
  }

  public var labelColor: UIColor {
    get {
      return findSubview(ofType: UILabel.self, within: self)!.textColor
    }
    set(newColor) {
      for view in optionCollection {
        let label = findSubview(ofType: UILabel.self, within: view)
        label?.textColor = newColor
      }
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    translatesAutoresizingMaskIntoConstraints = false
    setupFromNib()
    self.optionCollection.sort { $0.frame.origin.x < $1.frame.origin.x}
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    translatesAutoresizingMaskIntoConstraints = false
    setupFromNib()
    self.optionCollection.sort { $0.frame.origin.x < $1.frame.origin.x }
  }

  public func setSelectedOptionByValue(_ value: T) {
    for index in 0..<_options.count {
      let optionView = optionCollection[index]
      let isSelected = _options[index].value == value
      setOptionView(optionView, isSelected:isSelected)
    }
  }

  public var selectedValue: T? {
    get {
      return selectedOption?.value ?? nil
    }
  }

  private func setOptionView(_ optionView: UIView, isSelected: Bool) {
    let index = optionCollection.firstIndex(of: optionView)
    let option = _options[index!]
    let icon = findSubview(ofType: CLSilhouette.self, within: optionView)!
    icon.silhouetteImage = option.image
    icon.tintColor = isSelected ? option.activeColor : option.inactiveColour
    if isSelected {
      _selectedIndex = index
    }
    findSubview(ofType: UIButton.self, within: optionView)?.isSelected = isSelected
  }

  @IBAction func optionSelected(button: UIButton) {
    _selectedIndex = button.tag
    let targetOptionView = optionCollection[_selectedIndex!]

    for optionView in self.optionCollection {
      let currentButton = findSubview(ofType: UIButton.self, within: optionView)
      if currentButton == button {
        setOptionView(targetOptionView, isSelected: !button.isSelected)
      } else {
        setOptionView(optionView, isSelected: false)
      }
    }
    delegate?.optionViewChanged(index: _selectedIndex!)
  }

  public func setOptions(_ options: [CLOption<T>]) {
    self._options = options

    for (index, optionView) in self.optionCollection.enumerated() {
      let button = findSubview(ofType: UIButton.self, within: optionView)!
      button.tag = index

      let label = findSubview(ofType: UILabel.self, within: optionView)!
      label.text = options[index].labelText

      let icon = findSubview(ofType: CLSilhouette.self, within: optionView)!
      icon.silhouetteImage = options[index].image
      icon.tintColor = options[index].inactiveColour
      
      optionView.accessibilityIdentifier = options[index].accessibilityIdentifier
    }
  }

  public func setOptionsWithDictionaries(_ dicts: [Dictionary<String, T>]) {
    var options: [CLOption<T>] = []
    for dict in dicts {
      let option = CLOption<T>(value: dict["value"]!,
                           labelText: dict["labelText"] as! String,
                           image: dict["image"] as! UIImage,
                           inactiveColour: UIColor.black,
                           activeColor: UIColor.yellow)
      options.append(option)
    }
    setOptions(options)
  }

}
