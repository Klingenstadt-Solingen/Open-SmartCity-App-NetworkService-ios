//
//  OSCACoding.swift
//
//
//  Created by Mammut Nithammer on 11.01.22.
//

import Foundation

public enum OSCACoding {}

extension OSCACoding {
  /// The JSON Encoder setup with the correct `dateEncodingStrategy`
  /// strategy for `OSCA`.
  public static func jsonEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = dateEncodingStrategy
    return encoder
  }
  
  /// The JSON Decoder setup with the correct `dateDecodingStrategy`
  /// strategy for `OSCA`. This encoder is used to decode all data received
  /// from the server.
  public static func jsonDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = dateDecodingStrategy
    return decoder
  }
  
  //    /// The Parse Encoder is used to JSON encode all `OSCA-Objects`s and
  //    /// types in a way meaninful for a Parse Server to consume.
  //    static func oscaEncoder() -> OSCAEncoder {
  //        ParseEncoder(
  //            dateEncodingStrategy: dateEncodingStrategy
  //        )
  //    }
}

extension OSCACoding {
  public enum DateEncodingKeys: String, CodingKey {
    case iso
    case type = "__type"
  }
  
  public static let dateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return dateFormatter
  }()
  
  public static let dateFormatterWithoutMS: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return dateFormatter
  }()
  
  public static let dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .custom { date, encoder in
    var container = encoder.container(keyedBy: DateEncodingKeys.self)
    try container.encode("Date", forKey: .type)
    let dateString = dateFormatter.string(from: date)
    try container.encode(dateString, forKey: .iso)
  }
  
  public static let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .custom({ (decoder) -> Date in
    do {
      let container = try decoder.singleValueContainer()
      let decodedString = try container.decode(String.self)
      
      if decodedString.contains(".") {
        if let date = dateFormatter.date(from: decodedString) {
          return date
        } else {
          throw ParseError(
            code: .unknownError,
            message: "An invalid date string was provided when decoding dates."
          )
        }
      } else {
        if let date = dateFormatterWithoutMS.date(from: decodedString) {
          return date
        } else {
          throw ParseError(
            code: .unknownError,
            message: "An invalid date string was provided when decoding dates."
          )
        }
      }
      
      
    } catch {
      let container = try decoder.container(keyedBy: DateEncodingKeys.self)
      
      if
        let decoded = try container.decodeIfPresent(String.self, forKey: .iso),
        let date = dateFormatter.date(from: decoded) {
        return date
      } else {
        throw ParseError(
          code: .unknownError,
          message: "An invalid date string was provided when decoding dates."
        )
      }
    }
  })
  
  
}
