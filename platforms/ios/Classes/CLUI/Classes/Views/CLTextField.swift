//
//  CLTextField.swift
//  CLEngine
//
//  Created by Thomas Lee on 04/10/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
@objc public class CLTextField : UIView, UITextFieldDelegate, NibLoadable {
  
  @IBOutlet weak public var textField: UITextField!
  @IBOutlet weak public var placeholderLabel: UILabel!
  @IBOutlet weak public var topLabel: UILabel!
  @IBOutlet weak public var toolTipView: UIView!
  @IBOutlet weak public var tooltipLabel: UILabel!
  @IBOutlet weak public var underline: UIView!
  @IBOutlet weak public var buttonToggleTextVisibility: UIButton!

  public var delegate: CLTextFieldDelegate?

  public var buttonToggleTextVisibilityImageEnabled: UIImage?
  public var buttonToggleTextVisibilityImageDisabled: UIImage?
  private var _hasBeenUsed: Bool = false

  public override var isAccessibilityElement: Bool {
    get {
      return false
    }
    set(newVal) {
      // ignore
    }
  }

  public var hasBeenUsed:Bool {
     get {
      return _hasBeenUsed
    }
    set(newUsed) {
      _hasBeenUsed = newUsed
    }
  }

  @IBInspectable public var text: String {
    get {
      return textField.text ?? ""
    }
    set(newText) {
      textField.text = newText
    }
  }
  @IBInspectable public var labelText: String = "unset" {
    didSet {
      topLabel.text = labelText
      placeholderLabel.text = labelText
      topLabel.accessibilityLabel = labelText
    }
  }
  @IBInspectable public var tooltipText: String {
    get {
      return tooltipLabel.text ?? ""
    }
    set(newTooltipText) {
      tooltipLabel.text = newTooltipText
      textField.accessibilityHint = newTooltipText
      self.sizeToFit()
    }
  }
  var animationTimeInSeconds: Float = 0.2
  @IBInspectable public var isPassword: Bool = false {
    didSet {
      textField.isSecureTextEntry = isPassword
      buttonToggleTextVisibility.isEnabled = isPassword
      buttonToggleTextVisibility.isHidden = !isPassword
      buttonToggleTextVisibility.isSelected = false
      buttonToggleTextVisibility.setImage(buttonToggleTextVisibilityImageEnabled, for: .selected)
      buttonToggleTextVisibility.setImage(buttonToggleTextVisibilityImageDisabled, for: .normal)
    }
  }
  @IBInspectable public var textColor: UIColor = UIColor.black
  @IBInspectable public var labelColor: UIColor = UIColor.black {
    didSet {
      topLabel.textColor = labelColor
      placeholderLabel.textColor = labelColor
    }
  }
  @IBInspectable public var tooltipColor: UIColor = #colorLiteral(red: 0.8796768785, green: 0.2174243033, blue: 0.2412634194, alpha: 1) {
    didSet {
      tooltipLabel.textColor = tooltipColor
    }
  }
  @IBInspectable public var underlineColor: UIColor = #colorLiteral(red: 0.577245214, green: 0.577245214, blue: 0.577245214, alpha: 1) {
    didSet {
      underline.backgroundColor = underlineColor
    }
  }
  public var keyboardType: UIKeyboardType {
    get {
      return textField.keyboardType
    }
    set(kt) {
      textField.keyboardType = kt
    }
  }

  public var isEditing = false


  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupFromNib()
    setup()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupFromNib()
    setup()
  }

  public func initWith(labelText: String) -> Self {
    setupFromNib()
    self.labelText = labelText
    setup()
    return self
  }

  private func setup() {
    textField.delegate = self
    textField.isAccessibilityElement = true
    topLabel.isAccessibilityElement = true
    tooltipLabel.isAccessibilityElement = true
    isPassword = false
    tooltipLabel.numberOfLines = 0
    tooltipText = ""
    setEditingState(false)
    translatesAutoresizingMaskIntoConstraints = false
    self.setNeedsLayout()
    self.sizeToFit()
    textField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
  }

  public func setEditingState(_ isEditing: Bool) {
    self.isEditing = isEditing
    let hasValue = text.count > 0

    let targetToolTipAlpha = CGFloat((tooltipLabel.text?.count ?? 0 > 0) ? 1 : 0)
    let targetEditingLabelAlpha = CGFloat(hasValue || isEditing ? 1 : 0)
    let targetLabelAlpha = CGFloat(hasValue || isEditing ? 0 : 1)

    UIView.animate(withDuration: TimeInterval(animationTimeInSeconds), delay: 0, options: [.curveEaseInOut], animations:{
      [weak self] in
      self?.toolTipView.alpha = targetToolTipAlpha
      self?.topLabel.alpha = targetEditingLabelAlpha
      self?.placeholderLabel.alpha = targetLabelAlpha
    }, completion: nil)
  }

  public func animateStateChanges(_ applyChanges: [(_ clTextField: CLTextField?) -> Void], _ completion: ((_ clTextField: CLTextField?) -> Void)?) {
    UIView.animate(withDuration: TimeInterval(animationTimeInSeconds),
                   delay: 0,
                   options: [.curveEaseInOut],
                   animations: {
      [weak self] in
      for applyChange in applyChanges {
        applyChange(self)
      }
    }, completion: {
      [weak self] _ in
      completion?(self)
    })
  }

  public var returnKeyType: UIReturnKeyType {
    get {
      return textField.returnKeyType
    }
    set(returnKeyType) {
      textField.returnKeyType = returnKeyType
      textField.enablesReturnKeyAutomatically = true
    }
  }


  open override func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }

  open override func resignFirstResponder() -> Bool {
    return textField.resignFirstResponder()
  }


  @objc private func textFieldDidChange(_ textField: UITextField) {
    if delegate != nil   {
      delegate?.textFieldDidChange(self)
    }
  }

  public func textFieldShouldReturn(_ textField:UITextField) -> Bool {
    return delegate?.textFieldShouldReturn(self) ?? true
  }

  @objc public func textFieldDidBeginEditing(_ textField: UITextField) {
    setEditingState(true)
    if (delegate != nil) {
      delegate?.textFieldDidBeginEditing(self)
    }
  }

  @objc public func textFieldDidEndEditing(_ textField: UITextField) {
    _hasBeenUsed = true
    setEditingState(false)
    if (delegate != nil) {
      delegate?.textFieldDidEndEditing(self)
    }
  }
  @IBAction func buttonToggleTextVisibilityPressed(_ sender: UIButton) {
    textField.isSecureTextEntry = sender.isSelected
    sender.isSelected = !sender.isSelected
  }

}

