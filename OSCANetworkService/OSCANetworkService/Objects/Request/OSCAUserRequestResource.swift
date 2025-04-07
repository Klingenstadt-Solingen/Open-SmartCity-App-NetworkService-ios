//
//  OSCAUserRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 05.07.22.
//

import Foundation
import OSCAEssentials
/**
 
 ```console
 curl -vX GET \
 -H "X-Parse-Application-Id: APPLICATIONID" \
 -H "X-Parse-REST-API-Key: RESTAPIKEY" \
 -H "X-Parse-Master-Key: MASTERKEY" \
 -H "X-Parse-Session-Token: SESSIONTOKEN" \
 https://parse-dev.solingen.de/users/me
 ```
 */
public struct OSCAUserRequestResource<T: OSCAParseClassObject> {
  public init(baseURL: URL,
              parseSessionToken: String? = nil,
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.parseSessionToken = parseSessionToken
    self.headers = headers
  }// end public init
  
  public typealias Response = T
  
  /// base url
  var baseURL: URL
  /// session token
  let parseSessionToken: String?
  /// http headers
  let headers: [String: CustomStringConvertible]
  
  public var sessionTokenValidation: URLRequest? {
    // synthesizing HTTP body
    guard let parseSessionToken = self.parseSessionToken
    else { return nil }
    
    // synthesizing url
    let url = self.baseURL.appendingPathComponent("/users/me")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method POST
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    // http set header value parse session token
    urlRequest.addValue(parseSessionToken, forHTTPHeaderField: "X-Parse-Session-Token" )
    // synthesizing HTTP header
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }// end for header in headers
    // return http request
    return urlRequest
  }// end internal var requestUploadClass
}// end public struct OSCAUserRequestResource

extension OSCAUserRequestResource: OSCAUserRequestResourceProtocol {}
