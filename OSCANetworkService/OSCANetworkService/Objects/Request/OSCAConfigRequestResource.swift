//
//  OSCAConfigRequestResource.swift
//  OSCANetworkService
//
//  Created by Ömer Kurutay on 28.03.22.
//

import Foundation
import OSCAEssentials


/**
 ```console
 curl -X GET \
 -H "X-Parse-Application-Id: ${APPLICATION_ID}" \
 -H "X-Parse-REST-API-Key: ${REST_API_KEY}" \
 `https://YOUR.PARSE-SERVER.HERE/parse/config`
 ```
 */
public struct OSCAConfigRequestResource<T: OSCAParseConfig> {
  public typealias Response = T
  
  var baseURL: URL
  let headers: [String: CustomStringConvertible]
  
  public var requestConfig: URLRequest? {
    let url = baseURL.appendingPathComponent("/config")
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    
    for header in headers {
      urlRequest.addValue(header.value.description,
                          forHTTPHeaderField: header.key)
    }// end for header in headers
    
    return urlRequest
  }// end requestConfig
  
  public init(baseURL: URL,
              headers: [String: CustomStringConvertible] = [:]) {
    self.baseURL = baseURL
    self.headers = headers
  }// end public init
}// end public struct OSCAConfigRequestResource

extension OSCAConfigRequestResource {
  
}// end extension public struct OSCAConfigRequestResource

extension OSCAConfigRequestResource: OSCANetworkConfigRequestResourceProtocol {}
