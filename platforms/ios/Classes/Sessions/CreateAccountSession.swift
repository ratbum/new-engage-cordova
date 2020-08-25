//
//  AccountCreationSession.swift
//  CLEngine
//
//  Created by Thomas Lee on 07/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import CoreData
import OAuthenticator
import CrowdLabDTO
import CrowdLabRepositories
import CrowdLabAPIAdapter
import PromiseKit

public class CreateAccountSession {

  // Add update to delegate calls
  var tokenStore = TokenStorage()
  private var authenticator: OAuthenticator
  var userRepo: UserRepo!
  public var user: UserModel
  public var targetProjectCode = ""
  private var userDefaults: CLUserDefaults
  public var asyncFeedbackDisplay: AsyncFeedbackDisplay?
  private var errorCollection: FieldErrorCollection?
  private var device: DeviceModel!
  private var formHelpers = FormHelpers()


  public func popErrorCollection() -> FieldErrorCollection? {
    if errorCollection == nil {
      return nil
    }
    let tmpErrorCollection = errorCollection!
    errorCollection = nil
    return tmpErrorCollection
  }

  public var hasErrors: Bool {
    return errorCollection != nil
  }

  public var hasUserAcceptedTerms: Bool? {
    get {
      return user.acceptedTerms ?? false
    }
    set(accepted) {
      user.acceptedTerms = accepted
    }
  }

  public init(userDefaults: CLUserDefaults, newUser: UserModel?) {
    print(APIKeys.apiUrl)
    self.userDefaults = userDefaults
    authenticator = OAuthenticator(tokenStore: TokenStorage(), config: CrowdlabConfig.current.apiConfig.oAuthConfig)
    userRepo = UserRepo(config: CrowdlabConfig.current.apiConfig, authenticator: authenticator)
    if newUser != nil {
      self.user = newUser!
    } else {
      self.user = UserModel()
    }
  }

  public func checkUserEmail(_ emailAddress:String) -> String? {
    if errorCollection != nil {
      if let projectCodeError = errorCollection!["email"] {
        return projectCodeError.fieldErrorDescriptions.first
      }
    }
    if formHelpers.isValid(email: emailAddress) {
      return nil
    }
    return TranslationKey.CreateAccount.fieldEmailErrorInvalid
  }

  public func checkUserPassword(_ password:String) -> String? {
    let isValid = formHelpers.isValid(password: password)
    if (isValid) {
      return nil
    }
    return TranslationKey.CreateAccount.fieldPasswordErrorTooShort
  }

  public func checkProjectCode(_ projectCode:String) -> String? {
    if errorCollection != nil {
      if let projectCodeError = errorCollection!["project_code"] {
        return projectCodeError.fieldErrorDescriptions.first
      }
    }
    let isValid = projectCode.count >= 3
    if (isValid) {
      return nil
    }
    return TranslationKey.CreateAccount.fieldProjectCodeErrorNotRecognised
  }

  public func checkFullName(_ name:String) -> String? {
    let isValid = name.count > 0
    if (isValid) {
      return nil
    }
    return TranslationKey.CreateAccount.fieldFullnameErrorEmpty
  }

  public func checkUserNickname(_ nickname:String) -> String? {
    let isValid = nickname.count > 0
    if (isValid) {
      return nil
    }
    return TranslationKey.CreateAccount.fieldNicknameErrorEmpty
  }

  public func checkUserDateOfBirth(_ dob: Date) -> String? {
    let oneHundredAndFiftyYearsAgo = Date().addingTimeInterval(TimeInterval(exactly: Int64(-4730400000))!)

    let isValid = dob > oneHundredAndFiftyYearsAgo && dob < Date.yesterday
    if isValid {
      return nil
    }
    return ""
  }

  public func checkUserAge(_ strAge: String) -> String? {
    let age = Int(strAge) ?? 0
    if (age <= 0) {
      return TranslationKey.CreateAccount.fieldAgeTooYoung
    }
    if age >= 150 {
      return TranslationKey.CreateAccount.fieldAgeTooOld
    }
    return nil
  }

