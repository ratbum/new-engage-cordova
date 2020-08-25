//
//  GenderDecorator.swift
//  Engage
//
//  Created by Thomas Lee on 12/11/2019.
//

import Foundation
import CrowdLabDTO
struct GenderDecorator {
  var translator: Translator
  var gender: UserModel.Gender!
  init(translator: Translator, gender: UserModel.Gender) {
    self.translator = translator
    self.gender = gender
  }

  public var name: String {
    get {
      return translator.translate("gender_" + self.gender.rawValue)
    }
  }
}
