//
//  Downloader.swift
//  Engage
//
//  Created by Thomas Lee on 13/02/2020.
//

import Foundation

class Downloader {
  func loadFile(at url: URL,
                to destination: URL,
                withHeaders headers: [String: String],
                completion: @escaping (URL?, Error?) -> Void) {
 
    let session = URLSession(configuration: URLSessionConfiguration.default,
                             delegate: nil,
                             delegateQueue: nil)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    for header in headers {
      request.addValue(header.value, forHTTPHeaderField: header.key)
    }
    
    let task = session.dataTask(with: request, completionHandler: {
      data, response, error in
      if error == nil {
        if let response = response as? HTTPURLResponse {
          if response.statusCode == 200 {
            if let data = data {
              if let _ = try? data.write(to: destination, options: Data.WritingOptions.atomic) {
                completion(destination, error)
              } else {
                completion(destination, error)
              }
            } else {
              completion(destination, error)
            }
          }
        }
      } else {
        completion(destination, error)
      }
    })
    task.resume()
  }

}
