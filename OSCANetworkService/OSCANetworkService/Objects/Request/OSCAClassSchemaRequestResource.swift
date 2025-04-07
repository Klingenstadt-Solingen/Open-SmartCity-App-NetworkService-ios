//
//  OSCAClassSchemaRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 20.01.23.
//

import Foundation
import OSCAEssentials

public struct OSCAClassSchemaRequestResource {
  public init(baseURL: URL,
              parseClass: String? = nil,
              parameters: [String : CustomStringConvertible],
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.parseClass = parseClass
    self.parameters = parameters
    self.headers = headers
  }// end public init

  public typealias Response = ParseClassSchema
  
  var baseURL: URL
  var parseClass: String?
  let parameters: [String: CustomStringConvertible]
  let headers: [String: CustomStringConvertible]
  
  public var requestClassSchema: URLRequest? {
    var url = baseURL
    if let parseClassName = parseClass {
      url = url.appendingPathComponent("/schemas/\(parseClassName)")
    } else {
      url = url.appendingPathComponent("/schemas")
    }// end if
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
  }// end public var requestClassSchema
}// end public struct OSCAClassSchemaRequestResource

extension OSCAClassSchemaRequestResource: OSCAClassSchemaRequestResourceProtocol {}
