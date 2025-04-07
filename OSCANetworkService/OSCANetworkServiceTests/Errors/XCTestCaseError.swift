//
//  XCTestCaseError.swift
//  OSCANetworkServiceTests
//
//  Created by Stephan Breidenbach on 07.07.22.
//

import Foundation
/// error cases
public enum XCTestCaseError: Error {
  /// `Info.plist` not found
  case plistNotFound
  /// `parse` API key not found in `Info.plist`
  case parseAPIKeyNotFound
  /// `parse`REST API key not found in `Info.plist`
  case parseRESTAPIKeyNotFound
  /// `parse`Master API key not found in `Info.plist`
  case parseMasterAPIKeyNotFound
  /// `parse` Application id not found in `Info.plist`
  case parseApplicationIDNotFound
  /// `parse` root URL not found in `info.plist`
  case parseRootURLNotFound
  /// `parse` root URL has no URL format
  case parseRootURLWrongFormat
  /// default location latitude not found in `info.plist`
  case defaultGeoPointLatitudeNotFound
  /// default location longitude not found in `info.plist`
  case defaultGeoPointLongitudeNotFound
  /// device's infos are wrong
  case malformedDeviceInfo
  /// malformed parse installation object
  case malformedParseInstallation
  /// login as an anonymous user failed
  case AnonymousUserLoginFailed
}// end XCTestCaseError

