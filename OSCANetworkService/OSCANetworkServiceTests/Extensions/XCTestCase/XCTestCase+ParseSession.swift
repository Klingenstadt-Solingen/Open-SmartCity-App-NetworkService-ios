//
//  XCTestCase+ParseSession.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 04.07.22.
//

#if canImport(XCTest)
import Foundation
import XCTest
import OSCAEssentials

extension XCTestCase {
  /// factory method for Parse Session object
  /// the `user` property is set with a `ParseUser` object
  /// - parameter user: parse `ParseUser` object which will be injected into the `ParseSession` object
  /// - parameter installation: parse `ParseInstallation` object injected in to the `ParseSession`object
  /// - returns: `ParseSession` object
  public func makeParseSession(from user: ParseUser, with installation: ParseInstallation) throws -> ParseSession{
    guard let installationId = installation.installationId,
          let sessionToken = user.sessionToken
    else { throw XCTestCaseError.AnonymousUserLoginFailed }
    var parseSession = ParseSession(user: user, installationId: installationId)
    parseSession.sessionToken = sessionToken
    return parseSession
  }// end func makeParseSession
}// end extension XCTestCase
#endif
