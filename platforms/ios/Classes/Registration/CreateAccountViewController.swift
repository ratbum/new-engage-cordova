//
//  CreateAccountViewController.swift
//  CLEngine
//
//  Created by Thomas Lee on 15/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import UIKit
import CrowdLabRepositories
import CrowdLabDTO
import PromiseKit
import OAuthenticator

@objc public class CreateAccountViewController: UIViewController, CLTextFieldDelegate {
  
  public var createAccountSession: CreateAccountSession!
  
  @IBOutlet weak var fieldEmail: CLTextField!
  @IBOutlet weak var fieldPassword: CLTextField!
  @IBOutlet weak var fieldProjectCode: CLTextField!
  
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var orLabel: UILabel!
  @IBOutlet weak var buttonRegister: UIButton!
  @IBOutlet weak var buttonLogin: UIButton!
  
  var invalidDate: Date?
  var translator = Translator()
  let style = CrowdlabConfig.current.style!
  
  let shouldValidateWhileTyping = Device.create().deviceIdentifierParts.0 > 7
  
  public override func viewDidLoad() {
    self.navigationController?.navigationBar.tintColor = style.navigationColour
    buttonRegister.backgroundColor = style.interactivePrimaryColour
    buttonLogin.setTitleColor(style.interactiveSecondaryColour, for: .normal)
    
    createAccountSession = createAccountSession ??
      CreateAccountSession(userDefaults: CLUserDefaults(valueStore: UserDefaults.standard), newUser: nil)
    welcomeLabel.text = translator.translate(TranslationKey.CreateAccount.welcome)
    orLabel.text = translator.translate(TranslationKey.Login.or)
    buttonRegister.setTitle(translator.translate(TranslationKey.CreateAccount.buttonRegister), for: .normal)
    buttonLogin.setTitle(translator.translate(TranslationKey.Login.title), for: .normal)
    
    fieldEmail.delegate = self
    fieldPassword.delegate = self
    fieldProjectCode.delegate = self
    
    fieldEmail.keyboardType = UIKeyboardType.emailAddress
    fieldEmail.labelText = translator.translate(TranslationKey.CreateAccount.fieldEmail)
    fieldPassword.labelText = translator.translate(TranslationKey.CreateAccount.fieldPassword)
    fieldProjectCode.labelText = translator.translate(TranslationKey.CreateAccount.fieldProjectCode)
    
    fieldEmail.tooltipText = translator.translate(TranslationKey.CreateAccount.fieldEmailTooltip)
    fieldPassword.tooltipText = translator.translate(TranslationKey.CreateAccount.fieldPasswordTooltip)
    fieldProjectCode.tooltipText = translator.translate(TranslationKey.CreateAccount.fieldProjectCodeTooltip)
    
    fieldEmail.returnKeyType = UIReturnKeyType.next
    fieldPassword.returnKeyType = UIReturnKeyType.next
    fieldProjectCode.returnKeyType = UIReturnKeyType.done
    
    fieldEmail.textField.accessibilityIdentifier = "email_field"
    fieldPassword.textField.accessibilityIdentifier = "password_field"
    fieldProjectCode.textField.accessibilityIdentifier = "project_code_field"
    
    fieldEmail.tooltipLabel.accessibilityIdentifier = "email_tooltip"
    fieldPassword.tooltipLabel.accessibilityIdentifier = "password_tooltip"
    fieldProjectCode.tooltipLabel.accessibilityIdentifier = "project_code_tooltip"
    
    fieldPassword.buttonToggleTextVisibilityImageEnabled = UIImage(named: "password_eye_hide")
    fieldPassword.buttonToggleTextVisibilityImageDisabled = UIImage(named: "password_eye_show")
    fieldPassword.isPassword = true
    
    setRegisterButtonEnabled(isFormValid())
    fieldEmail.setValidationColors(forValidity: false)
    fieldPassword.setValidationColors(forValidity: false)
    fieldProjectCode.setValidationColors(forValidity: false)
  }
  
  func setRegisterButtonEnabled(_ isEnabled: Bool) {
    DispatchQueue.main.async {
      self.buttonRegister.isEnabled = isEnabled
    }
    if isEnabled {
      DispatchQueue.main.async {
        self.buttonRegister.backgroundColor = self.style.interactivePrimaryColour
      }
    } else {
      DispatchQueue.main.async {
        self.buttonRegister.backgroundColor = self.style.interactivePrimaryColourDisabled
      }
    }
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    title = translator.translate(TranslationKey.CreateAccount.title)
    super.viewWillAppear(animated)
    if createAccountSession.hasErrors {
      updateAllValidation()
      invalidDate = Date()
    }
  }
  
