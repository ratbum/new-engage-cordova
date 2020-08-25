//
//  FormHelpers.swift
//  Engage
//
//  Created by Thomas Lee on 04/10/2019.
//

import Foundation


struct FormHelpers {
  func isValid(email: String) -> Bool {
    do {
      let emailRegex = try NSRegularExpression(pattern:
        "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
          "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
          "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
          "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
          "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
          "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
      let emailIsValid = emailRegex.matches(in: email,
                                            options: .reportCompletion,
                                            range: NSRange(location: 0,
                                                           length: email.count)).count == 1
      return emailIsValid
    } catch {
      return false
    }
  }

  func isValid(password: String) -> Bool {
    return password.count > 7
  }

  func isValid(passwordResetCode: String) -> Bool {
    let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    return passwordResetCode.count == 6 && Set(passwordResetCode).isSubset(of: nums)
  }

  func shouldValidateWhileTyping() -> Bool {
    return Device.create().deviceIdentifierParts.0 > 7
  }
}
