//
//  CLTextFieldDelegate.swift
//  CLUIiOS
//
//  Created by Thomas Lee on 10/10/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation
import UIKit

public protocol CLTextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: CLTextField)
  func textFieldDidEndEditing(_ textField: CLTextField)
  func textFieldShouldReturn(_ textField: CLTextField) -> Bool
  func textFieldDidChange(_ textField: CLTextField)
}
