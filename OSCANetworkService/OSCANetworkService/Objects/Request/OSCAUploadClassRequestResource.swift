//
//  OSCAUploadClassRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 31.01.22.
//

import Foundation
import OSCAEssentials

/**
 `U`: Type of Parse class object for upload conforming to `OSCAParseClassObject`-protocol
 
 ```console
 curl -v -X POST \
 -H "X-Parse-Application-Id: APPLICATION-ID" \
 -H "X-Parse-REST-API-Key: API-KEY" \
 -H "Content-Type: application/json" \
 --data-raw '{
 "name": "Name",
 "address": "Address Street, No",
 "zip": "ZipCode",
 "city": "City",
 "phone": "0156 0404040",
 "email": "john.doe@example.com",
 "message": "This is test mail from cli",
 "contactId": "contactId"
 }' \
 'https://parse-dev.solingen.de/classes/ContactFormData'
 
 ```
 
 [POST-Request](https://stackoverflow.com/questions/60003622/swift-5-make-http-post-request)
 */
public struct OSCAUploadClassRequestResource<U: OSCAParseClassObject> {
  public typealias Response = ParseUploadResponse
  
  /// base url
  var baseURL: URL
  /// name of the parse class
  let uploadParseClass: String
  /// parse class object for upload
  public let uploadParseClassObject: U?
  /// http headers
  let headers: [String: CustomStringConvertible]
  
  public var requestUploadClass: URLRequest? {
    // synthesizing url
    let url = self.baseURL.appendingPathComponent("/classes/\(uploadParseClass)")
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
    }// end for header in headers
    // synthesizing HTTP body
    guard let uploadParseClassObject = self.uploadParseClassObject,
          let uploadParseClassObjectSerialized = try? OSCACoding.jsonEncoder().encode(uploadParseClassObject)
    else { return nil }
    
    urlRequest.httpBody = uploadParseClassObjectSerialized
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
              parseClass: String,
              uploadParseClassObject: U? = nil,
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.uploadParseClass = parseClass
    self.uploadParseClassObject = uploadParseClassObject
    self.headers = headers
  }// end public init
}// end public struct OSCAUploadClassRequestResource<U: Encodable>

extension OSCAUploadClassRequestResource: OSCAUploadRequestResourceProtocol {
  
}
