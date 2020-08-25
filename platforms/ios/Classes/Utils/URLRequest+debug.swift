//
//  URLRequest+debug.swift
//  Engage
//
//  Created by Thomas Lee on 06/09/2019.
//

import Foundation

public extension URLRequest {

  var curlString: String {
    // Logging URL requests in whole may expose sensitive data,
    // or open up possibility for getting access to your user data,
    // so make sure to disable this feature for production builds!
    #if !DEBUG
    return ""
    #else
    var result = "curl -k "

    if let method = httpMethod {
      result += "-X \(method) \\\n"
    }

    if let headers = allHTTPHeaderFields {
      for (header, value) in headers {
        result += "-H \"\(header): \(value)\" \\\n"
      }
    }

    if let body = httpBody, !body.isEmpty, let string = String(data: body, encoding: .utf8), !string.isEmpty {
      result += "-d '\(string)' \\\n"
    }

    if let url = url {
      result += url.absoluteString
    }

    return result
    #endif
  }
}
