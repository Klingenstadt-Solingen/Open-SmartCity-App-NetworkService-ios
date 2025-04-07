//
//  OSCANetworkService+Delete.swift
//  OSCANetworkService
//
//  Created by Ömer Kurutay on 26.06.23.
//

import OSCAEssentials
import Foundation
import Combine

// MARK: - Delete
extension OSCANetworkService {
  @discardableResult
  public func delete<Request>(_ resource: Request) -> AnyPublisher<Data, OSCANetworkError> where Request: OSCADeleteRequestResourceProtocol {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    guard let request = resource.requestDeleteClassObject else {
      return Fail.init(outputType: Data.self,
                       failure: OSCANetworkError.invalidRequest)
      .eraseToAnyPublisher()
    }
    
    return self.getDataTaskPublisher(request)
  }
}
