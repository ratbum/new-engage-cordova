//
import Foundation
import UIKit
import CrowdLabDTO

enum AccountViewStateMode : Int {
  case accountCreationMode = 0
  case accountEditModeTasksList
  case accountEditModeProjectsList
}

@objc public class TermsConditionsViewController: UIViewController, AsyncFeedbackDisplay {
  
  @IBOutlet weak var termsTextView: UITextView!
  @IBOutlet weak var acceptLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var acceptButton: CLCheckbox!
  var displayMode: AccountViewStateMode?
  var translator = Translator()
  let config = CrowdlabConfig.current

  public var createAccountSession: CreateAccountSession?
  private var blockingView: CLProgressOverlay!

  @objc public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  @objc required init?(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }

  func setSignUpButtonEnabled(_ isEnabled: Bool) {
    continueButton.isEnabled = isEnabled
    if isEnabled {
      continueButton.backgroundColor = config.style.interactivePrimaryColour
    } else {
      continueButton.backgroundColor = config.style.interactivePrimaryColourDisabled
    }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    continueButton.backgroundColor = config.style.interactivePrimaryColour
    acceptButton.tintColor = config.style.interactivePrimaryColour
    acceptButton.checkmarkImage = UIImage(named: "checkmark")
    setupTranslation()
    styleView()
    acceptButton.addTarget(self, action: #selector(toggleAccept),
                           for: .valueChanged)
  }

  @objc func logout() {
    // Since you have not agreed to the terms here, your account will not be created,
    // and you are returned to the create account screen.
    let viewControllers = navigationController?.viewControllers
    for vcIndex in 0..<(viewControllers?.count ?? 0) {
      let viewController: UIViewController? = viewControllers?[vcIndex]
      if viewController is CreateAccountViewController {
        if let aController = viewController {
          navigationController?.popToViewController(aController, animated: true)
        }
        break
      }
    }
  }

  // MARK: - Setups
  func button(for buttonImage: UIImage?) -> UIButton? {
    let buttonFrame = CGRect(x: 0.0,
                             y: 0.0,
                             width: buttonImage?.size.width ?? 0.0,
                             height: buttonImage?.size.height ?? 0.0)
    let btn = UIButton(frame: buttonFrame)
    btn.setBackgroundImage(buttonImage, for: .normal)
    btn.addTarget(self,
                  action: #selector(TermsConditionsViewController.logout),
                  for: .touchUpInside)
    return btn
  }

  func buttonForLogout() -> UIButton? {
    var buttonImage = UIImage(named: "sign_up_logout_button")
    buttonImage = buttonImage?.withRenderingMode(.alwaysOriginal)
    return button(for: buttonImage)
  }

  func setupTranslation() {
    title = translator.translate(TranslationKey.Terms.title)
    continueButton.setTitle(translator.translate(TranslationKey.Terms.continueButtonText), for: .normal)
    acceptLabel.text = translator.translate(TranslationKey.CreateAccount.termsAccept)
  }

  @objc func languageChanged(_ notification: Notification?) {
    setupTranslation()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if createAccountSession != nil {
      createAccountSession?.asyncFeedbackDisplay = self
    }

    let shouldHideElements = displayMode == AccountViewStateMode.accountEditModeProjectsList ||
      displayMode == AccountViewStateMode.accountEditModeTasksList ||
      createAccountSession == nil
    acceptButton.isHidden = shouldHideElements
    continueButton.isHidden = shouldHideElements
    acceptLabel.isHidden = shouldHideElements

    if !shouldHideElements {
      navigationItem.leftBarButtonItem = UIBarButtonItem(customView: buttonForLogout()!)
    }

    acceptButton.isChecked = createAccountSession?.hasUserAcceptedTerms ?? false
    updateContinueButtonStatus()
  }


  public override func viewWillDisappear(_ animated: Bool) {
    createAccountSession?.asyncFeedbackDisplay = nil
    NotificationCenter.default.removeObserver(self)
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }

  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  @objc func styleView() {
    // TODO: Style this
    automaticallyAdjustsScrollViewInsets = false
    let innerMargin: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    termsTextView.textContainerInset = innerMargin
    termsTextView.layer.borderWidth = 2.0
    termsTextView.layer.borderColor = UIColor.colorFromRgbValue(0xdedede).cgColor
    termsTextView.layer.cornerRadius = 4.0
    termsTextView.text = translator.translate(TranslationKey.Terms.termsText)
  }

  @IBAction func toggleAccept(_ sender: CLCheckbox) {
    createAccountSession?.hasUserAcceptedTerms = sender.isChecked
    updateContinueButtonStatus()
  }

  @IBAction func continueButtonPressed(_ sender: UIButton) {
    createAccountSession?.createAccount(success: {
      user, token in
      print(user, token)
    }, failure: {
      error in
      print(error)
    })
  }

  func updateContinueButtonStatus() {
    if createAccountSession == nil {
      return
    }
    setSignUpButtonEnabled(createAccountSession!.hasUserAcceptedTerms ?? false)
  }

  public func asyncProcessStarted() {
    blockingView = CLProgressOverlay(targetSuperview: view)
  }

  public func asyncProcessFinished() {
    blockingView.removeFromSuperview()
    blockingView = nil
  }

  public func asyncProcessFailed(error: FieldErrorCollection?) {
    navigationController?.popViewController(animated: true)
  }

  public func asyncProcessSucceeded() {
    performSegue(withIdentifier: "goToUserDetails", sender: self)
  }

  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToUserDetails" {
      let nickVC = segue.destination as! NickNameViewController
      nickVC.createAccountSession = createAccountSession
    }
  }

  func fail() throws {
    //print("putme failed with \(error?.localizedDescription ?? "")")
  }

}
