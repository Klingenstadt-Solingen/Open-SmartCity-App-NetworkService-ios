//
//  OSCANetworkConfiguration.swift
//
//
//  Created by Mammut Nithammer on 09.01.22.
//  Reviewed by Stephan Breidenbach on 13.06.2022
//

import Foundation

public struct OSCANetworkConfiguration {
  public internal(set) var baseURL: URL
  public internal(set) var headers: [String: CustomStringConvertible]
  public internal(set) var session: URLSession
  
  
  public init(baseURL: URL,
              headers: [String: CustomStringConvertible] = [:],
              session: URLSession = URLSession(configuration: URLSessionConfiguration.ephemeral)) {
    self.baseURL = baseURL
    self.headers = headers
    self.session = session
  }// end public init
}// end public struct OSCANetworkConfiguration
