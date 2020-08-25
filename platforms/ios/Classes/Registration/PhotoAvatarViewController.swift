//

import UIKit
import Foundation

class PhotoAvatarViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var photoavatarImageView: UIImageView!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var galleryButton: UIButton!
  @IBOutlet weak var avatarWrapperView: UIView!

  var loadingView: CLProgressOverlay?
  var displayMode: AccountViewStateMode?
  private var appRequiresPermissionAlertView: BlockAlertView?
  let config = CrowdlabConfig.current

  private var buttonToUpdate: UIButton?
  private var avatarMenu: AwesomeMenu?
  private var anImageHasChanged = false

  var translator = Translator()

  private(set) var isContactingNetwork: Bool = false

  public var createAccountSession: CreateAccountSession?

  struct Constants {
    static let coverDuration = 0.15
    static let fullAlpha = CGFloat(1.0)
    static let zeroAlpha = CGFloat(0.0)
    static let showCover = true
    static let rotateAnglePhoto = CGFloat(2.82817)
    static let rotateAngleCover = CGFloat(2.82817)
    static let wholeAnglePhoto = CGFloat(1.32835)
    static let wholeAngleAvatar = CGFloat(1.32835)
  }

  public override func viewDidLoad() {
    continueButton.backgroundColor = config.style.interactivePrimaryColour
    cameraButton.titleLabel?.textColor = config.style.interactiveSecondaryColour
    cameraButton.tintColor = config.style.interactiveSecondaryColour
    galleryButton.titleLabel?.textColor = config.style.interactiveSecondaryColour
    galleryButton.tintColor = config.style.interactiveSecondaryColour
    if createAccountSession == nil {
      createAccountSession = CreateAccountSession(userDefaults: CLUserDefaults.standard, newUser: nil)
    }

    anImageHasChanged = false
    let tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(self.tryShowingPhotoLibrary))
    self.avatarWrapperView.addGestureRecognizer(tapGesture)
    super.viewDidLoad()
    setupTitle()
  }

  public override var shouldAutorotate: Bool {
    return true
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }

  // MARK: - Setups

  func setupTitle() {
    let navTextKey = TranslationKey.CreateAccount.photoGallery
    title = translator.translate(navTextKey)
    titleLabel?.text = translator.translate(TranslationKey.CreateAccount.photoExplain)
    automaticallyAdjustsScrollViewInsets = false
    cameraButton.setTitle(translator.translate(TranslationKey.Permissions.camera), for:.normal)
    galleryButton.setTitle(translator.translate(TranslationKey.Permissions.photoLibrary), for: .normal)
    // TODO: Style this
    continueButton.setTitle(translator.translate(TranslationKey.Global.skip), for: .normal)
    continueButton.accessibilityLabel = translator.translate(TranslationKey.Global.skip)
    validateFields()
  }

  func image(fromDict imageDict: [AnyHashable : Any]?) -> UIImage? {
    let documentsDirectory: URL? = URL(fileURLWithPath: "")//  Resourceror.get().getDocumentsDirectory()
    let pathToImage = (imageDict?["styles"] as! Dictionary<String, String>)["thumbnail"]
    let pathToLoad = (documentsDirectory?.appendingPathComponent(pathToImage ?? ""))?.path
    return UIImage(contentsOfFile: pathToLoad ?? "")
  }

  @objc func languageChanged(_ notification: Notification?) {
    setupTitle()
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // resize the borders of the buttons.
  }

  override func viewDidAppear(_ animated: Bool) {
    styleRoundButton(avatarWrapperView)
    styleRoundButton(photoavatarImageView)
  }

  override public func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }

  func styleRoundButton(_ theButtonWrapper: UIView?) {
    let styleConfig = CrowdlabConfig.current.style!
    let buttonFrame: CGRect? = theButtonWrapper?.frame
    theButtonWrapper?.clipsToBounds = true
    theButtonWrapper?.layer.cornerRadius = (buttonFrame?.size.width ?? 0.0) / 2.0
    theButtonWrapper?.layer.borderColor = styleConfig.fieldColour.cgColor
    theButtonWrapper?.layer.borderWidth = 2.0
    theButtonWrapper?.backgroundColor = styleConfig.fieldColour
    theButtonWrapper?.tintColor = styleConfig.fieldColour
  }

  override public var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  @IBAction func photoButtonPressed(_ sender: UIButton) {
    _ = tryShowingCamera()
  }

  @IBAction func libraryButtonPressed(_ sender: UIButton) {
    _ = tryShowingPhotoLibrary()
  }

  func tryShowingCamera() -> Bool {
    weak var weakSelf: PhotoAvatarViewController? = self

    let isAuthorized = CameraPermission().isAuthorized()
    if isAuthorized {
      weakSelf?.actionLaunchAppCamera(UIImagePickerController.SourceType.camera)
    } else {
      let cameraPermission = CameraPermission()
      cameraPermission.requestForImmediateUse {
        isAllowed in

        if isAllowed {
          weakSelf?.actionLaunchAppCamera(UIImagePickerController.SourceType.camera)
        } else {
          PermissionLauncher.alertUserPermissionNotGranted(permission: cameraPermission, viewController: self, completionHandler: {
            didOpenSettings in
          })
        }
      }

    }
    return isAuthorized
  }

  @objc func tryShowingPhotoLibrary() -> Bool {
    weak var weakSelf: PhotoAvatarViewController? = self

    let isAuthorized = PhotoLibraryPermission().isAuthorized()
    if isAuthorized {
      weakSelf?.actionLaunchAppCamera(.photoLibrary)
    } else {
      let photoLibraryPermission = PhotoLibraryPermission()

      photoLibraryPermission.requestForImmediateUse {
        isAllowed in

        if isAllowed {
          weakSelf?.actionLaunchAppCamera(.photoLibrary)
        } else {
          PermissionLauncher.alertUserPermissionNotGranted(permission: photoLibraryPermission, viewController: self, completionHandler: {
                 didOpenSettings in
            if didOpenSettings {
              weakSelf?.actionLaunchAppCamera(.photoLibrary)
            }

          })
        }
      }

    }
    return isAuthorized
  }

  func actionLaunchAppCamera(_ source: UIImagePickerController.SourceType) {
    DispatchQueue.main.async {
      if UIImagePickerController.isSourceTypeAvailable(source) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
      } else {
        let alertTitle = self.translator.translate(TranslationKey.Questionnaire.imageNotSupportedTitle)
        let alertDetail = self.translator.translate(TranslationKey.Questionnaire.imageNotSupportedMessage)
        let alertController = UIAlertController(title: alertTitle, message: alertDetail, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: self.translator.translate(TranslationKey.Global.ok), style: .cancel, handler: nil))
        self.present(alertController, animated: true)
      }
    }
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //This creates a filepath with the current date/time as the name to save the image
    var imageTypeToUse = UIImagePickerController.InfoKey.originalImage
    //This checks to see if the image was edited, if it was it saves the edited version as a .png
    if info[.editedImage] != nil {
      //save the edited image
      imageTypeToUse = UIImagePickerController.InfoKey.editedImage
    }

    guard let anUse = info[imageTypeToUse] as? UIImage else {
      return
    }
    loadingView = CLProgressOverlay(targetSuperview: avatarWrapperView)
    loadingView?.accessibilityIdentifier = "loading_view"
    loadingView?.isAccessibilityElement = true
    photoavatarImageView.image = anUse

    if !UIAccessibility.isReduceTransparencyEnabled {
      let blurEffect = UIBlurEffect(style: .dark)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      //always fill the view
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
    } else {
      view.backgroundColor = UIColor.black
    }
    dismiss(animated: true)
    createAccountSession?.uploadAvatar(pngData: anUse.pngData()!,
      success: {
      [weak self] in
      self?.loadingView?.removeFromSuperview()
      self?.loadingView = nil
      self?.continueButton.setTitle(self!.translator.translate(TranslationKey.Global.done), for: .normal)
      self?.continueButton.accessibilityLabel = self!.translator.translate(TranslationKey.Global.done)
    }, fail: {
      errors in
      print("Currently not authenticated.")
    })
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
    validateFields()
  }

  func documentsPath(_ fileName: String?) -> String? {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return URL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName!).absoluteString
  }

  func validateFields() {

  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToProjectLoading" {
      guard let projectLoading = segue.destination as? StartViewController else {
        return
      }
      projectLoading.device = createAccountSession?.user.device
    }
  }
  @IBAction func continueButtonPressed(_ sender: UIButton) {
    performSegue(withIdentifier: "goToProjectLoading", sender: self)
  }
}
