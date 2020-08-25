//

import UIKit
import Foundation
import CrowdLabDTO
import CrowdLabRepositories


public class NickNameViewController: UIViewController, CLTextFieldDelegate, CLOptionViewDelegate, UITableViewDelegate, UITableViewDataSource {


  let continueButtonHeightOffset = 16
  let shouldValidateWhileTyping = Device.create().deviceIdentifierParts.0 > 7

  public func textFieldDidBeginEditing(_ textField: CLTextField) {
    return
  }

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var fieldFullname: CLTextField!
  @IBOutlet weak var fieldNickname: CLTextField!
  @IBOutlet weak var fieldAge: CLTextField!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var genderWrapperView: UIView!
  var genderOptionView: CLOptionView<String>!
  var genderSelectionListView: SelfSizedTableView!
  @IBOutlet weak var buttonWrapperView: UIView!

  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var scrollableContentView: UIView!
  public var createAccountSession: CreateAccountSession?

  let config = CrowdlabConfig.current
  var displayMode: AccountViewStateMode?
  var translator = Translator()
  private var blockingView: CLProgressOverlay!

  var currentlySelectedGender: UserModel.Gender?

  @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!

  private var failResponseAlertView: BlockAlertView?

  private var collapsedDatePickerHeight: CGFloat = 0.0
  private var expandedDatePickerHeight: CGFloat = 0.0

