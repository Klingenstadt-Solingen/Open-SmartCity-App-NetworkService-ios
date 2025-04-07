//
//  ParseElasticSearchQuery.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 30.05.22.
//

import Foundation
/// elastic search query object for Parse cloud function endpoint `elastic-search`
public struct ParseElasticSearchQuery {
  /// elastic search index
  public var index: String?
  /// elastic search query string
  public var query: String?
  /// return format
  public var raw: Bool
}// end public struct ParseElasticSearchQuery

// MARK: - public initializer / mutator
extension ParseElasticSearchQuery {
  public init( index: String,
               query: String,
               raw  : Bool = true
  ) {
    self.index = index
    self.query = query
    self.raw   = raw
  }// end public init
}// end extension public struct ParseElasticSearchQuery

extension ParseElasticSearchQuery: Codable {}
extension ParseElasticSearchQuery: Hashable {}
extension ParseElasticSearchQuery: Equatable {}
