//
//  LoginSession.swift
//  Engage
//
//  Created by Thomas Lee on 20/09/2019.
//

import Foundation
import OAuthenticator
import PromiseKit
import CrowdLabDTO
import CrowdLabRepositories
import CrowdLabAPIAdapter

enum LoginError: Error {
  case wrongUserType
}

struct LoginSession {
  let authenticator = OAuthenticator(tokenStore: TokenStorage(), config: CrowdlabConfig.forCurrentApp().apiConfig.oAuthConfig)

  lazy var userRepo: UserRepo = UserRepo(config: CrowdlabConfig.forCurrentApp().apiConfig, authenticator: self.authenticator)
  lazy var userDefaults = CLUserDefaults.standard
  lazy var tokenStore = TokenStorage()
  init() {
  }

  private var errorCollection: FieldErrorCollection?

  public func checkUserEmail(_ emailAddress:String) -> String? {
    if errorCollection != nil {
      if let projectCodeError = errorCollection!["email"] {
        return projectCodeError.fieldErrorDescriptions.first
      }
    }
    do {
      let emailRegex = try NSRegularExpression(pattern:
        "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
          "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
          "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
          "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
          "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
          "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
      let emailIsValid = emailRegex.matches(in: emailAddress,
                                       options: .reportCompletion,
                                         range: NSRange(location: 0,
                                                          length: emailAddress.count)).count == 1
      if emailIsValid {
        return nil
      }
    } catch { }
    return TranslationKey.CreateAccount.fieldEmailErrorInvalid
  }

  public func checkUserPassword(_ password:String) -> String? {
    let isValid = password.count >= 8
    if isValid {
      return nil
    }
    return TranslationKey.CreateAccount.fieldPasswordErrorTooShort
  }

  public init(userDefaults: CLUserDefaults) {
    self.userDefaults = userDefaults
  }

  public mutating func login(username: String,
                    password: String,
                    success: @escaping () -> Void,
                    failure: @escaping (Error) -> Void) {
    var loginSession = self
    authenticator.waitForValidClientToken().then {
      (_) -> Promise<OAuthToken> in
      return loginSession.authenticator.waitForValidUserToken(username: username,
                                                              password: password)
    }.then {
      (userToken: OAuthToken) -> Promise<Void> in
      loginSession.tokenStore.setToken(userToken)
      loginSession.userRepo.updateToken(userToken)
      return loginSession.userRepo.createDeviceForCurrentUser(device: Device.create().asDeviceModel())
    }.done {_ in
      loginSession.userRepo.getDeviceForCurrentUser().done {
        device in
        loginSession.userDefaults.deviceId = device.id
        loginSession.userDefaults.deviceUUID = device.uuid.uuidString

        loginSession.userRepo.getCurrentUser().done {
          (user: UserModel) -> Void in
          if user.type == UserModel.UserType.staff {
            loginSession.userDefaults.userToken = nil
            loginSession.userDefaults.deviceId = 0
            
            failure(LoginError.wrongUserType)
            return
          }
          loginSession.userDefaults.user = user
          success()
        }.catch {
          error in
          failure(error)
        }
      }.catch {
        error in
        if let fieldErrors = FieldErrorCollection.fromNSError(error as NSError) {
          loginSession.errorCollection = fieldErrors
        }
        failure(error)
      }
    }.catch {
      error in
      if let fieldErrors = FieldErrorCollection.fromNSError(error as NSError) {
        loginSession.errorCollection = fieldErrors
      }
      failure(error)
    }
  }
}
