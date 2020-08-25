//
//  Config.swift
//  Engage
//
//  Created by Thomas Lee on 07/10/2019.
//

import Foundation
import OAuthenticator
import CrowdLabAPIAdapter
import CLAPIConfiguration

public extension CLAPIConfiguration {
  static var staging: CLAPIConfiguration = CLAPIConfiguration()
  static var production: CLAPIConfiguration = {
    var prodConfig = CLAPIConfiguration()
    prodConfig.urlBase = APIKeys.apiUrl
    prodConfig.oAuthConfig = OAuthConfig.production
    return prodConfig
  }()
}

public extension OAuthConfig {
  static var staging = OAuthConfig()
  static var production: OAuthConfig = {
    var prodConfig = OAuthConfig()
    prodConfig.url = APIKeys.authUrl
    prodConfig.clientId = APIKeys.clientId
    prodConfig.clientSecret = APIKeys.clientSecret
    return prodConfig
  }()
}

public struct StyleConfig {
  var primaryColour = #colorLiteral(red: 0.27588625, green: 0.5181780134, blue: 0.1907573714, alpha: 1)
  var secondaryColour = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
  var fieldColour = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
  var validColour = #colorLiteral(red: 0.08412888077, green: 0.8862745166, blue: 0, alpha: 1)
  var invalidColour = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
  var tooltipColour = #colorLiteral(red: 0.6363448346, green: 0.2627144535, blue: 0.6831891741, alpha: 1)
  var projectStatusBarColour = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
  var navigationColour = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
  var interactivePrimaryColour = #colorLiteral(red: 0.06697597115, green: 1, blue: 0.9897143102, alpha: 1)
  var interactivePrimaryColourDisabled = #colorLiteral(red: 0.06697597115, green: 1, blue: 0.9897143102, alpha: 0.5)
  var interactiveSecondaryColour = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)

  public static func configStringToUIColor(configString: String) -> UIColor? {
    if !configString.starts(with: "colorLiteral") {
      return nil
    }
    let scanner = Scanner(string: configString)
    var tmp: NSString?
    var redString: NSString?, blueString: NSString?, greenString: NSString?, alphaString: NSString?
    var red: CGFloat = -1.0, blue: CGFloat = -1.0, green: CGFloat = -1.0, alpha: CGFloat = 1

    scanner.scanUpTo("red:", into: &tmp)
    scanner.scanCharacters(from: CharacterSet(charactersIn: "red:"), into: &tmp)
    scanner.scanUpTo(",", into: &redString)
    red = CGFloat(Float(String(redString!))!)

    scanner.scanUpTo("green:", into: &tmp)
    scanner.scanCharacters(from: CharacterSet(charactersIn: "green:"), into: &tmp)
    scanner.scanUpTo(",", into: &greenString)
    green = CGFloat(Float(String(greenString!))!)

    scanner.scanUpTo("blue:", into: &tmp)
    scanner.scanCharacters(from: CharacterSet(charactersIn: "blue:"), into: &tmp)
    scanner.scanUpTo(",", into: &blueString)
    blue = CGFloat(Float(String(blueString!))!)

    scanner.scanUpTo("alpha:", into: &tmp)
    scanner.scanCharacters(from: CharacterSet(charactersIn: "alpha:"), into: &tmp)
    scanner.scanUpTo(")", into: &alphaString)
    alpha = CGFloat(Float(String(alphaString!))!)

    return UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
  }

  init() {}
}

public struct CrowdlabConfig {
  public static var current: CrowdlabConfig = CrowdlabConfig.forCurrentApp()

  public static var appName: String {
    return Bundle.main.infoDictionary?["CFBundleName"] as! String
  }

  public static func forCurrentApp() -> Self {
    return CrowdlabConfig.readFromConfig(file: CrowdlabConfig.appName)
  }

  public var apiConfig: CLAPIConfiguration!
  public let style: StyleConfig!

  public static func readFromConfig(file: String) -> CrowdlabConfig {
    let config = Bundle.main.path(forResource: file, ofType: "plist")!
    guard let dict = NSDictionary(contentsOfFile: config) as? [String: Any] else {
      exit(900)
    }
    return CrowdlabConfig(dictFromPlist: dict)
  }

  init(apiConfig: CLAPIConfiguration, style: StyleConfig) {
    self.apiConfig = apiConfig
    self.style = style
  }

  init(dictFromPlist: [String: Any]) {
    self.apiConfig = CLAPIConfiguration()
    self.apiConfig.urlBase = APIKeys.apiUrl
    self.apiConfig.oAuthConfig.url = APIKeys.authUrl
    self.apiConfig.oAuthConfig.clientId = APIKeys.clientId
    self.apiConfig.oAuthConfig.clientSecret = APIKeys.clientSecret

    let styleDict = dictFromPlist["style"] as! [String: String]
    var style = StyleConfig()
    style.fieldColour = StyleConfig.configStringToUIColor(configString: styleDict["fieldColour"]!)!
    style.validColour = StyleConfig.configStringToUIColor(configString: styleDict["validColour"]!)!
    style.invalidColour = StyleConfig.configStringToUIColor(configString: styleDict["invalidColour"]!)!
    style.tooltipColour = StyleConfig.configStringToUIColor(configString: styleDict["tooltipColour"] ?? "") ?? style.fieldColour
    style.interactivePrimaryColour = StyleConfig.configStringToUIColor(configString: styleDict["interactivePrimaryColour"]!)!
    style.interactivePrimaryColourDisabled = StyleConfig.configStringToUIColor(configString: styleDict["interactivePrimaryColourDisabled"]!)!
    style.interactiveSecondaryColour = StyleConfig.configStringToUIColor(configString: styleDict["interactiveSecondaryColour"]!)!
    style.projectStatusBarColour = StyleConfig.configStringToUIColor(configString: styleDict["projectStatusBarColour"]!)!
    style.navigationColour = StyleConfig.configStringToUIColor(configString: styleDict["navigationColour"]!)!
    self.style = style
  }
}
