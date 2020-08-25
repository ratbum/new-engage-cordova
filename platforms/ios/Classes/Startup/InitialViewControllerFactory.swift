//
//  InitialViewControllerFactory.swift
//  CLEngine
//
//  Created by Richard Hatherall on 02/10/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import UIKit
import Foundation

public struct InitialViewControllerFactory {
  
  init(deepLinkDestination: DeepLinkDestination = .none,
       userDefaults: CLUserDefaults = CLUserDefaults.standard) {
    self.targetDestination = deepLinkDestination
    self.userDefaults = userDefaults
  }

  func createViewControllers() -> [UIViewController] {
    switch targetDestination {
    case .createAccount?:
      let storyboard = StoryboardHelper.registrationStoryboard()
      return [
        createLanguageSelectorViewController(),
        storyboard.instantiateInitialViewController()!
      ]
    case .login?:
       let storyboard = StoryboardHelper.authenticationStoryboard()
       
       return [
         createLanguageSelectorViewController(),
         storyboard.instantiateInitialViewController()!
       ]
    default: // .none
      if needsLanguageSelecting {
        return [createLanguageSelectorViewController()]
      }
      if needsUserDetails {
        let storyboard = StoryboardHelper.registrationStoryboard()
        return [
          storyboard.instantiateViewController(withIdentifier: "ProfileDetails")
        ]
      }
      if !needsRegistration {
        // User has previously logged in; take them straight to app
        let storyboard = StoryboardHelper.projectStoryboard()
        return [storyboard.instantiateInitialViewController()!]
      }

      let storyboard = StoryboardHelper.registrationStoryboard()
      return [storyboard.instantiateInitialViewController()!]
    }
  }

  private let userDefaults: CLUserDefaults
  private var needsLanguageSelecting: Bool {
    return userDefaults.needsLanguageSelecting
  }

  private var needsRegistration: Bool {
    return userDefaults.needsRegistration
  }

  private var needsUserDetails: Bool {
    if let user = CLUserDefaults.standard.user {
      return user.nickname == nil // Route to nickname
    }
    return false
  }

  private var needsAuthentication: Bool {
    return true
  }

  private var targetDestination: DeepLinkDestination!

  private func createLanguageSelectorViewController() -> UIViewController {
    let storyboard = StoryboardHelper.firstRunStoryboard()
    return storyboard.instantiateViewController(withIdentifier: "SelectLanguage")
  }

  public func engageViewController() -> UIViewController {
    return StoryboardHelper.engageVc
  }

}
