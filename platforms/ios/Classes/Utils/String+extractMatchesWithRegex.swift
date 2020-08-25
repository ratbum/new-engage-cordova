//
//  String+extractMatchesWithRegex.swift
//  Engage
//
//  Created by Thomas Lee on 26/09/2019.
//

import Foundation

public extension String {
  func extractMatches(regexPattern: String) -> [String]? {
    var regex: NSRegularExpression
    do {
      regex = try NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
    } catch {
      return nil
    }
    let nsString = self as NSString
    let results = regex.matches(in: self,
                                options: .withTransparentBounds,
                                range: NSMakeRange(0, nsString.length))

    return results.map { nsString.substring(with: $0.range)}
  }
}
