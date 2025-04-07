//
//  XCTestCase+UserDefaults.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 04.07.22.
//
#if canImport(XCTest)
import Foundation
import OSCAEssentials
import XCTest

// MARK: - factory method for user defaults
extension XCTestCase {
  public func makeUserDefaults(domainString: String) throws -> UserDefaults {
    guard let userDefaults = UserDefaults(suiteName: domainString)
    else { throw OSCAObjectSavableError.noValidUserDefaults}
    return userDefaults
  }// end public func makeUSerDefaults
}// end extension XCTestCase
#endif
