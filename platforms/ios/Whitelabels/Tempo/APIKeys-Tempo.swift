//
//  APIKeys-Tempo.swift
//  CrowdLab
//
//  Created by Thomas Lee on 24/10/2019.
//

import Foundation

public struct APIKeys {
#if PROD
  public static let apiUrl = "https://tempoapi.allchannelsopen.com"
  public static let authUrl = "https://tempoapi.allchannelsopen.com/oauth/token"
  public static let clientId = "95f48a79436d81c427ac3a4b4584035610cd03bb1e62a4fa1ca86bf9eee94c57"
  public static let clientSecret = "afdb63bc64bcaf4d02b3072459dfb070fa04b0dfd769d97f287dfaa21deb8762"
#else
  public static let apiUrl = "https://api.crowdlab.io"
  public static let authUrl = "https://api.crowdlab.io/oauth/token"
  public static let clientId = "bddfb66a639eda8b7bb7cd04fa5a414831deb804f7ebe22984d4305004ee8597"
  public static let clientSecret = "6b175b48b70d516306a2b0fa542effb52a148e8829e23f89d6434a8d067576c1"
#endif
}

