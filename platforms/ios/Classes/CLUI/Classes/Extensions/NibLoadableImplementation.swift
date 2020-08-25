//
//  NibLoadable.swift
//  CLUI
//
//  Created by Thomas Lee on 04/10/2018.
//  Copyright © 2018 Thomas Lee. All rights reserved.
//

import Foundation
import UIKit

public extension NibLoadable where Self: UIView {

  static var nibName: String {
    // defaults to the name of the class implementing this protocol.
    return String(String(describing: Self.self).split(separator: "<")[0])
  }

  static var nib: UINib {
    let bundle = Bundle(for: Self.self)
    return UINib(nibName: Self.nibName, bundle: bundle)
  }

  func setupFromNib() {
    guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
      fatalError("Error loading \(self) from nib")
    }
    addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false

    if #available(iOS 11.0, *) {
      // Safe area layout guide is unavailable before iOS 11
      self.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                    constant: 0).isActive = true
      self.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor,
                                constant: 0).isActive = true
      self.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                     constant: 0).isActive = true
      self.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                   constant: 0).isActive = true
    } else {
      self.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                   constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor,
                                  constant: 0).isActive = true
      self.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                    constant: 0).isActive = true
      self.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                  constant: 0).isActive = true
    }
  }
}
