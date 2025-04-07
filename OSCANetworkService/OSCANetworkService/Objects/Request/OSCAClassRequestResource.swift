//
//  OSCARequestResource.swift
//
//
//  Created by Mammut Nithammer on 09.01.22.
//  Reviewed by Stephan Breidenbach on 14.06.2022
//

import Foundation
import OSCAEssentials

public struct OSCAClassRequestResource<ParseClass: OSCAParseClassObject & Hashable> {
  public typealias Response = ParseClass
  
  public init(baseURL: URL,
              parseClass: String,
              parameters: [String : CustomStringConvertible],
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.parseClass = parseClass
    self.parameters = parameters
    self.headers = headers
  }// end public init
  
  var baseURL: URL
  let parseClass: String
  let parameters: [String: CustomStringConvertible]
  let headers: [String: CustomStringConvertible]
  
  public var requestClass: URLRequest? {
    let url = baseURL.appendingPathComponent("/classes/\(parseClass)")
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    
    components.queryItems = parameters.keys.map { key in
      URLQueryItem(name: key, value: parameters[key]?.description)
    }
    
    guard let url = components.url else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }
    
    return urlRequest
  }// end internal var requestClass
}// end public struct OSCAClassRequestResource

extension OSCAClassRequestResource: OSCAClassRequestResourceProtocol {}

