//
//  OSCAHttpRequestResource.swift
//  OSCANetworkService
//
//  Created by Igor Dias on 26.10.22.
//

import Foundation
import OSCAEssentials

public struct OSCAHttpRequestResource {
  var baseURL: URL
  var path: String
  let parameters: [String: CustomStringConvertible]
  let headers: [String: CustomStringConvertible]
  let bodyObject: Encodable?
  let httpMethod: HTTPMethodType
  
  public var request: URLRequest? {
    let url = baseURL.appendingPathComponent(path)
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    
    components.queryItems = parameters.keys.map { key in
      URLQueryItem(name: key, value: parameters[key]?.description)
    }
    
    guard let url = components.url else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = httpMethod.rawValue
    
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }// end for header in headers
    
    if(self.bodyObject != nil){
      let bodyObjectSerialized = try? OSCACoding.jsonEncoder().encode(self.bodyObject!)
      urlRequest.httpBody = bodyObjectSerialized
    }
    
    return urlRequest
  }// end public var request
}// end public struct OSCAHttpRequestResource

extension OSCAHttpRequestResource {
  public init(
    baseURL: URL,
    path: String,
    httpMethod: HTTPMethodType = HTTPMethodType.get,
    bodyObject: Encodable? = nil,
    parameters: [String: CustomStringConvertible] = [:],
    headers: [String: CustomStringConvertible] = [:]
  ) {
    self.path = path
    self.bodyObject = bodyObject
    self.httpMethod = httpMethod
    self.parameters = parameters
    self.baseURL = baseURL
    self.headers = headers
  }// end public init
}// end extension public struct OSCAHttpRequestResource

extension OSCAHttpRequestResource: OSCAHttpRequestResourceProtocol {}
