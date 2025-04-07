//
//  OSCANetworkService+Update.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 02.02.23.
//

import Foundation
import OSCAEssentials
import Combine

// MARK: - Update
extension OSCANetworkService {
  
  /// Update method for requesting `ParseInstallation`object
  ///
  /// it updates a Parse-Installation element to the Parse mBaaS
  /// - returns: publisher with a `ParseInstallation`object on the `Output`and a possible `OSCANetworkError`on the `Fail`channel
  @discardableResult
  public func update<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCAInstallationRequestResourceProtocol {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // there is a well formed request!
    guard let request = resource.updateInstallation else {
      // return NetworkError: invalid request
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }
    // initialize data task publisher for well formed request
    
    // <(data, response) , URLError> ->
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: Request.Response?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(Request.Response.self, from: data)
        } catch {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let parseInstallation = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(parseInstallation)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func update with installation request resource
}// end extension OSCANetworkService
