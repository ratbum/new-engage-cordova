//
//  ResetPasswordViewController.swift
//  Engage
//
//  Created by Thomas Lee on 03/10/2019.
//

import Foundation
import CrowdLabAPICommands
import CrowdLabAPIAdapter
import OAuthenticator

class ResetPasswordViewController: UIViewController, CLTextFieldDelegate {

  let authenticator = OAuthenticator(tokenStore: TokenStorage(), config: CrowdlabConfig.current.apiConfig.oAuthConfig)
  let translator = Translator()
  @IBOutlet weak var codeField: CLTextField!
  
  @IBOutlet weak var resetPasswordButton: UIButton!
  @IBOutlet weak var passwordField: CLTextField!
  public var emailAddress: String?
  var formHelpers = FormHelpers()
  let config = CrowdlabConfig.current
  let style = CrowdlabConfig.current.style!

  @IBOutlet weak var resetPasswordExplanationTextView: UITextView!

  override func viewDidLoad() {
    resetPasswordButton.backgroundColor = style.interactivePrimaryColour
    codeField.delegate = self
    passwordField.delegate = self
    codeField.keyboardType = .numberPad

    codeField.labelText = translator.translate(TranslationKey.ResetPassword.codeField)
    passwordField.labelText = translator.translate(TranslationKey.ResetPassword.passwordField)
    
    title = translator.translate(TranslationKey.ResetPassword.title)
    resetPasswordExplanationTextView.text = translator.translate(TranslationKey.ResetPassword.explanation)
    resetPasswordButton.setTitle( translator.translate(TranslationKey.ResetPassword.changePassword), for: .normal)

    codeField.returnKeyType = .next
    passwordField.returnKeyType = .done
  }

  func setResetPasswordButtonIsEnabled(_ isEnabled: Bool) {
    resetPasswordButton.isEnabled = isEnabled
    if isEnabled {
      resetPasswordButton.backgroundColor = style.interactivePrimaryColour
    } else {
      resetPasswordButton.backgroundColor = style.interactivePrimaryColourDisabled
    }
  }

  @IBAction func resetPassword(_ sender: Any) {
    let resetPasswordCommand = ResetPasswordCommand(config: config.apiConfig, authenticator: authenticator, code: codeField.text, email: emailAddress!, password: passwordField.text)

    resetPasswordCommand.execute(success: {
      message in
      if message == "" {
        self.goToNextScreen()
      }
    }, failure: {
      error in
      if error is PasswordResetError {
        self.codeField.tooltipText = self.translator.translate(TranslationKey.ResetPassword.invalidCode)
        self.codeField.setValidationColors(forValidity: false)
      }
    })
  }

  private func updateTextFieldValidation(_ textField: CLTextField) {
    switch textField {
    case codeField:
      updateCodeValidation()
    case passwordField:
      updatePasswordValidation()
    default:
      break
    }
    resetPasswordButton.isEnabled = isFormValid()
  }

  private func updateCodeValidation() {
    codeField!.updateValidation(valueCheck: {
      possiblyCode in
      if !formHelpers.isValid(passwordResetCode: possiblyCode) {
        return TranslationKey.ResetPassword.invalidCode
      }
      return nil
    },
    defaultTooltipKey:
      TranslationKey.ResetPassword.codeTooltip)
  }

  private func updatePasswordValidation() {
    passwordField!.updateValidation(valueCheck: {
      possiblyPassword in
      if !formHelpers.isValid(password: possiblyPassword) {
        return TranslationKey.CreateAccount.fieldPasswordErrorTooShort
      }
      return nil
    },
    defaultTooltipKey: TranslationKey.CreateAccount.fieldPasswordTooltip)
  }

  public func textFieldDidBeginEditing(_ textField: CLTextField) {
    textField.setEditingState(true)
    updateTextFieldValidation(textField)
    return // No need to implement`
  }
  public func textFieldDidEndEditing(_ textField: CLTextField) {
    updateTextFieldValidation(textField)
  }

  public func textFieldShouldReturn(_ textField: CLTextField) -> Bool {
    if textField.returnKeyType == UIReturnKeyType.next {
      let nextView = self.view.viewWithTag(textField.tag+1)
      nextView?.becomeFirstResponder()
    } else if textField.returnKeyType == .done {
      _ = textField.resignFirstResponder()
      if isFormValid() {
        self.goToNextScreen()
      }
    }
    return true
  }

  public func textFieldDidChange(_ textField: CLTextField) {
    if !formHelpers.shouldValidateWhileTyping() {
      return
    }

    // Irritatingly, this doesn't work for the password field (unless you've shown its contents),
    // since no tabs can be entered in the first place
    if textField.text.contains("\t") {
      textField.text = textField.text.replacingOccurrences(of: "\t",
                                                           with: "",
                                                           options: .literal,
                                                           range: nil)
      _ = textFieldShouldReturn(textField)
    }
    // Important to check if this is valid before field is exited, since otherwise the continue button will
    // be pretty much always be greyed out.
    resetPasswordButton.isEnabled = isFormValid()

    updateTextFieldValidation(textField)
  }

  func isFormValid() -> Bool {
    return formHelpers.isValid(password: passwordField.text) && formHelpers.isValid(passwordResetCode: codeField.text)
  }

  func goToNextScreen() {
    self.performSegue(withIdentifier: "goToLogin", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let loginVc = segue.destination as? LoginViewController else {
      return
    }
    loginVc.emailAddress = self.emailAddress
  }
  
}