  #if MANY_GENDERS
  private var needsMoreThan2Genders = true
  #else
  private var needsMoreThan2Genders = false
  #endif
  public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
  }

  required init?(coder: NSCoder) {
    super.init(coder:coder)
  }

  func setContinueButtonIsEnabled(_ isEnabled: Bool) {
    continueButton.isEnabled = isEnabled
    if isEnabled {
      continueButton.backgroundColor = config.style.interactivePrimaryColour
    } else {
      continueButton.backgroundColor = config.style.interactivePrimaryColourDisabled
    }
  }

  public override func viewDidLoad() {
    continueButton.backgroundColor = config.style.interactivePrimaryColour
    self.navigationController?.setViewControllers([self], animated: false)

    if createAccountSession == nil {
      createAccountSession = CreateAccountSession(userDefaults: CLUserDefaults.standard, newUser: nil)
    }
    fieldFullname.delegate = self
    fieldNickname.delegate = self
    fieldAge.delegate = self

    fieldAge.keyboardType = .numberPad

    fieldFullname.returnKeyType = UIReturnKeyType.next
    fieldNickname.returnKeyType = UIReturnKeyType.next
    fieldAge.returnKeyType = .done

    fieldFullname.textField.accessibilityIdentifier = "full_name_field"
    fieldNickname.textField.accessibilityIdentifier = "nickname_field"
    fieldAge.textField.accessibilityIdentifier = "age_field"

    if needsMoreThan2Genders {
      let genderTitle = UILabel()
      genderTitle.text = translator.translate(TranslationKey.CreateAccount.genderTitle)
      genderTitle.translatesAutoresizingMaskIntoConstraints = false
      genderWrapperView.addSubview(genderTitle)
      genderSelectionListView = SelfSizedTableView()
      genderWrapperView.removeConstraints(genderWrapperView!.constraints)
      genderWrapperView.translatesAutoresizingMaskIntoConstraints = false
      genderSelectionListView.translatesAutoresizingMaskIntoConstraints = false
      genderSelectionListView.setContentCompressionResistancePriority(.required, for: .vertical)
      genderSelectionListView.setContentHuggingPriority(.required, for: .vertical)
      genderWrapperView.setContentHuggingPriority(.required, for: .vertical)
      genderWrapperView.setContentCompressionResistancePriority(.required, for: .vertical)
      genderSelectionListView.isScrollEnabled = false
      genderWrapperView.addSubview(genderSelectionListView)
      genderTitle.topAnchor.constraint(equalTo: genderWrapperView.topAnchor).isActive = true
      genderTitle.leadingAnchor.constraint(equalTo: genderWrapperView.leadingAnchor).isActive = true
      genderTitle.trailingAnchor.constraint(equalTo: genderWrapperView.trailingAnchor).isActive = true
      genderSelectionListView.topAnchor.constraint(equalTo: genderTitle.bottomAnchor, constant: 8).isActive = true
      genderSelectionListView.trailingAnchor.constraint(equalTo: genderWrapperView.trailingAnchor).isActive = true
      genderSelectionListView.leadingAnchor.constraint(equalTo: genderWrapperView.leadingAnchor).isActive = true
      genderWrapperView.bottomAnchor.constraint(equalTo: genderSelectionListView.bottomAnchor).isActive = true
      genderSelectionListView.delegate = self
      genderSelectionListView.dataSource = self
      genderSelectionListView.reloadData()
      let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
      spaceView.translatesAutoresizingMaskIntoConstraints = false
      stackView.addArrangedSubview(spaceView)
      genderSelectionListView.separatorStyle = .none
      spaceView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
      spaceView.heightAnchor.constraint(equalToConstant: 8).isActive = true
      scrollableContentView.layoutSubviews()
      scrollableContentView.sizeToFit()
    } else {
      genderOptionView = CLOptionView<String>(frame: genderWrapperView.frame)
      genderOptionView.setOptions([
        CLOption<String>(value: "male",
                     labelText: translator.translate(TranslationKey.CreateAccount.genderMale),
                         image: UIImage(named: "male_icon_up")!,
                inactiveColour: config.style.interactivePrimaryColourDisabled,
                   activeColor: config.style.interactivePrimaryColour,
       accessibilityIdentifier: "gender_m"),
        CLOption<String>(value: "female",
                     labelText: translator.translate(TranslationKey.CreateAccount.genderFemale),
                         image: UIImage(named: "female_icon_up")!,
                inactiveColour: config.style.interactivePrimaryColourDisabled,
                   activeColor: config.style.interactivePrimaryColour,
       accessibilityIdentifier: "gender_f")
      ])
      genderWrapperView.addSubview(genderOptionView)
      genderOptionView.pinEdges(to: genderWrapperView)
      genderOptionView.delegate = self
    }
    setupTranslations()
    updateAllValidation()
    fieldFullname.setValidationColors(forValidity: false)
    fieldNickname.setValidationColors(forValidity: false)
    fieldAge.setValidationColors(forValidity: false)

    if shouldValidateWhileTyping {
      setContinueButtonIsEnabled(isFormValid())
    }
  }
  // MARK: - Setups
  func setupTranslations() {
    let titleString = TranslationKey.CreateAccount.welcome

    title = translator.translate(titleString)
    titleLabel?.text = translator.translate(TranslationKey.CreateAccount.profileDetailsIntroduction)

    continueButton.setTitle(translator.translate(TranslationKey.Global.next), for: .normal)
    fieldFullname.labelText = translator.translate(TranslationKey.CreateAccount.fieldFullname)
    fieldNickname.labelText = translator.translate(TranslationKey.CreateAccount.fieldNickname)
    fieldAge.labelText = translator.translate(TranslationKey.CreateAccount.fieldAge)
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
  }

  private func updateFullnameValidation() {
    fieldFullname.updateValidation(valueCheck: (createAccountSession?.checkFullName)!,
                               defaultTooltipKey: TranslationKey.CreateAccount.fieldFullnameTooltip)
  }

  private func updateNicknameValidation() {
    fieldNickname.updateValidation(valueCheck: (createAccountSession?.checkUserNickname)!,
                               defaultTooltipKey: TranslationKey.CreateAccount.fieldNicknameTooltip)
  }

  private func updateAgeValidation() {
    fieldAge.updateValidation(valueCheck: (createAccountSession?.checkUserAge)!,
                               defaultTooltipKey: TranslationKey.CreateAccount.fieldAgeTooltip)
  }

  private func updateDateOfBirthValidation() {
  }


  private func updateAllValidation() {
    updateFullnameValidation()
    updateNicknameValidation()
    updateDateOfBirthValidation()
    setContinueButtonIsEnabled(isFormValid())
  }

  @objc func languageChanged(_ notification: Notification?) {
    setupTranslations()
  }

  public override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }

  public override func viewWillAppear(_ animated: Bool) {

  }

  override public func viewDidAppear(_ animated: Bool) {
  }

  override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }

  override public var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  private func isFormValid() -> Bool {
    return createAccountSession?.checkFullName(fieldFullname.text) == nil &&
      createAccountSession?.checkUserNickname(fieldNickname.text) == nil &&
      createAccountSession?.checkUserAge(fieldAge.text) == nil
  }

  public func textFieldShouldReturn(_ textField: CLTextField) -> Bool {
    if textField.returnKeyType == UIReturnKeyType.next {
      let nextView = self.view.viewWithTag(textField.tag+1)
      DispatchQueue.main.async {
        nextView?.becomeFirstResponder()
      }
    } else if textField.returnKeyType == .done {
      _ = textField.resignFirstResponder()
    }
    return true
  }

  public func textFieldDidEndEditing(_ textField: CLTextField) {
    switch textField {
    case fieldFullname:
      _ = updateFullnameValidation()
    case fieldNickname:
      _ = updateNicknameValidation()
    case fieldAge:
      _ = updateAgeValidation()
    default:
      break
    }
    setContinueButtonIsEnabled(isFormValid())
  }

  public func textFieldDidChange(_ textField: CLTextField) {
    if !shouldValidateWhileTyping {
      return
    }
    if textField.text.contains("\t") {
      textField.text = textField.text.replacingOccurrences(of: "\t", with: "", options: NSString.CompareOptions.literal, range: nil)
      _ = textFieldShouldReturn(textField)
    }
    // Important to check if this is valid before field is exited, since otherwise the continue button will
    // be pretty much always be greyed out.
    setContinueButtonIsEnabled(isFormValid())

    if textField == fieldFullname {
      _ = updateFullnameValidation()
    }
    if textField == fieldNickname {
      _ = updateNicknameValidation()
    }
    if textField == fieldAge {
      _ = updateAgeValidation()
    }
  }

  public func optionViewChanged(index: Int) {
    resignFirstResponderForTextFields()
    currentlySelectedGender = UserModel.Gender.allCases[index]
  }

  @IBAction func continueButtonPressed(_ sender: UIButton) {
    blockingView = CLProgressOverlay(targetSuperview: self.view)
    let ageText = fieldAge.text.trimmingCharacters(in: .whitespacesAndNewlines)
    var yearsAgo = DateComponents()
    yearsAgo.year = -Int(ageText)!
    let bornOn =  Calendar.current.date(byAdding: yearsAgo, to: Date())
    createAccountSession?.saveUserDetails(name: fieldFullname.text,
                                          nickname: fieldNickname.text,
                                          gender: currentlySelectedGender,
                                          dob: bornOn,
                                          success: {
                                            self.blockingView.removeFromSuperview()
                                            self.blockingView = nil
                                            self.goToNextScreen()
    }, failure: {
      error in
      self.blockingView.removeFromSuperview()

      let alertController = UIAlertController()
      alertController.message = self.translator.translate(TranslationKey.Global.unknownError)
      alertController.addAction(UIAlertAction(title: TranslationKey.Global.ok, style: UIAlertAction.Style.default, handler: nil))

      alertController.show(self, sender: self)
      self.present(alertController, animated: true, completion: nil)
    })
  }

  func resignFirstResponderForTextFields() {
    _ = fieldAge.resignFirstResponder()
    _ = fieldFullname.resignFirstResponder()
    _ = fieldNickname.resignFirstResponder()
  }

  // MARK: Validation
  func validateFullNameField(_ name: String?) -> Bool {
    let isValid: Bool = (name?.count ?? 0) > 0
    if isValid {
      fieldFullname.tooltipText = ""
    }
    return isValid
  }

  func validateNicknameField(_ name: String?) -> Bool {
    let isValid: Bool = (name?.count ?? 0) > 0
    if isValid {
      fieldNickname.tooltipText = ""
    }
    return isValid
  }

  private func goToNextScreen() {
    createAccountSession?.user.name = fieldFullname.text.trimmingCharacters(in:
      .whitespacesAndNewlines)
    createAccountSession?.user.nickname = fieldNickname.text.trimmingCharacters(in:
      .whitespacesAndNewlines)
    let ageText = fieldAge.text.trimmingCharacters(in: .whitespacesAndNewlines)
    var yearsAgo = DateComponents()
    yearsAgo.year = -Int(ageText)!
    createAccountSession?.user.bornOn = Calendar.current.date(byAdding: yearsAgo, to: Date())
    self.performSegue(withIdentifier: "goToAvatarSelection", sender: self)
  }

  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToAvatarSelection" {
      let avatarVC = segue.destination as! PhotoAvatarViewController
      avatarVC.createAccountSession = createAccountSession
    }
  }

  func isCompleted() -> Bool {
    return createAccountSession?.isCompleted() ?? false
  }

  func failWithError(_ error: Error) {
    failResponseAlertView = BlockAlertView.alert(withTitle: translator.translate(TranslationKey.Login.loginFail),
                                                 message: "") as? BlockAlertView
    failResponseAlertView!.addButton(withTitle: translator.translate(TranslationKey.Global.ok), block: nil)
    failResponseAlertView!.show()
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return UserModel.Gender.allCases.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "g")

    let genderDecorator = GenderDecorator(translator: translator, gender: UserModel.Gender.allCases[indexPath.row])
    cell.textLabel!.text = genderDecorator.name
    cell.tintColor = config.style.interactiveSecondaryColour
    let backgroundView = cell.backgroundView ?? UIView()
    backgroundView.backgroundColor = .white
    cell.selectedBackgroundView = backgroundView
    return cell
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    resignFirstResponderForTextFields()
    for rowNumber in 0..<UserModel.Gender.allCases.count {
      tableView.cellForRow(at: IndexPath(row: rowNumber, section: indexPath.section))?.accessoryType = .none
    }
    let selectedCell = tableView.cellForRow(at: indexPath)!
    selectedCell.accessoryType = .checkmark
    selectedCell.selectedBackgroundView?.layer.backgroundColor = UIColor.white.cgColor
    currentlySelectedGender = UserModel.Gender.allCases[indexPath.row]
    if !shouldValidateWhileTyping {
      continueButton.isEnabled = true
    } else {
      continueButton.isEnabled = isFormValid()
    }
  }

  func optionValuesAreEqual(withOption1 o1: Any, option2 o2: Any) -> Bool {
    return (o1 as? NSNumber)?.isEqual(o2 as? NSNumber) ?? false
  }
}
