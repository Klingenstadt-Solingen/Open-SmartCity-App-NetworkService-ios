//
//  OSCASessionRequestResource.swift
//  OSCANetworkService
//
//
//  Created by Stephan Breidenbach on 19.06.22.
//

import Foundation
import OSCAEssentials

public struct OSCASessionRequestResource<T: OSCAParseClassObject> {
  public init(baseURL: URL,
              headers: [String : CustomStringConvertible],
              sessionToken: String) {
    self.baseURL = baseURL
    self.headers = headers
    self.sessionToken = sessionToken
  }// end public init
  
  public typealias Response = T
  
  /// request resource's base URL
  var baseURL: URL
  /// request resource's header
  let headers: [String: CustomStringConvertible]
  /// request resource's Parse installation object
  let sessionToken: String

  /// a ready made Parse Session request resource
  ///
  ///  if `parseSession`'s `objectId` is `nil`, this object doesn't exist on Parse backend
  ///  => `GET` - request
  ///  else `Get` - request
  ///
  ///
  public var requestSession: URLRequest? {
    let url = baseURL.appendingPathComponent("/sessions/me")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return nil }
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method GET
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    // add session token header
    urlRequest.addValue(sessionToken, forHTTPHeaderField: "X-Parse-Session-Token")
    // synthezising header
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    } // for
    // return http request
    return urlRequest
  } // end internal var requestSession
} // end public struct OSCASessionRequestResource

extension OSCASessionRequestResource: OSCASessionRequestResourceProtocol {}
