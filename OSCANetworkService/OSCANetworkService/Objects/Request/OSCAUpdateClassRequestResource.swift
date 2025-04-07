//
//  OSCAUpdateClassRequestResource.swift
//  OSCANetworkService
//
//  Created by Ömer Kurutay on 19.06.23.
//

import OSCAEssentials
import Foundation

public struct OSCAUpdateClassRequestResource<U: OSCAParseClassObject>: OSCAUpdateRequestResourceProtocol {
  public typealias Response = ParseUpdateResponse
  
  /// base url
  var baseURL: URL
  let objectId: String
  /// name of the parse class
  let updateParseClass: String
  /// parse class object for update
  public let updateParseClassObject: U?
  /// http headers
  let headers: [String: CustomStringConvertible]
  
  public var requestUpdateClass: URLRequest? {
    // synthesizing url
    let url = self.baseURL
      .appendingPathComponent("/classes/\(self.updateParseClass)/\(self.objectId)")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return nil }
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method POST
    urlRequest.httpMethod = HTTPMethodType.put.rawValue
    // http set header value json for content-type
    urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
    // synthesizing HTTP header
    for header in self.headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }
    // synthesizing HTTP body
    guard let updateParseClassObject = self.updateParseClassObject,
          let updateParseClassObjectSerialized = try? OSCACoding.jsonEncoder().encode(updateParseClassObject)
    else { return nil }
    
    urlRequest.httpBody = updateParseClassObjectSerialized
    // return http request
    return urlRequest
  }
  
  /**
   - Parameters:
   - baseURL: base URL of the Parse mbaas
   - objectId: The objectId of the object to be updated
   - parseClass: `String`representation of the Parse class name
   - updateParseClassObject: the object you want to update conformin to the `Encodable` protocol
   - headers: http request headers
   */
  public init(baseURL: URL,
              objectId: String,
              parseClass: String,
              updateParseClassObject: U? = nil,
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.objectId = objectId
    self.updateParseClass = parseClass
    self.updateParseClassObject = updateParseClassObject
    self.headers = headers
  }
}
