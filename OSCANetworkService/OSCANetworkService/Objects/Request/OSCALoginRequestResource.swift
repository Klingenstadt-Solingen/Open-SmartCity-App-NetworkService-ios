//
//  OSCALoginRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 14.06.22.
//

import Foundation
import OSCAEssentials
/**
 `Auth`: Type of Parse authentication object `ParseAuthData` conforming to `Encodable`-protocol
 
 ```console
 curl -vX POST \
 -H "X-Parse-Application-Id: APPLICATIONID" \
 -H "X-PARSE-CLIENT-KEY: PARSE_API_KEY" \
 -H "X-Parse-Installation-Id: PARSE_ISTALLATION_ID" \
 -H "Content-Type: application/json" \
 -H "X-Parse-Revocable-Session: 1" \
 -d '{"authData":{"anonymous":{"id":"UUID"}}}' \
 https://parse.solingen.de/users
 ```
 
 [POST-Request](https://stackoverflow.com/questions/60003622/swift-5-make-http-post-request)
 */
public struct OSCALoginRequestResource<Auth: Encodable> {
  /// base url
  var baseURL: URL
  /// UUID for `Parse installation id
  let parseInstallationId: String?
  /// parse class object for upload
  let authDataObject: Auth?
  /// http headers
  let headers: [String: CustomStringConvertible]
  
  internal var loginRequest: URLRequest? {
    // synthesizing HTTP body
    guard let authDataObject = self.authDataObject,
          let authDataObjectSerialized = try? OSCACoding.jsonEncoder().encode(authDataObject)
    else { return nil }
    
    // synthesizing url
    let url = self.baseURL.appendingPathComponent("/users")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method POST
    urlRequest.httpMethod = HTTPMethodType.post.rawValue
    // http set header value parse installation id
    guard let parseInstallationId = self.parseInstallationId
    else {
      return nil
    }// end guard
    // revocable session header
    urlRequest.addValue("1", forHTTPHeaderField: "X-Parse-Revocable-Session")
    // installation id header
    urlRequest.addValue(parseInstallationId, forHTTPHeaderField: "X-Parse-Installation-Id" )
    // http set header value json for content-type
    urlRequest.addValue("Application/json", forHTTPHeaderField: "Content-Type")
    // synthesizing HTTP header
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }// end for header in headers
    // set request http body
    urlRequest.httpBody = authDataObjectSerialized
    // return http request
    return urlRequest
  }// end internal var requestUploadClass
  
  /**
   - Parameters:
   - baseURL: base URL of the Parse mbaas
   - parseClass: `String`representation of the Parse class name
   - uploadParseClassObject: the object you want to upload conformin to the `Encodable` protocol
   - headers: http request headers
   */
  public init(baseURL: URL,
              parseInstallationId: String?,
              authDataObject: Auth?,
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.parseInstallationId = parseInstallationId
    if let authDataObject = authDataObject {
      self.authDataObject = authDataObject
    } else {
      self.authDataObject = ParseAuthData.AuthData(anonymous: ParseAuthData.AuthData.ID(id: parseInstallationId)) as? Auth
    }// end if
    self.headers = headers
  }// end public init
}// end public struct OSCALoginRequestResource<U: Encodable>
