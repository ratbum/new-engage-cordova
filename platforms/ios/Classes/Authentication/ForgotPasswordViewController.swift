//
//  ForgotPasswordViewController.swift
//  Engage
//
//  Created by Thomas Lee on 03/10/2019.
//

import Foundation
import CrowdLabAPICommands
import CrowdLabDTO
import CrowdLabAPIAdapter
import OAuthenticator

class ForgotPasswordViewController: UIViewController, CLTextFieldDelegate {

  let translator = Translator()
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var forgotPasswordExplanationTextView: UITextView!
  @IBOutlet weak var emailField: CLTextField!
  @IBOutlet weak var requestResetButton: UIButton!
  let formHelpers = FormHelpers()
  let style = CrowdlabConfig.current.style!
  var shouldValidateWhileTyping: Bool!
  var adapter: CLAPIAdapter
  let authenticator = OAuthenticator(tokenStore: TokenStorage(), config: CrowdlabConfig.current.apiConfig.oAuthConfig)


  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    adapter = CLAPIAdapter(configuration: CrowdlabConfig.current.apiConfig)
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder: NSCoder) {
    adapter = CLAPIAdapter(configuration: CrowdlabConfig.current.apiConfig)
    super.init(coder: coder)
  }

  public var emailAddress: String?

  override func viewDidLoad() {
    var contentSize = scrollView.frame.size
    contentSize.height += 1
    scrollView.contentSize = contentSize
    requestResetButton.backgroundColor = style.interactivePrimaryColour
    shouldValidateWhileTyping = formHelpers.shouldValidateWhileTyping()
    requestResetButton.tintColor = style.interactivePrimaryColour
    emailField.keyboardType = .emailAddress
    emailField.delegate = self
    emailField.returnKeyType = .done

    emailField.labelText = translator.translate(TranslationKey.CreateAccount.fieldEmail)
    
    
    title = translator.translate(TranslationKey.ForgotPassword.title)
    forgotPasswordExplanationTextView.text = translator.translate(TranslationKey.ForgotPassword.explanation)
    requestResetButton.setTitle( translator.translate(TranslationKey.ForgotPassword.sendCode), for: .normal) 

    emailField.setValidationColors(forValidity: false)
    emailField.isOpaque = false
  }

  func setRequestPasswordButtonIsEnabled(_ isEnabled: Bool) {
    requestResetButton.isEnabled = isEnabled
    if isEnabled {
      requestResetButton.backgroundColor = style.interactivePrimaryColour
    } else {
      requestResetButton.backgroundColor = style.interactivePrimaryColourDisabled
    }
  }

  public func textFieldDidChange(_ textField: CLTextField) {
    if !shouldValidateWhileTyping { return }

    if textField.text.contains("\t") {
      textField.text = textField.text.replacingOccurrences(of: "\t",
                                                           with: "",
                                                           options: NSString.CompareOptions.literal,
                                                           range: nil)
      _ = textField.resignFirstResponder()
    }
    updateValidation(withFieldErrors: nil)
    setRequestPasswordButtonIsEnabled(isFormValid())
  }

  override func viewWillAppear(_ animated: Bool) {
    if emailAddress != nil {
      emailField.text = emailAddress!
      emailField.setEditingState(false)
      emailAddress = nil
    }
    setRequestPasswordButtonIsEnabled(shouldValidateWhileTyping && isFormValid())
  }

  func updateValidation(withFieldErrors fieldErrors: FieldErrorCollection?) {

    self.emailField.updateValidation(valueCheck: {_ in
      if fieldErrors != nil {
        for fieldError in fieldErrors! {
          if fieldError.fieldName == "email" {
            return fieldError.fieldErrorDescriptions[0]
          }
        }
      }
      let emailIsValid = formHelpers.isValid(email: self.emailField.text)
      if !emailIsValid {
        return TranslationKey.CreateAccount.fieldEmailErrorInvalid
      }
      if !self.emailField.hasBeenUsed {
        return TranslationKey.CreateAccount.fieldEmailTooltip
      }
      return nil
    }, defaultTooltipKey: TranslationKey.CreateAccount.fieldEmailTooltip)
    self.emailField.setNeedsDisplay()
  }

  func textFieldDidBeginEditing(_ textField: CLTextField) {
    textField.setEditingState(true)
    updateValidation(withFieldErrors: nil)

    if shouldValidateWhileTyping {
      requestResetButton.isEnabled = true
    }
  }

  public func textFieldDidEndEditing(_ textField: CLTextField) {
    updateValidation(withFieldErrors: nil)
    setRequestPasswordButtonIsEnabled(isFormValid())
  }

  public func textFieldShouldReturn(_ textField: CLTextField) -> Bool {
    _ = textField.resignFirstResponder()
    textField.setEditingState(false)
    if isFormValid() {
      requestReset(self)
    }
    return true
  }

  @IBAction func requestReset(_ sender: Any) {
    emailField.hasBeenUsed = true
    emailField.setEditingState(false)
    let passwordResetCommand = ForgotPasswordCommand(config: CrowdlabConfig.current.apiConfig, authenticator: authenticator,
                                                     email: emailField.text)
    passwordResetCommand.execute(success: {
      _ in
      self.goToNextScreen()
    }, failure: {
      error in
    })
  }

  private func isFormValid() -> Bool {
    return formHelpers.isValid(email: emailField.text)
  }

  func goToNextScreen() {
    self.performSegue(withIdentifier: "goToSetPassword", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let resetPasswordVc = segue.destination as? ResetPasswordViewController else {
      return
    }
    resetPasswordVc.emailAddress = emailField.text
  }

}