// MARK: UITextInput conformance
// Make custom text field support text input without hoop-jumping
@objc extension CLTextField : UITextInput {
  public var hasText: Bool {
    get {
      return textField.hasText
    }
  }

  public func insertText(_ text: String) {
    self.textField.insertText(text)
  }

  public func deleteBackward() {
    self.textField.deleteBackward()
  }

  public func text(in range: UITextRange) -> String? {
    return self.textField.text(in:range)
  }

  public func replace(_ range: UITextRange, withText text: String) {
    textField.replace(range, withText: text)
  }

  public var selectedTextRange: UITextRange? {
    get {
      return textField.selectedTextRange
    }
    set(newSelectedTextRange) {
      textField.selectedTextRange = newSelectedTextRange
    }
  }

  public var markedTextRange: UITextRange? {
    get {
      return textField.markedTextRange
    }
  }

  public var markedTextStyle: [NSAttributedString.Key : Any]? {
    get {
      return textField.markedTextStyle
    }
    set(newMarkedTextStyle) {
      textField.markedTextStyle = newMarkedTextStyle
    }
  }

  public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
    textField.setMarkedText(markedText, selectedRange: selectedRange)
  }

  public func unmarkText() {
    textField.unmarkText()
  }

  public var beginningOfDocument: UITextPosition {
    get {
      return textField.beginningOfDocument
    }
  }

  public var endOfDocument: UITextPosition {
    get {
      return textField.endOfDocument
    }
  }

  public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
    return textField.textRange(from: fromPosition, to: toPosition)
  }

  public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
    return textField.position(from: position, offset: offset)
  }

  public func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
    return textField.position(from: position, in:direction, offset:offset)
  }

  public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
    return textField.compare(position, to:other)
  }

  public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
    return textField.offset(from: from, to: toPosition)
  }

  public var inputDelegate: UITextInputDelegate? {
    get {
      return textField.inputDelegate
    }
    set {
      textField.inputDelegate = newValue
    }
  }

  public var tokenizer: UITextInputTokenizer {
    get {
      return textField.tokenizer
    }
  }

  public func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
    return textField.position(within:range, farthestIn:direction)
  }

  public func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
    return textField.characterRange(byExtending:position, in:direction)
  }

  public func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> UITextWritingDirection {
    return textField.baseWritingDirection(for:position, in:direction)
  }

  public func setBaseWritingDirection(_ writingDirection: UITextWritingDirection, for range: UITextRange) {
    return textField.setBaseWritingDirection(writingDirection, for:range)
  }

  public func firstRect(for range: UITextRange) -> CGRect {
    return textField.firstRect(for:range)
  }

  public func caretRect(for position: UITextPosition) -> CGRect {
    return textField.caretRect(for:position)
  }

  public func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
    return textField.selectionRects(for:range)
  }

  public func closestPosition(to point: CGPoint) -> UITextPosition? {
    return textField.closestPosition(to:point)
  }

  public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
    return textField.closestPosition(to: point, within:range)
  }

  public func characterRange(at point: CGPoint) -> UITextRange? {
    return textField.characterRange(at:point)
  }

}
