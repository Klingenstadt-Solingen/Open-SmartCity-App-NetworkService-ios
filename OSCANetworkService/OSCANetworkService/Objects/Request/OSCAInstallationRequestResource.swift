//
//  OSCAInstallationRequestResource.swift
//  
//
//  Created by Stephan Breidenbach on 17.06.22.
//

import Foundation
import OSCAEssentials

public struct OSCAInstallationRequestResource<T: OSCAParseClassObject> {
  public init(baseURL: URL,
              headers: [String : CustomStringConvertible],
              parseInstallation: ParseInstallation) {
    self.baseURL = baseURL
    self.headers = headers
    self.parseInstallation = parseInstallation
  }// end public init
  
  public typealias Response = T
  
  /// request resource's base URL
  var baseURL: URL
  /// request resource's header
  let headers: [String: CustomStringConvertible]
  /// request resource's Parse installation object
  let parseInstallation: ParseInstallation
  
  /// a ready made Parse installation request resource
  ///
  ///  if `parseInstallation`'s `objectId` is `nil`, this object doesn't exist on Parse backend
  ///  => `Post` - request
  ///  else `Get` - request
  ///
  ///  
  public var requestInstallation: URLRequest? {
    
    if let objectId = parseInstallation.objectId {
      // installation exists on Parse => GET
      // synthesizing url
      let url = baseURL.appendingPathComponent("/installations/\(objectId)")
      guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      else { return nil }
      // the synthesized url exists!
      guard let url = components.url else { return nil }
      // synthesizing request with url
      var urlRequest = URLRequest(url: url)
      // http method GET
      urlRequest.httpMethod = HTTPMethodType.get.rawValue
      // synthezising header
      for header in headers {
        urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
      }// end for
      // add installation id header
      if let installationId: String = parseInstallation.installationId {
        urlRequest.addValue(installationId, forHTTPHeaderField: "X-Parse-Installation-Id")
      } else {
        return nil
      }// end if
      // return request
      return urlRequest
    } else {
      // installation doesn't exist on Parse => POST
      // try to serialize parse installation object
      guard let parseInstallationSerialized = try? OSCACoding.jsonEncoder().encode(parseInstallation),
            // installation id is mandatory
            let _: String = parseInstallation.installationId,
            // device type is mandatory
            let _: ParseInstallation.DeviceType = parseInstallation.deviceType
      else { return nil }
      // synthesizing url
      let url = baseURL.appendingPathComponent("/installations")
      guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      else { return nil }
      // the synthesized url exists!
      guard let url = components.url else { return nil }
      // synthesizing request with url
      var urlRequest = URLRequest(url: url)
      // http method POST
      urlRequest.httpMethod = HTTPMethodType.post.rawValue
      // synthezising header
      for header in headers {
        urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
      }// for
      // http set header value json for content-type
      urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
      // set request http body
      urlRequest.httpBody = parseInstallationSerialized
      // return http request
      return urlRequest
    }// end if
  }// end internal var requestClass
  
  public var updateInstallation: URLRequest? {
    if let objectId = parseInstallation.objectId {
      // installation does exist on Parse => POST
      // try to serialize parse installation object
      guard let parseInstallationSerialized = try? OSCACoding.jsonEncoder().encode(parseInstallation),
            // object id is mandatory
            let _: String = parseInstallation.objectId,
            // installation id is mandatory
            let _: String = parseInstallation.installationId,
            // device type is mandatory
            let _: ParseInstallation.DeviceType = parseInstallation.deviceType
      else { return nil }
      // synthesizing url
      let url = baseURL.appendingPathComponent("/installations/\(objectId)")
      guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      else { return nil }
      // the synthesized url exists!
      guard let url = components.url else { return nil }
      // synthesizing request with url
      var urlRequest = URLRequest(url: url)
      // http method POST
      urlRequest.httpMethod = HTTPMethodType.put.rawValue
      // synthezising header
      for header in headers {
        urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
      }// for
      // add installation id header
      if let installationId: String = parseInstallation.installationId {
        urlRequest.addValue(installationId, forHTTPHeaderField: "X-Parse-Installation-Id")
      } else {
        return nil
      }// end if
      // http set header value json for content-type
      urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
      // set request http body
      urlRequest.httpBody = parseInstallationSerialized
      // return http request
      return urlRequest
    } else {
      return self.requestInstallation
    }
  }// end internal var updateInstallation
}// end public struct OSCAClassRequestResource

extension OSCAInstallationRequestResource: OSCAInstallationRequestResourceProtocol {}
