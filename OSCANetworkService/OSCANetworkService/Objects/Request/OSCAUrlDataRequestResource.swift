//
//  OSCAUrlDataRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 01.02.23.
//


import Foundation
import OSCAEssentials

public struct OSCAUrlDataRequestResource<T: OSCAUrlData> {
  public init(url: URL? = nil) {
    self.url = url
  }// end public init
  
  public typealias Response = T
  
  public var url: URL? = nil
  public var requestUrlData: URLRequest? {
    // the url exists!
    guard let url = self.url else { return nil }
    // synthesizing request with request url
    var urlRequest = URLRequest(url: url)
    // http method GET
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    return urlRequest
  }// end requestData
}// end public struct OSCAUrlDataRequestResource

extension OSCAUrlDataRequestResource: OSCAUrlDataRequestResourceProtocol {}
