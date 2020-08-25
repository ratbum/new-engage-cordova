//
//  WebTokenHandler.swift
//  CrowdLab
//
//  Created by Thomas Lee on 26/11/2019.
//

import Foundation
import NotificationCenter
import OAuthenticator
import PromiseKit

@objc public class WebTokenHandler: NSObject {
  var authenticator: OAuthenticator!
  var numberOfOutstandingRequests = 0

  init(oAuthenticator: OAuthenticator) {
    super.init()
    self.authenticator = oAuthenticator
    NotificationCenter.default.addObserver(self, selector: #selector(WebTokenHandler.tokenRequest(notification:)),
                                           name: NSNotification.Name(rawValue: "CLTokenRequest"), object: nil)
  }

  @objc func tokenRequest(notification: NSNotification) {
    guard let token = CLUserDefaults.standard.userToken else {
      return
    }
    numberOfOutstandingRequests += 1
    if (numberOfOutstandingRequests == 1) {
      self.authenticator.waitForValidUserToken(token).done {
        (token: OAuthToken) -> Void in
        var i = self.numberOfOutstandingRequests
        while (i > 0) {
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CLTokenRequestFulfilled"),
                                        object: token.accessToken)
          i = i - 1
        }
        self.numberOfOutstandingRequests = 0
      }.catch {
        error in
        var i = self.numberOfOutstandingRequests
        while (i > 0) {
          NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CLTokenRequestFulfilled"),
                                        object: nil)
          i = i - 1
        }
        self.numberOfOutstandingRequests = 0
      }
    }
  }

  @objc public static func create() -> WebTokenHandler {
    return WebTokenHandler(oAuthenticator: OAuthenticator(tokenStore: TokenStorage(),
                                                          config: CrowdlabConfig.current.apiConfig.oAuthConfig))
  }
}
