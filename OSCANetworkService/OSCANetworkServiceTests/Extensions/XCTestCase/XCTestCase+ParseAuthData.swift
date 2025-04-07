//
//  XCTestCase+ParseAuthData.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 04.07.22.
//

#if canImport(XCTest)
import Foundation
import XCTest
import OSCAEssentials

extension XCTestCase {
  /// factory method for Parse authentication data
  ///
  /// the `uuid` property is set with an new UUID
  /// - returns :`ParseAuthData` object
  public func makeParseAuthData() throws -> ParseAuthData{
    let uuid = UUID().uuidString
    return ParseAuthData(uuid: uuid)
  }// end func makePareAuthData
}// end extension XCTestCase
#endif
