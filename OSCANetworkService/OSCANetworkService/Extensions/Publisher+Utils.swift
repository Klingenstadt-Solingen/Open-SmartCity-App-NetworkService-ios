//
//  Publisher+Utils.swift
//
//
//  Created by Mammut Nithammer on 09.01.22.
//

import Combine
import Foundation

public extension Publisher {
  /// The flatMapLatest operator behaves much like the standard FlatMap operator, except that whenever
  /// a new item is emitted by the source Publisher, it will unsubscribe to and stop mirroring the Publisher
  /// that was generated from the previously-emitted item, and begin only mirroring the current one.
  func flatMapLatest<T: Publisher>(_ transform: @escaping (Self.Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
    map(transform).switchToLatest()
  }
}

public extension Publisher {
  static func empty() -> AnyPublisher<Output, Failure> {
    return Empty().eraseToAnyPublisher()
  }
  
  static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
    
    return Just(output)
      .catch { _ in AnyPublisher<Output, Failure>.empty() }
      .eraseToAnyPublisher()
  }
  
  static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
    return Fail(error: error).eraseToAnyPublisher()
  }
}
