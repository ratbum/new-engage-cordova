//
//  StartViewController.swift
//  Crowdlab
//
//  Created by Thomas Lee on 09/07/2019.
//

import UIKit
import CrowdLabRepositories
import OAuthenticator
import CrowdLabDTO
import PromiseKit
class StartViewController: UIViewController {

  public var userToken: OAuthToken?
  var device: DeviceModel?
  let style = CrowdlabConfig.current.style
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    // Do any additional setup after loading the view.
  }

  func loadToken() -> OAuthToken? {
    let tokenStore = TokenStorage()
    return tokenStore.getToken()
  }

  func loadDeviceId() -> Int {
    return CLUserDefaults.standard.deviceId
  }
  
  func loadDeviceUUID() -> String {
    return CLUserDefaults.standard.deviceUUID
  }

  func loadLanguageCode() -> String {
    return CLUserDefaults.standard.selectedLanguageCode
  }

  override func viewDidAppear(_ animated: Bool) {
    
    let vcFactory = InitialViewControllerFactory()
    UIApplication.shared.delegate?.window?!.makeKeyAndVisible()
    self.navigationController?.setNavigationBarHidden(true, animated: false)

    guard let window = UIApplication.shared.keyWindow else { return }
    guard let engageVc = vcFactory.engageViewController() as? CDVViewController else { return }

    window.rootViewController = engageVc
    engageVc.hasLoaded = false;
    let updatedEnvironmentConfig = EnvironmentJS().text
    if updatedEnvironmentConfig != "" {
      engageVc.updatedEnvironmentConfig = updatedEnvironmentConfig
    }
    
    if loadDeviceId() != 0 {
      engageVc.shouldClearLocalstorage = true
      engageVc.device = "\(loadDeviceId())"
    }
    engageVc.language = loadLanguageCode()
    
    if loadDeviceUUID() != "" {
      engageVc.deviceUUID = "\(loadDeviceUUID())"
    }
    engageVc.runEngageScripts()
    window.rootViewController?.view.backgroundColor = style?.projectStatusBarColour

    print("§ device: ", loadDeviceId())
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
  }

}
