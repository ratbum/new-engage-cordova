//
//  Translator.swift
//  Engage
//
//  Created by Thomas Lee on 20/08/2019.
//

import Foundation
import ObjectMapper

public class Translator {

  var clDefaults: CLUserDefaults = CLUserDefaults.standard
  var languages: [Language]?
  let environmentJs = EnvironmentJS()

  public func translate(_ stringToTranslate: String) -> String {
    return activeLanguage()?.translations[stringToTranslate] ?? stringToTranslate
  }

  public func translate(_ stringToTranslate: String, replacingTokensWith replacement: String) -> String {
    let partialTranslation = translate(stringToTranslate)
    if !partialTranslation.contains("%s") {
      return partialTranslation
    }
    let translatedReplacement = translate(replacement)
    return partialTranslation.replacingOccurrences(of: "%s", with: translatedReplacement, options: .caseInsensitive, range: (partialTranslation.startIndex ..< partialTranslation.endIndex))
  }
  
  func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
  
  public func convertFileToLanguages(file: URL) -> [Language] {
    //reading
    do {
      let js = try String(contentsOf: file, encoding: .utf8)
      let components = js.components(separatedBy: " = ")
      let json = components[1...].joined(separator: "")
      let dict = convertToDictionary(text: json)
      guard let languages = dict!["languages"] as? [Any] else {
        return []
      }
      let jsonData = try! JSONSerialization.data(withJSONObject: languages, options: [])
      let justLanguagesJson = String(data: jsonData, encoding: .utf8)!
      
      return Mapper<Language>().mapArray(JSONString: justLanguagesJson)!
    } catch {
      print(error)
      return []
    }
  }
  
  public func getRemoteLanguages(onComplete: @escaping ([Language]?, Error?) -> Void) {
    let environmentJs = EnvironmentJS()

    environmentJs.download {
      destinationPath, error in
      if error != nil {
         onComplete(nil, error)
      }
      let languages = self.convertFileToLanguages(file: destinationPath!)
      onComplete(languages, nil)
    }
  }

  public func getBundledLanguages() -> [Language] {
    if languages != nil { return languages! }
    if let path = Bundle.main.path(forResource: "languages", ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let jsonString = String(data: data, encoding: .utf8)!

        languages = Mapper<Language>().mapArray(JSONString: jsonString)
        return languages!
      } catch {
        // handle error
      }
    }
    return []
  }

  public func setActiveLanguage(_ lang: Language) {
    clDefaults.selectedLanguageCode = lang.code
  }
  
  public func getLanguagesAsync(onComplete: @escaping ([Language]) -> Void) {
    if FileManager().fileExists(atPath: environmentJs.path) {
      let langs = self.convertFileToLanguages(file: environmentJs.url)
      if langs.count == 0 {
        onComplete(getBundledLanguages())
      }
      onComplete(langs)
    }
    onComplete(getBundledLanguages())
  }
  
  public func getLanguages() -> [Language] {
    if FileManager().fileExists(atPath: environmentJs.path) {
      let langs = self.convertFileToLanguages(file: environmentJs.url)
      if langs.count == 0 {
        return getBundledLanguages()
      }
      return langs
    }
    return getBundledLanguages()
  }

  public func activeLanguage() -> Language? {
    let langCode = clDefaults.selectedLanguageCode

    return (getLanguages().filter {
      $0.code == langCode
    }.first) ?? nil
  }
}
