//
//  LoginViewController.swift
//  Engage
//
//  Created by Thomas Lee on 20/09/2019.
//

import UIKit
import OAuthenticator


class LoginViewController: UIViewController, CLTextFieldDelegate {

  @IBOutlet weak var emailTextField: CLTextField!
  @IBOutlet weak var passwordTextField: CLTextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var registerButton: UIButton!
  @IBOutlet weak var orLabel: UILabel!
  @IBOutlet weak var forgotPasswordButton: UIButton!
  @IBOutlet weak var welcomeLabel: UILabel!

  public var emailAddress: String?
  public var password: String?
  var translator = Translator()
  var loginSession = LoginSession(userDefaults: CLUserDefaults.standard)
  var blockingView: CLProgressOverlay?
  var formHelpers = FormHelpers()
  let style = CrowdlabConfig.current.style!

  override func viewDidLoad() {
    super.viewDidLoad()
    forgotPasswordButton.tintColor = style.interactiveSecondaryColour
    
    registerButton.tintColor = style.interactiveSecondaryColour
    registerButton.setTitle(translator.translate(TranslationKey.CreateAccount.title), for: .normal)
    orLabel.text = translator.translate(TranslationKey.Login.or)

    emailTextField.keyboardType = .emailAddress
    title = translator.translate(TranslationKey.Login.title)

    welcomeLabel.text = translator.translate(TranslationKey.Login.welcome)
    emailTextField.labelText = translator.translate(TranslationKey.CreateAccount.fieldEmail)
    passwordTextField.labelText = translator.translate(TranslationKey.CreateAccount.fieldPassword)

    emailTextField.delegate = self
    passwordTextField.delegate = self

    emailTextField.returnKeyType = .next
    passwordTextField.returnKeyType = .done
    passwordTextField.isPassword = true
    forgotPasswordButton.setTitle(translator.translate(TranslationKey.ForgotPassword.title), for: .normal)
    loginButton.setTitle(translator.translate(TranslationKey.Login.title), for: .normal)
    setLoginButtonIsEnabled(isFormValid())

    emailTextField.setValidationColors(forValidity: false)
    passwordTextField.setValidationColors(forValidity: false)
    
  }

  func setLoginButtonIsEnabled(_ isEnabled: Bool) {
    DispatchQueue.main.async {
      self.loginButton.isEnabled = isEnabled
    }
    if isEnabled {
      DispatchQueue.main.async {
        self.loginButton.backgroundColor = self.style.interactivePrimaryColour
      }
    } else {
      DispatchQueue.main.async {
        self.loginButton.backgroundColor = self.style.interactivePrimaryColourDisabled
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    if emailAddress != nil {
      emailTextField.text = emailAddress!
      emailTextField.setEditingState(false)
    }
    if password != nil {
      passwordTextField.text = password!
      passwordTextField.setEditingState(false)
    }
    if (emailAddress != nil && password != nil) {
      goToNextScreen()
    }
  }

  @IBAction func loginButtonPressed(_ sender: Any) {
    goToNextScreen()
  }

  private func updateTextFieldValidation(_ textField: CLTextField) {
    DispatchQueue.global(qos: .background).async {
      switch textField {
      case self.emailTextField:
        self.updateEmailValidation()
      case self.passwordTextField:
        self.updatePasswordValidation()
      default:
        break
      }
      DispatchQueue.main.async {
        self.setLoginButtonIsEnabled(self.isFormValid())
      }
    }
  }

  private func updateEmailValidation() {
    let defaultKey = translator.translate(TranslationKey.CreateAccount.fieldEmailTooltip)
    DispatchQueue.main.async {
      self.emailTextField!.updateValidation(valueCheck: self.loginSession.checkUserEmail,
                                     defaultTooltipKey: defaultKey)
    }
  }

  private func updatePasswordValidation() {
    let defaultKey = translator.translate(TranslationKey.CreateAccount.fieldPasswordTooltip)
    DispatchQueue.main.async {
      self.passwordTextField!.updateValidation(valueCheck: self.loginSession.checkUserPassword,
                                        defaultTooltipKey: defaultKey)
    }
  }

  public func textFieldDidBeginEditing(_ textField: CLTextField) {
    textField.setEditingState(true)
    return // No need to implement`
  }
  public func textFieldDidEndEditing(_ textField: CLTextField) {
    updateTextFieldValidation(textField)
    setLoginButtonIsEnabled(isFormValid())
  }

  public func textFieldShouldReturn(_ textField: CLTextField) -> Bool {
    if textField.returnKeyType == UIReturnKeyType.next {
      let nextView = self.view.viewWithTag(textField.tag+1)
      DispatchQueue.main.async {
        nextView?.becomeFirstResponder()
      }
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
    setLoginButtonIsEnabled(isFormValid())
    updateTextFieldValidation(textField)
  }

  private func isFormValid() -> Bool {
    return loginSession.checkUserEmail(emailTextField.text) == nil &&
      loginSession.checkUserPassword(passwordTextField.text) == nil
  }

  private func goToNextScreen() {
    let email = emailTextField.text.trimmingCharacters(in:
      NSCharacterSet.whitespacesAndNewlines)
    let password = passwordTextField.text.trimmingCharacters(in:
      NSCharacterSet.whitespacesAndNewlines)
    self.blockingView = CLProgressOverlay(targetSuperview: self.view)
    loginSession.login(username: email,
                       password: password,
                       success: {
                        self.blockingView?.removeFromSuperview()
                        self.blockingView = nil
                        self.performSegue(withIdentifier: "goToProjectLoading", sender: self)
    }, failure: {
      error in
      self.blockingView?.removeFromSuperview()
      self.blockingView = nil
      switch error {
      case OAuthTokenError.invalidToken:
        self.emailTextField.tooltipText = self.translator.translate(TranslationKey.Login.loginFail)
        self.emailTextField.setValidationColors(forValidity: false)
      case LoginError.wrongUserType:
        self.emailTextField.tooltipText = self.translator.translate( TranslationKey.Login.wrongUserType)
        self.emailTextField.setValidationColors(forValidity: false)
      default:
        self.emailTextField.tooltipText = self.translator.translate( TranslationKey.Login.loginFail)
        self.emailTextField.setValidationColors(forValidity: false)

      }
    })
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    guard let forgotPasswordVc = segue.destination as? ForgotPasswordViewController else {
      return
    }
    forgotPasswordVc.emailAddress = emailTextField.text
  }
}