  private func updateEmailValidation() {
    let defaultKey =
    translator.translate(TranslationKey.CreateAccount.fieldEmailTooltip)
    DispatchQueue.main.async {
      self.fieldEmail!.updateValidation(valueCheck: self.createAccountSession.checkUserEmail,
                                 defaultTooltipKey: defaultKey)
    }
  }
  
  private func updatePasswordValidation() {
    let defaultKey =
    translator.translate(TranslationKey.CreateAccount.fieldPasswordTooltip)
    DispatchQueue.main.async {
      self.fieldPassword!.updateValidation(valueCheck: self.createAccountSession.checkUserPassword,
                                    defaultTooltipKey: defaultKey)
    }
  }
  
  private func updateProjectCodeValidation() {
     let defaultKey =
     translator.translate(TranslationKey.CreateAccount.fieldProjectCodeTooltip)
    DispatchQueue.main.async {
      self.fieldProjectCode!.updateValidation(valueCheck: self.createAccountSession.checkProjectCode,
                                       defaultTooltipKey: defaultKey)
    }
  }
  
  public func updateAllValidation() {
    updateEmailValidation()
    updatePasswordValidation()
    updateProjectCodeValidation()
    setRegisterButtonEnabled(isFormValid())
  }
  
  public func textFieldDidBeginEditing(_ textField: CLTextField) {
    DispatchQueue.global(qos: .background).async {
      if textField == self.fieldProjectCode {
        self.setRegisterButtonEnabled(true)
      }
    }
    return // No need to implement
  }
  
  private func isFormValid() -> Bool {
    if invalidDate != nil {
      if invalidDate!.addingTimeInterval(0.1) < Date() {
        _ = self.createAccountSession.popErrorCollection()
      }
    }
    return createAccountSession.checkUserEmail(fieldEmail.text) == nil &&
      createAccountSession.checkUserPassword(fieldPassword.text) == nil &&
      createAccountSession.checkProjectCode(fieldProjectCode.text) == nil
  }
  
  private func updateTextFieldValidation(_ textField: CLTextField) {
    DispatchQueue.global(qos: .background).async {
      switch textField {
      case self.fieldEmail:
        self.updateEmailValidation()
      case self.fieldPassword:
        self.updatePasswordValidation()
      case self.fieldProjectCode:
        self.updateProjectCodeValidation()
      default:
        break
      }
    }
  }
  
  public func textFieldDidEndEditing(_ textField: CLTextField) {
    DispatchQueue.global(qos: .background).async {
      self.updateTextFieldValidation(textField)
      DispatchQueue.main.async {
        self.setRegisterButtonEnabled(self.isFormValid())
      }
    }
  }
  
  public func textFieldShouldReturn(_ textField: CLTextField) -> Bool {
    if textField.returnKeyType == UIReturnKeyType.next {
      let nextView = self.view.viewWithTag(textField.tag+1)
      DispatchQueue.main.async {
        nextView?.becomeFirstResponder()
      }
    } else if textField.returnKeyType == .done {
      DispatchQueue.main.async {
        _ = textField.resignFirstResponder()
      }
      if isFormValid() {
        goToNextScreen()
      }
    }
    return true
  }
  
  public func textFieldDidChange(_ textField: CLTextField) {
    let text = textField.text
    DispatchQueue.global(qos: .background).async {
      if !self.shouldValidateWhileTyping { return }
      // Irritatingly, this doesn't work for the password field (unless you've shown its contents),
      // since no tabs can be entered in the first place
      if text.contains("\t") {
        let newText = text.replacingOccurrences(of: "\t",
        with: "",
        options: NSString.CompareOptions.literal,
        range: nil)
        DispatchQueue.main.async {
          textField.text = newText
        }
        _ = self.textFieldShouldReturn(textField)
      }
      self.updateTextFieldValidation(textField)
      DispatchQueue.main.async {
        self.setRegisterButtonEnabled(self.isFormValid())
      }
    }
  }
  
  private func goToNextScreen() {
    
    let email = fieldEmail.text.trimmingCharacters(in:
      NSCharacterSet.whitespacesAndNewlines)
    let password = fieldPassword.text.trimmingCharacters(in:
      NSCharacterSet.whitespacesAndNewlines)
    let projectCode = fieldProjectCode.text.trimmingCharacters(in:
      NSCharacterSet.whitespacesAndNewlines)
    
    createAccountSession.user = UserModel.createBasicUser(email: email, password: password , projectCode: projectCode, language: "en")
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: "goToTermsAndConditions", sender: self)
    }
  }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToTermsAndConditions" {
      let termsVC = segue.destination as! TermsConditionsViewController
      termsVC.createAccountSession = createAccountSession
    }
  }
  
  @IBAction func buttonRegisterPressed(_ sender: UIButton) {
    goToNextScreen()
  }
  
  @IBAction func buttonLoginPressed(_ sender: UIButton) {
    self.performSegue(withIdentifier: "goToAuthentication", sender: self)
  }
}
