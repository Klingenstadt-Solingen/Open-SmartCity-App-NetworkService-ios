//
//  OSCANetworkService+Upload.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 30.01.23.
//

import Foundation
import Combine
import OSCAEssentials

// MARK: - Upload
extension OSCANetworkService {
  /// Generic upload method with generc `U`  conforming to `Encodable` -protocol.
  ///
  /// it puts a Parse-class element to the Parse mBaaS
  /// - Returns: publisher with a Parse upload response on the `Output`, and a possible `Error` on the `Fail` channel
  @discardableResult
  public func upload<Request>(_ resource: Request) -> AnyPublisher<Request.Response, Error> where Request: OSCAUploadRequestResourceProtocol {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    guard let request = resource.requestUploadClass else {
      return .fail(OSCANetworkError.invalidRequest)
    }// end request
    return self.config.session.dataTaskPublisher(for: request)
      .mapError { _ in OSCANetworkError.invalidRequest }
      .flatMap { data, response -> AnyPublisher<Data, Error> in
        guard let response = response as? HTTPURLResponse
        else {
          return .fail(OSCANetworkError.invalidResponse)
        }// end guard
        
        guard 200 ..< 300 ~= response.statusCode else {
          return .fail(OSCANetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
        }
        
        return .just(data)
      }// end flatMap
      .decode(type: Request.Response.self, decoder: OSCACoding.jsonDecoder())
      .flatMap { requestResult -> AnyPublisher<Request.Response, Error> in
          .just(requestResult)
      }// end flatMap
      .eraseToAnyPublisher()
  }// end public func upload
  
  @discardableResult
  public func upload<Request>(_ resource: Request) -> AnyPublisher<Request.Response, Error> where Request: OSCAUploadFileRequestResourceProtocol {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    guard let request = resource.requestUploadFile
    else {
      return .fail(OSCANetworkError.invalidRequest)
    }// end guard
    return self.config.session.dataTaskPublisher(for: request)
      .mapError { _ in OSCANetworkError.invalidRequest }
      .flatMap { data, response -> AnyPublisher<Data, Error> in
        guard let response = response as? HTTPURLResponse
        else {
          return .fail(OSCANetworkError.invalidResponse)
        }// end guard
        
        guard 200 ..< 300 ~= response.statusCode
        else {
          return .fail(OSCANetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
        }// end guard
        
        return .just(data)
      }// end flatMap
      .decode(type: Request.Response.self, decoder: OSCACoding.jsonDecoder())
      .flatMap { requestResult -> AnyPublisher<Request.Response,Error> in
          .just(requestResult)
      }// end flatMap
      .eraseToAnyPublisher()
  }// end public func uploadFile
}// end extension final class OSCANetworkService

extension OSCANetworkService: OSCANetworkServiceUploadProtocol {}
