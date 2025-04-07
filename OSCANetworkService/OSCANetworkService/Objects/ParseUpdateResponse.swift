//
//  ParseUpdateResponse.swift
//  OSCANetworkService
//
//  Created by Ömer Kurutay on 19.06.23.
//

import Foundation
/**
 scheme of an update response to Parse
 ```json
 {
   "updatedAt": "2022-01-01T12:23:45.678Z"
 }
 ```
 */
public struct ParseUpdateResponse: Codable, Hashable, Equatable {
  public var updatedAt: Date?
}
