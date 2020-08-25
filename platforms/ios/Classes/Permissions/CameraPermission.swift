//
//  CameraPermission.swift
//  CLEngine
//
//  Created by Richard Hatherall on 22/08/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import AVFoundation

@objc public class CameraPermission: NSObject, Permission, LaunchablePermission {
  public var permissionTitleTranslationKey = TranslationKey.Permissions.camera
  public var permissionDescriptionTranslationKey = TranslationKey.Permissions.camera

  public var isCheckingStatus = false
  public let kind: PermissionKind = .camera
  public var status: PermissionStatus {
    if isCheckingStatus {
      return .checking
    }
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .restricted: return .denied
    case .authorized: return .authorized
    case .denied: return .denied
    default: return .notDetermined
    }
  }
  public weak var delegate: PermissionDelegate?

  public func requestAuthorization() {
    isCheckingStatus = true
    AVCaptureDevice.requestAccess(for: .video) { _ in
      DispatchQueue.main.async { [weak self] in
        self?.isCheckingStatus = false
        self?.delegate?.permission(self!, statusChangedTo: self!.status)
      }
    }
  }

  public func requestForImmediateUse(callback: @escaping (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .video) { status in
      callback(status)
    }
  }

  @objc public func isAuthorized() -> Bool {
    return self.status == .authorized
  }


}
