//
//  TranslationKey.swift
//  CLEngine
//
//  Created by Richard Hatherall on 04/12/2018.
//  Copyright © 2018 CrowdLab. All rights reserved.
//

import Foundation

public struct TranslationKey {
  struct Login {
    static let title = "login_signin"
    static let welcome = "login_welcome"
    static let loginFail = "login_fail"
    static let wrongUserType = "auth.error.access_denied_for_account_type"
    // Used to separate login & create account
    static let or = "login_create_or" // NEW
  }

  struct ForgotPassword {
    static let title = "forgotpassword_title"
    static let explanation = "forgotpassword_description"
    static let sendCode = "auth.buttons.password.send_code"
  }

  struct ResetPassword {
    static let title = "resetpassword_title" // NEW
    static let explanation = "forgotpassword_passwordsent"
    static let changePassword = "auth.buttons.password.reset"
    static let invalidCode = "auth.error.reset_password.not_found"
    static let codeField = "enter_code"
    static let passwordField = "entercode_newpassword"
    static let codeTooltip = "entercode_accesscode"
  }

  struct Languages {
    static let title = "create_accountlanguage"
    static let selectLanguage = "language_selectlanguage"
  }

  struct Terms {
    static let title = "create_readtermstitle"
    static let continueButtonText = "create_signup"
    static let termsText = "terms_terms"
  }

  struct Permissions {
    static let showSettings = "permission_show_settings" // NEW
    static let camera = "permission_camera"
    static let photoLibrary = "permission_photos"
  }

  struct Global {
    static let `continue` = "button_continue"
    static let next = "global_next"
    static let no = "global_no"
    static let yes = "global_yes"
    static let cancel = "global_alert_cancel" // NEW
    static let ok = "global_ok"
    static let done = "global_done"
    static let skip = "button_skip"
    static let unknownError = "login_errortitle"
  }

  struct Questionnaire {
    static let confirmCancel = "questionnaire_surequit"
    static let imageNotSupportedTitle = "questionnaire_imagenotsupportedtitle"
    static let imageNotSupportedMessage = "questionnaire_imagenotsupportedmessage"
  }

  struct CreateAccount {
    static let title = "login_createaccount"

    static let welcome = "create_welcome"
    // First screen (initial create)
    static let fieldEmail = "login_email"
    static let fieldEmailTooltip = "create_email_tooltip"
    static let fieldEmailErrorInvalid = "create_invalidemailmessage"

    static let fieldPassword = "login_password"
    static let fieldPasswordTooltip = "create_passworderror"
    static let fieldPasswordErrorTooShort = "create_passworderror"

    static let fieldProjectCode = "promocode_title"
    static let fieldProjectCodeTooltip = "create_project_code_tooltip"
    static let fieldProjectCodeErrorNotRecognised = "create_project_code_error"
    
    static let buttonRegister = "auth.buttons.user.register"

    // Second screen (terms)
    static let termsAccept = "profilequest_acceptterms"
    static let termsFullText = "terms_terms"

    // Third screen (details)
    static let profileDetailsIntroduction = "create_explaindetails"
    static let fieldFullname = "profilequest_name"
    static let fieldFullnameTooltip = "profilequest_fullname_short"
    static let fieldFullnameErrorEmpty = "profilequest_fullname_empty"

    static let fieldNickname = "profilequest_nickname"
    static let fieldNicknameTooltip = "profilequest_nickname_short"
    static let fieldNicknameErrorEmpty = "profilequest_nickname_empty"

    static let genderTitle = "activemodel.attributes.user.gender"
    static let genderMale = "profilequest_male"
    static let genderFemale = "profilequest_female"

    static let fieldAge = "profilequest_age" // NEW
    static let fieldAgeTooltip = "profilequest_age_tooltip" // NEW
    static let fieldAgeTooYoung = "profilequest_age_too_young" // NEW
    static let fieldAgeTooOld = "profilequest_age_too_old" // NEW

    // Fourth screen (avatar)
    static let avatarIntroduction = "questionnaire_phototitle"
    static let photoGallery = "photo_gallery" // Profile images?
    static let photoExplain = "photo_explain"
  }
}
