//
//  LanguageSelectorViewController.swift
//  Engage
//
//  Created by Thomas Lee on 21/08/2019.
//

import Foundation
import UIKit

@objc class LanguageSelectorViewController: UITableViewController {

  private var styles: [AnyHashable : Any] = [:]
  private var barStyles: [AnyHashable : Any] = [:]
  private var navbarStyles: [AnyHashable : Any] = [:]
  private var currentLanguage = 0
  private var languages: [Language] = []
  let config = CrowdlabConfig.current
  private var translator: Translator!

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
  }

  func button(for buttonImage: UIImage?) -> UIButton? {
    let buttonFrame = CGRect(x: 0.0,
                             y: 0.0,
                         width: buttonImage?.size.width ?? 0.0,
                        height: buttonImage?.size.height ?? 0.0)
    let btn = UIButton(frame: buttonFrame)
    btn.setBackgroundImage(buttonImage, for: .normal)
    return btn
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.tintColor = config.style.navigationColour

    
    refreshControl = refreshControl ?? UIRefreshControl()
    refreshControl!.addTarget(self, action: #selector(refreshLanguages(_:)), for: UIControl.Event.valueChanged)
    tableView.addSubview(refreshControl!)

    translator = Translator()
    languages = translator.getLanguages()
    refreshLanguages(nil)


    setupTitle()
    setNeedsStatusBarAppearanceUpdate()

    var firstEnglishLanguageIndex = 0
    for i in 0...languages.count {
      if (languages[i].code.starts(with: "en")) {
        firstEnglishLanguageIndex = i
        break
      }
    }
    
    let thelanguage = languages[firstEnglishLanguageIndex]
    title = thelanguage.translations[TranslationKey.Languages.title]
  }
  
  @objc func refreshLanguages(_ sender: Any?) {
    translator.getRemoteLanguages {
      languages, error in
      if error != nil {
        return
      }
      if languages!.count == 0 {
        return
      }
      DispatchQueue.main.async {
       
        self.languages = languages!
        self.tableView.reloadData()
        print("done")
      }
    }
    
    self.refreshControl?.endRefreshing()
  }
  
  func convertJsonToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }

  // MARK: - Setups

  func setupTitle() {
    title = translator.translate(TranslationKey.Languages.selectLanguage)
    tableView.reloadData()
  }

  func languageChanged(_ notification: Notification?) {
    setupTitle()
  }

  func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }

  func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
    return .portrait
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let lang = languages[indexPath.row]
    translator.setActiveLanguage(lang)
    CLUserDefaults.standard.selectedLanguageCode = lang.code
    performSegue(withIdentifier: "goToCreateAccount", sender: self)
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return languages.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let theLanguage = languages[indexPath.row]
    cell.textLabel?.text = theLanguage.label
    return cell
  }
}
