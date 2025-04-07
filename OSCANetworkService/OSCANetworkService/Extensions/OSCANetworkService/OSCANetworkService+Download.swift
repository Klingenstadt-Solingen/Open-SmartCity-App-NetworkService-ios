//
//  OSCANetworkService+Download.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 30.01.23.
//

import Foundation
import Combine
import OSCAEssentials

// MARK: - Download
extension OSCANetworkService {
  @discardableResult
  public func download<Request>(_ resource: Request) -> AnyPublisher<[Request.Response], Error> where Request: OSCAClassRequestResourceProtocol {
    guard let request = resource.requestClass else { return .fail(OSCANetworkError.invalidRequest) }
    return self.getDataTaskPublisher(request)
      .decode(type: QueryResponse<Request.Response>.self, decoder: OSCACoding.jsonDecoder())
      .flatMap { queryResponse -> AnyPublisher<[Request.Response], Error> in
          .just(queryResponse.results)
      }// end flatMap
      .eraseToAnyPublisher()
  }// end public func download with class request resource
  
  @discardableResult
  public func download<Request>(_ resource: Request) -> AnyPublisher<Request.Response, Error> where Request: OSCANetworkConfigRequestResourceProtocol {
    guard let request = resource.requestConfig else { return .fail(OSCANetworkError.invalidRequest) }
    
    return self.getDataTaskPublisher(request)
      .decode(type: Request.Response.self, decoder: OSCACoding.jsonDecoder())
      .eraseToAnyPublisher()
  }// end public func download with config request resource
  
  @discardableResult
  public func download<T>(_ resource: OSCAHttpRequestResourceProtocol) -> AnyPublisher<T, Error> where T: Decodable {
    guard let request = resource.request else { return .fail(OSCANetworkError.invalidRequest) }
    
    return self.getDataTaskPublisher(request)
      .decode(type: T.self, decoder: OSCACoding.jsonDecoder())
      .eraseToAnyPublisher()
  }// end public func download with http request resource
}// end extension public final class OSCANetworkService
