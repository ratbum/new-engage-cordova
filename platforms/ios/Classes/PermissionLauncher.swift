//
//  PermissionLauncher.swift
//  CLEngine
//
//  Created by Thomas Lee on 02/10/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol LaunchablePermission {
  var permissionTitleTranslationKey: String { get }
  var permissionDescriptionTranslationKey: String { get }
}

@objc public class PermissionLauncher: NSObject {

  @objc static public func alertUserPermissionNotGranted(permission: LaunchablePermission,
                                                     viewController: UIViewController,
                                                  completionHandler: ((Bool) -> Void)?) {
    let alertController = UIAlertController(
      title: Translator().translate(permission.permissionTitleTranslationKey),
      message: Translator().translate(permission.permissionDescriptionTranslationKey),
      preferredStyle: .alert)
    let denyPermission = UIAlertAction(title: Translator().translate(TranslationKey.Global.cancel),
                                       style: .default, handler: {
      _ in
      completionHandler?(false)
    })
    let openAppPermissionsSettings = UIAlertAction(
      title: Translator().translate(TranslationKey.Permissions.showSettings),
      style: .default) {
      _ in
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: {
          _ in
          completionHandler?(true)
        })
      }
    }
    alertController.addAction(denyPermission)
    alertController.addAction(openAppPermissionsSettings)

    DispatchQueue.main.async { [weak viewController] in
      viewController?.present(alertController, animated: true) {}
    }
  }
}
