//
//  StoryboardHelper.swift
//  CLEngine
//
//  Created by Thomas Lee on 16/08/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation

public class StoryboardHelper {
    
    
  static let _projectStoryboard = storyboardNamed("Storyboard")
  static public let engageVc = _projectStoryboard.instantiateViewController(withIdentifier: "Engage")
  static public func firstRunStoryboard() -> UIStoryboard {
    return storyboardNamed("FirstRun")
  }

  static public func registrationStoryboard() -> UIStoryboard {
    return storyboardNamed("Registration")
  }

  static public func authenticationStoryboard() -> UIStoryboard {
    return storyboardNamed("Authentication")
  }

  static public func projectStoryboard() -> UIStoryboard {
    return _projectStoryboard
  }

  static public func storyboardNamed(_ storyboardName: String) -> UIStoryboard {
    let bundle = Bundle.main // Bundle.init(identifier: "com.crowdlab.CLEngine")
    return UIStoryboard(name: storyboardName, bundle: bundle)
  }
}
