//
//  DeepLinkDestination.swift
//  CLEngine
//
//  Created by Thomas Lee on 04/02/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation

public enum DeepLinkDestination: String {
  case none = ""
  case languageSelect = "languageSelect"
  case permissionsSetup = "permissionsSetup"
  case createAccount = "createAccount"
  case login = "login"
  case taskList = "taskList"
}
