//
//  TokenStorage.swift
//  CrowdLab
//
//  Created by Thomas Lee on 04/11/2019.
//

import Foundation
import OAuthenticator

struct TokenStorage: TokenStore {
  func getToken() -> OAuthToken? {
    print("Get token: " + (CLUserDefaults.standard.userToken?.toJSON() ?? "nil"))
    return CLUserDefaults.standard.userToken
  }
  func setToken(_ token: OAuthToken) {
    if token.accessType == .client {
      return
    }
    print("Set token: ", token)
    CLUserDefaults.standard.userToken = token
  }
}
