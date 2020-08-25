//
//  Permission.swift
//  CLEngine
//
//  Created by Richard Hatherall on 22/08/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

@objc public enum PermissionKind: Int {
  case camera = 1
  case crashReport = 2
  case location = 3
  case microphone = 4
  case photo = 5
  case pushNotification = 6
}

@objc public enum PermissionStatus: Int {
  case notDetermined = 1
  case denied = 2
  case authorized = 3
  case checking = 4
}

@objc public protocol PermissionDelegate {
  func permission(_ permission: Permission, statusChangedTo newStatus: PermissionStatus)
  @objc optional var viewController: UIViewController { get }
}

public protocol PermissionManagerDelegate: PermissionDelegate {}

@objc public protocol Permission {
  var kind: PermissionKind { get }
  var status: PermissionStatus { get }
  var delegate: PermissionDelegate? { get set }
  func requestAuthorization()
  func isAuthorized() -> Bool
}


