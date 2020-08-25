//
//  AsyncFeedbackDisplay.swift
//  CLEngine
//
//  Created by Thomas Lee on 16/01/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation
import CrowdLabDTO

public protocol AsyncFeedbackDisplay {
  func asyncProcessStarted()
  func asyncProcessFinished()
  func asyncProcessFailed(error: FieldErrorCollection?)
  func asyncProcessSucceeded()
}

public protocol BlockingAsyncFeedbackDisplay: AsyncFeedbackDisplay {

}
