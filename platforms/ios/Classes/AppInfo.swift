//
//  AppInfo.swift
//  Engage
//
//  Created by Thomas Lee on 14/02/2020.
//

import Foundation

struct AppInfo {
  enum DeploymentType {
    case production
    case debug
  }
  let targetName = Bundle.main.infoDictionary?["TargetName"] as! String
  #if PROD
  let deploymentType: DeploymentType = .production
  #else
  let deploymentType: DeploymentType = .debug
  #endif
}
