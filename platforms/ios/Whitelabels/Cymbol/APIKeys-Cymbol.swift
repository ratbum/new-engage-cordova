//
//  APIKeys-Cymbol.swift
//  CrowdLab
//
//  Created by Thomas Lee on 24/10/2019.
//

import Foundation

public struct APIKeys {
#if PROD
  public static let apiUrl = "https://cymbolapi.allchannelsopen.com"
  public static let authUrl = "https://cymbolapi.allchannelsopen.com/oauth/token"
  public static let clientId = "5f5cfc6b92e8b764a2fd179e1e6b8e6ffe5a1000218cf9e0289055ef78bba2eb"
  public static let clientSecret = "7c328ec583a836eea6421d24d0b24263a80f4deb38898f0da8682f455e260b62"
#else
  public static let apiUrl = "https://api.crowdlab.io"
  public static let authUrl = "https://api.crowdlab.io/oauth/token"
  public static let clientId = "bddfb66a639eda8b7bb7cd04fa5a414831deb804f7ebe22984d4305004ee8597"
  public static let clientSecret = "6b175b48b70d516306a2b0fa542effb52a148e8829e23f89d6434a8d067576c1"
#endif
}