  public func isCompleted() -> Bool {
    var isMissingSomething = false
    isMissingSomething = isMissingSomething || user.email == nil || user.email == ""
    isMissingSomething = isMissingSomething || user.name == nil || user.nickname == ""
    isMissingSomething = isMissingSomething || user.nickname == nil || user.nickname == ""
    isMissingSomething = isMissingSomething || user.password == nil || user.password == ""
    isMissingSomething = isMissingSomething || user.bornOn == nil
    isMissingSomething = isMissingSomething || !hasUserAcceptedTerms!
    return !isMissingSomething
  }

  public func saveUserDetails(name: String?,
                              nickname: String?,
                              gender: UserModel.Gender?,
                              dob: Date?,
                              success: @escaping () -> Void,
                              failure: @escaping (Error) -> Void) {
    var user = UserModel()
    user.name = name
    user.nickname = nickname
    user.gender = gender ?? UserModel.Gender.doNotWishToAnswer
    user.bornOn = dob

    authenticator.waitForValidUserToken(getUserToken()!).done {
      (token: OAuthToken) -> Void in

      self.userRepo.updateCurrent(user: user).then {
        (user: UserModel) -> Promise<UserModel> in
        self.userDefaults.user = user
        return Promise<UserModel>() {
          seal in
          seal.fulfill(user)
        }
      }.done {_ in
        success()
      }.catch {
        error in
        print(error)
        failure(error)
      }
    }.catch {
      error in
      print(error)
      failure(error)
    }

  }

  public func uploadAvatar(pngData: Data,
                           success: @escaping () -> Void,
                           fail: @escaping (_ errors: FieldErrorCollection?) -> Void) {


    authenticator.waitForValidUserToken(getUserToken()!).done {
      (token: OAuthToken) -> Void in
      self.userRepo.uploadAvatarForCurrentUser(avatarPngData: pngData).done {
        user in
        self.userDefaults.user = user
        success()
      }.catch {
        error in
        fail(nil)
      }
    }.catch {
      error in
      fail(nil)
    }
  }

  func createAccount(success: @escaping (UserModel, OAuthToken) -> Void,
                     failure: @escaping (Error) -> Void) {
    asyncFeedbackDisplay?.asyncProcessStarted()

    let d = Device.create()
    device = DeviceModel(id: d.id ?? 1,
                         uuid: d.uuid,
                         manufacturer: d.manufacturer,
                         model: d.model,
                         osVersion: d.osVersion,
                         platform: d.platform,
                         pushToken: d.pushToken,
                         appVersion: "0.0.0")!
    userRepo.register(email: user.email!,
      password: user.password!,
      projectCode: user.projectCode!,
      language: user.language ?? "en",
      device: device).then {
        (result: (user: UserModel, token: OAuthToken)) -> Promise<(UserModel, OAuthToken)> in
        self.userDefaults.userToken = result.token
        self.user = result.user
        var userUpdates = UserModel()
        userUpdates.acceptedTerms = true
        let devicePromise = self.userRepo.getDeviceForCurrentUser().then {
          (device: DeviceModel) -> Promise<UserModel> in
          self.user.device = device
          self.userDefaults.deviceId = device.id
          self.userDefaults.deviceUUID = device.uuid.uuidString
          return Promise<UserModel>() {
            seal in
            seal.fulfill(self.user)
          }
        }
        return devicePromise.then {
          userWithDevice in
          return self.userRepo.updateCurrent(user: userUpdates).then {
            (user: UserModel) -> Promise<(UserModel, OAuthToken)> in
            var varResult = result
            varResult.user.acceptedTerms = true
            return Promise<(UserModel, OAuthToken)> {
              seal in
              seal.fulfill(varResult)
            }
          }
        }

    }.done {
      (result: (user: UserModel, token: OAuthToken)) -> Void in
      self.asyncFeedbackDisplay?.asyncProcessSucceeded()
      self.userDefaults.user = result.user
      success(result.user, result.token)
    }.catch {
      error in
      self.errorCollection = error as? FieldErrorCollection
      self.asyncFeedbackDisplay?.asyncProcessFailed(error: self.errorCollection)
      failure(error)
    }
  }

  func getUserToken() -> OAuthToken? {
    return CLUserDefaults.standard.userToken
  }

  public func tokenDidUpdate(token: OAuthToken) {
    CLUserDefaults.standard.userToken = token
  }
}
