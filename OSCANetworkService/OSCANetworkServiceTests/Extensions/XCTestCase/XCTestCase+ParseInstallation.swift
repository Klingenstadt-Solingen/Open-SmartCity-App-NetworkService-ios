//
//  XCTestCase+ParseInstallation.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 04.07.22.
//

#if canImport(XCTest)
import Foundation
import XCTest
import OSCAEssentials

extension XCTestCase {
  /// factory method for Parse installation object
  ///  the `installationID` property is set with an new UUID
  /// - returns: `ParseInstallation` object without `objectId` with `deviceTye`= `ios`
  public func makeParseInstallation() throws -> ParseInstallation{
    var parseInstallation = ParseInstallation(objectId: nil,
                                              createdAt: nil,
                                              updatedAt: nil,
                                              deviceType: .ios)
    parseInstallation.installationId = UUID().uuidString.lowercased()
    return parseInstallation
  }// end func makeParseInstallation
}// end extension
#endif
