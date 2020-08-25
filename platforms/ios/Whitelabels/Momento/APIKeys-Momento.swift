//
//  APIKeys-Momento.swift
//  CrowdLab
//
//  Created by Thomas Lee on 24/10/2019.
//

import Foundation

public struct APIKeys {
#if PROD
  public static let apiUrl = "https://hubapi.allchannelsopen.com/"
  public static let authUrl = "https://hubapi.allchannelsopen.com/oauth/token"
  public static let clientId = "820d5410de6ed149ae9c851d6730ff4af7cde5bcbaaaa5283ae1c078e1adcc0a"
  public static let clientSecret = "48dc00a8f56d038609e551aeb9112171f4eea6bd785b5070115a59622b4f7252"
#else
  public static let apiUrl = "https://api.crowdlab.io"
  public static let authUrl = "https://api.crowdlab.io/oauth/token"
  public static let clientId = "bddfb66a639eda8b7bb7cd04fa5a414831deb804f7ebe22984d4305004ee8597"
  public static let clientSecret = "6b175b48b70d516306a2b0fa542effb52a148e8829e23f89d6434a8d067576c1"
#endif
}

