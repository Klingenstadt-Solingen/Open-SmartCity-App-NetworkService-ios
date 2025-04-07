//
//  OSCADeleteClassRequestResource.swift
//  OSCANetworkService
//
//  Created by Ömer Kurutay on 26.06.23.
//

import OSCAEssentials
import Foundation

public struct OSCADeleteClassRequestResource: OSCADeleteRequestResourceProtocol {
  /// base url
  var baseURL                 : URL
  /// name of the parse class
  let deleteParseClass        : String
  /// parse class objectId for delete
  let deleteParseClassObjectId: String?
  /// http headers
  let headers                 : [String: CustomStringConvertible]
  
  public var requestDeleteClassObject: URLRequest? {
    guard let objectId = self.deleteParseClassObjectId else { return nil }
    // synthesizing url
    let url = self.baseURL
      .appendingPathComponent("/classes/\(self.deleteParseClass)/\(objectId)")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return nil }
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method DELETE
    urlRequest.httpMethod = HTTPMethodType.delete.rawValue
    // synthesizing HTTP header
    for header in self.headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }
    // return http request
    return urlRequest
  }
  
  /**
   - Parameters:
   - baseURL: base URL of the Parse mbaas
   - parseClass: `String`representation of the Parse class name
   - deleteParseClassObjectId: the id of the object you want to delete
   - headers: http request headers
   */
  public init(baseURL                 : URL,
              parseClass              : String,
              deleteParseClassObjectId: String? = nil,
              headers                 : [String : CustomStringConvertible]) {
    self.baseURL                  = baseURL
    self.deleteParseClass         = parseClass
    self.deleteParseClassObjectId = deleteParseClassObjectId
    self.headers                  = headers
  }
}
