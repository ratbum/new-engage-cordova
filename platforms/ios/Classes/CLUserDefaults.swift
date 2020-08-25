//
//  CLUserDefaults.swift
//  CLEngine
//
//  Created by Richard Hatherall on 31/08/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import OAuthenticator
import CrowdLabDTO

public protocol KeyObjectCoding {
  func object(forKey defaultName: String) -> Any?
  func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: KeyObjectCoding {}

@objcMembers public class CLUserDefaults: NSObject {

  struct Keys {
    static let selectedLanguageCode = "LanguageHasAlreadyBeenChosen"
    static let lastUserSignedInEmailAddress = "LastSignedInUser"
    static let userToken = "UserToken"
    static let deviceId = "DeviceId"
    static let deviceUUID = "DeviceUUID"
    static let user = "User"
  }

  public static let standard = CLUserDefaults(valueStore: UserDefaults.standard)
  let valueStore: KeyObjectCoding

  public init(valueStore: KeyObjectCoding) {
    self.valueStore = valueStore
  }

  public var lastUserSignedInEmailAddress: String? {
    get {
      return valueStore.object(forKey: Keys.lastUserSignedInEmailAddress) as? String
    }
    set {
      valueStore.set(newValue, forKey: Keys.lastUserSignedInEmailAddress)
    }
  }

  public var needsLanguageSelecting: Bool {
    return valueStore.object(forKey: Keys.selectedLanguageCode) == nil
  }

  public var needsRegistration: Bool {
    return userToken == nil && deviceId == 0
  }

  public var selectedLanguageCode: String {
    get {
      return valueStore.object(forKey: Keys.selectedLanguageCode) as? String ?? "en"
    }
    set {
      valueStore.set(newValue, forKey: Keys.selectedLanguageCode)
    }
  }

  public var user: UserModel? {
    get {
      guard let tmpUser = valueStore.object(forKey: Keys.user) as? String else {
        return nil
      }
      return UserModel.fromJSON(tmpUser)
    }
    set(user) {
      valueStore.set(user?.toJSON(), forKey: Keys.user)
    }
  }

  @objc public func deleteUser() {
    valueStore.set(nil, forKey: Keys.user)
  }

  @objc public func deleteUserToken() {
    valueStore.set(nil, forKey: Keys.userToken)
  }
  
  @objc public func deleteDeviceUUID() {
    valueStore.set(nil, forKey: Keys.deviceUUID)
  }

  public var userToken: OAuthToken? {
    get {
      guard let tokenString = valueStore.object(forKey: Keys.userToken) as? String else {
        return nil
      }
      return OAuthToken.fromJSON(tokenString)
    }
    set(token) {
      valueStore.set(token?.toSnakeCasedJSON(), forKey: Keys.userToken)
    }
  }

  public var deviceId: Int {
    get {
      return valueStore.object(forKey: Keys.deviceId) as? Int ?? 0
    }
    set(dId) {
      valueStore.set(dId, forKey: Keys.deviceId)
    }
  }

  public var deviceUUID: String {
    get {
      return valueStore.object(forKey: Keys.deviceUUID) as? String ?? ""
    }
    set(dId) {
      valueStore.set(dId, forKey: Keys.deviceUUID)
    }
  }
}
