//
//  OSCAUploadFileRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 02.02.23.
//

import Foundation
import OSCAEssentials

/**
 ```console
 curl -X POST \
 -H "X-Parse-Application-Id: ${APPLICATION_ID}" \
 -H "X-Parse-REST-API-Key: ${REST_API_KEY}" \
 -H "Content-Type: image/jpeg" \
 --data-binary '@myPicture.jpg' \
 'https://YOUR.PARSE-SERVER.HERE/parse/files/pic.jpg'
 ```
 */
public struct OSCAUploadFileRequestResource {
  public typealias Response = ParseUploadFileResponse
  
  /// base url
  var baseURL: URL
  /// image data for upload
  let uploadFile: Data?
  /// http headers
  let headers: [String: CustomStringConvertible]
  
  public var requestUploadFile: URLRequest? {
    // synthesizing url
    let url = self.baseURL.appendingPathComponent("/files/Defect-\(UUID().uuidString).jpeg")
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    // the synthesized url exists!
    guard let url = components.url else { return nil }
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method POST
    urlRequest.httpMethod = HTTPMethodType.post.rawValue
    // http set header value json for content-type
    urlRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
    // synthesizing HTTP header
    for header in headers {
      urlRequest.addValue(header.value.description, forHTTPHeaderField: header.key)
    }// end for header in headers
    urlRequest.httpBody = self.uploadFile
    // return http request
    return urlRequest
  }// end public var requestUploadFile
  
  /**
   - Parameters:
   - baseURL: base URL of the Parse mbaas
   - uploadImage: the image you want to upload
   - headers: http request headers
   */
  public init(baseURL: URL,
              uploadFile: Data? = nil,
              headers: [String : CustomStringConvertible]) {
    self.baseURL = baseURL
    self.uploadFile = uploadFile
    self.headers = headers
  }// end public init
}// end public struct

extension OSCAUploadFileRequestResource: OSCAUploadFileRequestResourceProtocol {}
