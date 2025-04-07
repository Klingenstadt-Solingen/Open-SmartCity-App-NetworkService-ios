//
//  OSCAImageDataRequestResource.swift
//  OSCAImageDataRequestResource
//
//  Created by Stephan Breidenbach on 31.03.22.
//

import Foundation
import OSCAEssentials

public struct OSCAImageDataRequestResource<T: OSCAImageData> {
  public typealias Response = T
  
  public var objectId: String? = nil
  var baseURL: URL? = nil
  var fileName: String? = nil
  var mimeType: String? = nil
  public var requestImageData: URLRequest? {
    // synthesizing url
    guard let baseURL = self.baseURL,
          let categoryId = self.objectId,
          !categoryId.isEmpty,
          let fileName = self.fileName,
          !fileName.isEmpty,
          let mimeType = self.mimeType,
          !mimeType.isEmpty else { return nil }
    
    let url = baseURL.appendingPathComponent("\(fileName)\(mimeType)")
    let decodedUrl = URL(string: url.description.removingPercentEncoding ?? url.absoluteString)
    // the synthesized url exists!
    guard let components = URLComponents(url: decodedUrl ?? url, resolvingAgainstBaseURL: false),
          let url = components.url else { return nil }
    // synthesizing request with request url
    var urlRequest = URLRequest(url: url)
    // http method GET
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    return urlRequest
  }// end requestData
}// end public struct OSCAImageDataRequestResource

// MARK: - initializers and mutators
extension OSCAImageDataRequestResource {
  public init( objectId: String,
               baseURL: URL,
               fileName: String,
               mimeType: String
  ){
    self.objectId = objectId
    self.baseURL = baseURL
    self.fileName = fileName
    self.mimeType = mimeType
  }// end public init
}// end extension public struct OSCAImageDataRequestResource

extension OSCAImageDataRequestResource: OSCAImageDataRequestResourceProtocol {}
