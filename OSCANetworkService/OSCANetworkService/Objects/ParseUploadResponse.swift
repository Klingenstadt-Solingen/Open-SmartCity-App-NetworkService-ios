//
//  ParseUploadResponse.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 31.01.22.
//

import Foundation
/**
 scheme of an upload response to Parse
 ```json
 {
 "objectId": "gr6j9DYEZY",
 "createdAt": "2022-01-19T15:33:58.177Z"
 }
 ```
 */
public struct ParseUploadResponse {
  public var objectId: String?
  public var createdAt: Date?
}// end struct ParseUploadResponse

extension ParseUploadResponse: Codable {}
extension ParseUploadResponse: Hashable {}
extension ParseUploadResponse: Equatable {}
