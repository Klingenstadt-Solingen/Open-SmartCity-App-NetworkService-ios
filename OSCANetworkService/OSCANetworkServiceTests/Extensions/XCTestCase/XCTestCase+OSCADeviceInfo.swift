//
//  XCTestCase+OSCADeviceInfo.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 04.07.22.
//
#if canImport(XCTest)
import Foundation
import XCTest
import OSCAEssentials

// MARK: - factory method 
extension XCTestCase {
  /// factory method for device informations
  /// - returns: `OSCADeviceInfo` object with all device infos
  public func makeDeviceInfo() throws -> OSCADeviceInfo {
    let parseInstallation = try makeParseInstallation()
    let parseUser: ParseUser? = nil
    let deviceInfo: OSCADeviceInfo = OSCADeviceInfo(parseInstallation: parseInstallation, parseUser: parseUser)
    return deviceInfo
  }// end public func makeDeviceInfo
}// end extension XCTestCase
#endif
