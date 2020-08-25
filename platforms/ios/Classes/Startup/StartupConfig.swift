//
//  StartupConfig.swift
//  CLEngine
//
//  Created by Thomas Lee on 19/03/2019.
//  Copyright © 2019 CrowdLab. All rights reserved.
//

import Foundation

@objc public class StartupConfig: NSObject {
  @objc public var deepLinkDestination: String = ""
  @objc public var language: String = ""
  @objc public var reset: Bool = false

  let parser = ArgParser(helptext: """
    Command line args; primarily for test purposes.

    --deeplink <val>, -d <val>
    The location to navigate to when starting the app.

    --language <val>, -l <val>
    The language to use throughout.

    --reset
    Reset EVERYTHING.

  """)


  override init() {

  }

  @objc public static func createPopulatedWithCommandLineArgs() -> StartupConfig {
    let sc = StartupConfig()
    sc.populateWithCommandLineArgs()
    return sc
  }

  @objc public func populateWithCommandLineArgs() {
    parser.newString("language l", fallback: "")
    parser.newString("deeplink d", fallback: "")
    parser.newFlag("reset")

    parser.parse()

    language = parser.getString("language")
    deepLinkDestination = parser.getString("deeplink")
    reset = parser.getFlag("reset")
  }

}
