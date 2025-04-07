//
//  QueryResponse.swift
//
//
//  Created by Mammut Nithammer on 06.01.22.
//

import Foundation

/// Represents the response object of a parse-server query
public struct QueryResponse<T>: Decodable where T: Decodable {
  /// The results of the query
  public var results: [T]
  /// The count of objects of the query
  public let count: Int?
}// end

public struct FunctionResponse<T>: Decodable where T: Decodable {
  public var result: T
}// end internal struct FunctionResponse
