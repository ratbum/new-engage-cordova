//
//  Device+deviceModel.swift
//  Engage
//
//  Created by Thomas Lee on 20/09/2019.
//

import Foundation
import CrowdLabDTO

extension Device {
  public func asDeviceModel() -> DeviceModel {
    return DeviceModel(id: self.id ?? 0,
                       uuid: self.uuid,
                       manufacturer: self.manufacturer,
                       model: self.model,
                       osVersion: self.osVersion,
                       platform: self.platform,
                       pushToken: self.pushToken ?? "empty",
                       appVersion: self.appVersion)!
  }
}
