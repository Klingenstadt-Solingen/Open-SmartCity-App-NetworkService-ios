//
//  OSCAFunctionRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 20.05.22.
//

import Foundation
import OSCAEssentials

public struct OSCAFunctionRequestResource<P: Codable & Hashable & Equatable> {
  public init(baseURL: URL,
              cloudFunctionName: String,
              cloudFunctionParameter: P? = nil,
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.cloudFunctionName = cloudFunctionName
    self.cloudFunctionParameter = cloudFunctionParameter
    self.headers = headers
  }// end public init
  
  public typealias CloudFunctionParameter = P
  /// base URL of Parse BaaS
  var baseURL: URL
  /// cloud function name
  let cloudFunctionName: String
  /// cloud function input parameter (`json`encoded http body in a `POST`request)
  public let cloudFunctionParameter: P?
  /// http request headers
  let headers: [String: CustomStringConvertible]
  
  /// request resource for an `URLRequest` of an Parse BaaS cloud function
  public var requestFunction: URLRequest? {
    let url = baseURL.appendingPathComponent("/functions/\(self.cloudFunctionName)")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method POST
    urlRequest.httpMethod = HTTPMethodType.post.rawValue
    // http set header value json for content-type
    urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
    // synthesizing HTTP header
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }
    // synthesizing HTTP body
    guard let parameter = self.cloudFunctionParameter,
          let parameterSerialized = try? OSCACoding.jsonEncoder().encode(parameter)
    else { return nil }
    // add serialized json cloud function parameter to request's http body
    urlRequest.httpBody = parameterSerialized
    return urlRequest
  }// end internal var requestClass
  
  
}// end public struct OSCAFunctionRequestResource<T: Decodable>

extension OSCAFunctionRequestResource {
  public static func elasticSearch(baseURL: URL,
                                   headers: [String: CustomStringConvertible],
                                   cloudFunctionParameter: ParseElasticSearchQuery) -> OSCAFunctionRequestResource<ParseElasticSearchQuery> {
    let cloudFunctionName = "elastic-search"
    return OSCAFunctionRequestResource<ParseElasticSearchQuery>(baseURL: baseURL, cloudFunctionName: cloudFunctionName, cloudFunctionParameter: cloudFunctionParameter, headers: headers)
  }//end static func elasticSearch
}// end extension public struct OSCAFunctionRequestResource

extension OSCAFunctionRequestResource: OSCAFunctionRequestResourceProtocol {}
