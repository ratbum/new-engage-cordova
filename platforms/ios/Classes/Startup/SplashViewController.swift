//
//  SplashViewController.swift
//  CLEngine
//
//  Created by Richard Hatherall on 02/10/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import UIKit

public class SplashViewController: UIViewController {

  // MARK: - Private
  private var notificationCenter = NotificationCenter.default
  private let userDefaults = CLUserDefaults.standard
  private var initialViewControllerFactory: InitialViewControllerFactory!
  @objc public var startupConfig: StartupConfig!
  var translator = Translator()

  // MARK: - Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()
    // Core data model needs loading before this.
    loadLanguages()
  }

  public override func viewDidDisappear(_ animated: Bool) {
    notificationCenter.removeObserver(self)
    super.viewDidDisappear(animated)
  }

  private func loadLanguages() {
    _ = translator.getLanguages()
    languageLoaded()
  }

  @objc func languageLoaded() {
    UIApplication.shared.delegate?.window?!.makeKeyAndVisible()

    let deepLinkDestination = DeepLinkDestination(rawValue: startupConfig.deepLinkDestination)!
    initialViewControllerFactory = InitialViewControllerFactory(deepLinkDestination: deepLinkDestination)
    if let window = UIApplication.shared.keyWindow {
      let initialViewControllers = initialViewControllerFactory.createViewControllers()
      let appNavigationViewController = UINavigationController(rootViewController: initialViewControllers.first!)
      appNavigationViewController.viewControllers = initialViewControllers
      UIView.transition(with: window,
                        duration: 0.5,
                        options: .transitionCrossDissolve,
                        animations: { window.rootViewController = appNavigationViewController },
                        completion: nil)
    }
  }
}
