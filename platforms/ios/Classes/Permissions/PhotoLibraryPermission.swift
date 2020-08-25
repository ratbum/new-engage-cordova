//
//  PhotoLibraryPermission.swift
//  CLEngine
//
//  Created by Thomas Lee on 30/08/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import Photos

@objc public class PhotoLibraryPermission: NSObject, Permission, LaunchablePermission {
  public let permissionTitleTranslationKey = TranslationKey.Permissions.photoLibrary
  public let permissionDescriptionTranslationKey = TranslationKey.Permissions.photoLibrary

  private var isCheckingStatus = false
  public var kind: PermissionKind = .photo
  public var status: PermissionStatus {
    if isCheckingStatus {
      return .checking
    }
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized: return .authorized
    case .denied: return .denied
    case .notDetermined: return .notDetermined
    case .restricted: return .denied
    @unknown default:
      return .denied
    }
  }
  public weak var delegate: PermissionDelegate?

  public func requestAuthorization() {
    isCheckingStatus = true
    PHPhotoLibrary.requestAuthorization { _ in
      DispatchQueue.main.async { [weak self] in
        self?.isCheckingStatus = false
        self?.delegate?.permission(self!, statusChangedTo: self!.status)
      }
    }
  }

  public func requestForImmediateUse(callback: @escaping (Bool) -> Void) {
    PHPhotoLibrary.requestAuthorization { status in
      callback(status == .authorized)
    }
  }

  @objc public func isAuthorized() -> Bool {
    return self.status == .authorized
  }

}
