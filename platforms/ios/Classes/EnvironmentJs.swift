//
//  EnvironmentJs.swift
//  Engage
//
//  Created by Thomas Lee on 14/02/2020.
//

import Foundation

@objc class EnvironmentJS : NSObject {
  
  #if PROD
  let remoteUrl: URL = {0
    let target = AppInfo().targetName
    let urlPath =  "https://\(target.lowercased()).web-platform.me/api/environment"
    return URL(string: urlPath)!
  }()
  #else
  let remoteUrl: URL = {
    let target = AppInfo().targetName

    let urlPath =  "https://\(target.lowercased())-beta-engage.crowdlabtech.com/api/environment"
    return URL(string: urlPath)!
  }()
  #endif
   
  
  private static func fileUrl() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("environment.js")
  }
  
  public func download(onComplete: @escaping (URL?, Error?) -> Void) {
    let downloader = Downloader()
    
    #if PROD
    let tenantName = AppInfo().targetName.lowercased() + "-production"
    #else
    let tenantName = AppInfo().targetName.lowercased() + "-staging"
    #endif

    let headers = [
      "X-Tenant-Stage": tenantName,
      "X-Platform": "ios"
    ]
    let environmentUrlString = self.remoteUrl.absoluteString + "?randomId=" + UUID().uuidString
    print(environmentUrlString)
    downloader.loadFile(at: URL(string: environmentUrlString)!,
                        to: self.url,
                        withHeaders: headers,
                        completion: onComplete)
  }
  
  let url = fileUrl()
  let path = fileUrl().path

  var text: String {
    get {
      var content = ""
      print(path)
      do {
        content = try String(contentsOf: url, encoding: .utf8)
      } catch {
        print(error)
      }
      return content
    }
  }
}
