//
//  ParseUploadFileResponse.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 03.02.23.
//

import Foundation
/**
 scheme of a file upload response to Parse
 ```json
 {
 "url": "https://parse-dev.examplecity.de/files/examplecityapp/2202c988c14e06ea8a9266f3ea8cbbdf.jpeg",
 "name": "filename.extension"
 }
 ```
 */
public struct ParseUploadFileResponse {
  public var url: String?
  public var name: String?
}// end public struct ParseUploadFileResponse

extension ParseUploadFileResponse: Codable {}
extension ParseUploadFileResponse: Hashable {}
extension ParseUploadFileResponse: Equatable {}
