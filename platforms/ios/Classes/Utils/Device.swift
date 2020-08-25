//
//  Device.swift
//  Engage
//
//  Created by Thomas Lee on 18/09/2019.
//

import Foundation

struct Device {
  var id: Int?
  let uuid: UUID
  let platform = "ios"
  let manufacturer = "apple"
  let model: String
  let osVersion: String
  let appVersion: String
  var pushToken: String?

  var deviceIdentifierParts: (Int, Int) {
    get {
      guard let parts = model.extractMatches(regexPattern: "\\d+") else {
        return (0, 0)
      }
      return (Int(parts.first!)!, Int(parts.last!)!)
    }
  }

  init(uuid: UUID, model: String, osVersion: String, appVersion: String, pushToken: String?) {
    self.uuid = uuid
    self.model = model
    self.osVersion = osVersion
    self.appVersion = appVersion
    self.pushToken = pushToken
  }

  public static func create() -> Device {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    let d = Device(uuid: UIDevice.current.identifierForVendor!,
                   model: identifier,
                   osVersion: UIDevice.current.systemVersion,
                   appVersion: (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0.0.0",
                   pushToken: nil)
    return d
  }
}
