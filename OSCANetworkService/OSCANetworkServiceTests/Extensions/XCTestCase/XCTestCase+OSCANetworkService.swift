//
//  XCTestCase+OSCANetworkService.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 04.07.22.
//

#if canImport(XCTest)
import Foundation
import XCTest
import OSCANetworkService

public extension XCTestCase {
  /// initializes a network service from `Info.plist` develop Parse
  private func getDevNetworkService(userDefaults: UserDefaults) throws -> OSCANetworkService {
    guard let dict = self.devPlistDict else { throw XCTestCaseError.plistNotFound }
    guard let parseAPIKey = dict[Keys.Plist.devParseAPIKey] as? CustomStringConvertible else { throw XCTestCaseError.parseAPIKeyNotFound}
    guard let parseAPIApplicationID = dict[Keys.Plist.devParseAPIApplicationID] as? CustomStringConvertible else { throw XCTestCaseError.parseApplicationIDNotFound}
    guard let parseAPIBaseURL = dict[Keys.Plist.devParseAPIRootURL] as? String else { throw XCTestCaseError.parseRootURLNotFound }
    guard let parseRESTAPIKey = dict[Keys.Plist.devParseRESTAPIKey] as? String else { throw XCTestCaseError.parseRESTAPIKeyNotFound }
    guard let parseMasterAPIKey = dict[Keys.Plist.devParseMasterAPIKey] as? String else { throw XCTestCaseError.parseMasterAPIKeyNotFound }
    // take headers from app config secrets
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": parseAPIKey,
      "X-PARSE-APPLICATION-ID": parseAPIApplicationID,
      "X-PARSE-REST-API-KEY": parseRESTAPIKey,
      "X-Parse-Master-Key": parseMasterAPIKey
    ]// end headers
    // take base url from app config secrets
    guard let baseURL = URL(string: parseAPIBaseURL) else { throw XCTestCaseError.parseRootURLWrongFormat}
    // network config
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    )// end let config
    // initialize network service
    let dependencies = OSCANetworkServiceDependencies(config: config, userDefaults: userDefaults)
    return OSCANetworkService.create(with: dependencies)
  }// end var networkService
  
  /// initializes a network service from `Info.plist`production Parse
  private func getProductionNetworkService(userDefaults: UserDefaults) throws -> OSCANetworkService {
    guard let dict = self.productionPlistDict else { throw XCTestCaseError.plistNotFound }
    guard let parseAPIKey = dict[Keys.Plist.parseAPIKey] as? CustomStringConvertible else { throw XCTestCaseError.parseAPIKeyNotFound}
    guard let parseAPIApplicationID = dict[Keys.Plist.parseAPIApplicationID] as? CustomStringConvertible else { throw XCTestCaseError.parseApplicationIDNotFound}
    guard let parseAPIBaseURL = dict[Keys.Plist.parseAPIRootURL] as? String else { throw XCTestCaseError.parseRootURLNotFound }
    guard let parseRESTAPIKey = dict[Keys.Plist.parseRESTAPIKey] as? String else { throw XCTestCaseError.parseRESTAPIKeyNotFound }
        guard let parseMasterAPIKey = dict[Keys.Plist.parseMasterAPIKey] as? String else { throw XCTestCaseError.parseMasterAPIKeyNotFound }
    // take headers from app config secrets
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": parseAPIKey,
      "X-PARSE-APPLICATION-ID":parseAPIApplicationID,
      "X-PARSE-REST-API-KEY": parseRESTAPIKey,
      "X-Parse-Master-Key": parseMasterAPIKey
    ]// end headers
    // take base url from app config secrets
    guard let baseURL = URL(string: parseAPIBaseURL) else { throw XCTestCaseError.parseRootURLWrongFormat}
    // network config
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    )// end let config
    // initialize network service
    let dependencies = OSCANetworkServiceDependencies(config: config, userDefaults: userDefaults)
    return OSCANetworkService.create(with: dependencies)
  }// end var networkService
}// end public extension XCTestCase

// MARK: - factory methods for network service
extension XCTestCase {
  /// factory method for developer network service
  /// - returns: `OSCANetworkService` object with developer Parse backend configuration
  public func makeDevNetworkService() throws -> OSCANetworkService{
    return try getDevNetworkService(userDefaults: makeUserDefaults(domainString: "de.osca.networkservice"))
  }// end func makeDevNetworkService
  
  /// factory method for production network service
  /// - returns: `OSCANetworkService` object with production Parse backend configuration
  public func makeProductionNetworkService() throws -> OSCANetworkService{
    return try getProductionNetworkService(userDefaults: makeUserDefaults(domainString: "de.osca.networkservice"))
  }// end func makeProductionNetworkService
}// end extension XCTestCase
#endif
