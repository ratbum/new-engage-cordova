//
//  APIKeys-Crowdlab.swift
//  CrowdLab
//
//  Created by Thomas Lee on 24/10/2019.
//

import Foundation

struct APIKeys {
#if PROD
  public static let apiUrl = "https://api.crowdlab.io"
  public static let authUrl = "https://api.crowdlab.io/oauth/token"
  public static let clientId = "bddfb66a639eda8b7bb7cd04fa5a414831deb804f7ebe22984d4305004ee8597"
  public static let clientSecret = "6b175b48b70d516306a2b0fa542effb52a148e8829e23f89d6434a8d067576c1"
#else
  public static let apiUrl = "https://api.crowdlab.io"
  public static let authUrl = "https://api.crowdlab.io/oauth/token"
  public static let clientId = "bddfb66a639eda8b7bb7cd04fa5a414831deb804f7ebe22984d4305004ee8597"
  public static let clientSecret = "6b175b48b70d516306a2b0fa542effb52a148e8829e23f89d6434a8d067576c1"
#endif
}
