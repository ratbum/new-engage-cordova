//
//  Language.swift
//  Engage
//
//  Created by Thomas Lee on 22/08/2019.
//

import Foundation
import ObjectMapper

public struct Language: Codable, Mappable {

  public init?(map: Map) {
    do {
      id = try map.value("id")
      code = try map.value("code")
      flag = try map.value("flag")
      label = try map.value("label")
      termsPagePresent = try map.value("terms_page_present")
      translations = try map.value("translations")
    } catch {
      return nil
    }
  }

  public mutating func mapping(map: Map) {
    id <- map["id"]
    code <- map["code"]
    flag <- map["flag"]
    label <- map["label"]
    termsPagePresent <- map["terms_page_present"]
    translations <- map["translations"]
  }

  public var id: Int
  public var code: String
  public var label: String
  public var flag: String
  public var termsPagePresent: Bool
  public var translations: [String: String]
}
