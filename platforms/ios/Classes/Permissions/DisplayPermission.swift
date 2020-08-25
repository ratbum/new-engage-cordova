//
//  DisplayPermission.swift
//  CLEngine
//
//  Created by Thomas Lee on 04/09/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

public class DisplayPermission: NSObject {

  var permission: Permission
  var translator = Translator()

  init(_ permission: Permission) {
    self.permission = permission
    super.init()
  }

  public var isCheckingStatus: Bool {
    return permission.status == .checking
  }

  public var title: String {
    return translator.translate(Constants.titleTranslationKeysMap[permission.kind]!)
  }

  public var icon: UIImage {
    return UIImage(named: Constants.kindStyleKeysMap[permission.kind]!)!
  }

  public func getCustomStyleKeys() -> String! {
    return "permissions_styles " + Constants.kindStyleKeysMap[permission.kind]!
  }

  public var status: PermissionStatus {
    return permission.status
  }

  struct Constants {
    static let kindStyleKeysMap: [PermissionKind: String] = [
      .camera: "permission_camera",
      .crashReport: "permission_error_reporting",
      .photo: "permission_gallery",
      .microphone: "permission_microphone",
      .pushNotification: "permission_notifications",
      .location: "permission_location"
    ]
    static let titleTranslationKeysMap: [PermissionKind: String] = [
      .camera: "permission_camera",
      .crashReport: "permission_crash_reports",
      .photo: "permission_photos",
      .microphone: "permission_microphone",
      .pushNotification: "permission_notifications",
      .location: "permission_location"
    ]
  }

  public func isAuthorized() -> Bool {
    return self.status == .authorized
  }
}
