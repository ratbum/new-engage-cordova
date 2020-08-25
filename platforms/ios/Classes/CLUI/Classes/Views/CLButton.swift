//
//  CLButton.swift
//  CrowdLab
//
//  Created by Thomas Lee on 23/10/2019.
//

import Foundation


public class CLButton: UIButton {

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  func setup() {
    self.layer.cornerRadius = 5.0
    self.clipsToBounds = true
  }

}
