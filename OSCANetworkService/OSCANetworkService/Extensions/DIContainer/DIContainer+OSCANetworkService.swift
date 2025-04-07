//
//  DIContainer+networkServiceDI.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 06.02.23.
//

import Foundation
import OSCAEssentials

extension DIContainer {
  /// Type property closure for `OSCANetworkConfiguration`
  static var networkServiceConfig = { (diContainer: Resolvable) throws -> OSCANetworkConfiguration in
#if DEBUG
    print("make networkServiceConfig closure")
#endif
    guard let diContainer = diContainer as? DIContainer else { throw ResolvableError.cast(DIContainer.self) }
    @InjectedSafe(.by(type: AppConfiguration.self),
                  container: diContainer,
                  mode: .shared)
    var appConfig: AppConfiguration?
    guard let appConfig = appConfig else { throw DIContainer.Error.notImplemented }
    var headers: [String: CustomStringConvertible]?
    var baseURL: URL?
    switch diContainer.config {
    case .develop:
      headers = [
        "X-PARSE-CLIENT-KEY": appConfig.parseAPIKeyDev,
        "X-PARSE-APPLICATION-ID": appConfig.parseApplicationIDDev,
        "X-Parse-Master-Key": appConfig.parseMasterKeyDev
      ] // end headers
      baseURL = URL(string: appConfig.parseAPIBaseURLDev)
    case .production:
      headers = [
        "X-PARSE-CLIENT-KEY": appConfig.parseAPIKey,
        "X-PARSE-APPLICATION-ID": appConfig.parseApplicationID,
        "X-Parse-Master-Key": appConfig.parseMasterKey
      ] // end headers
      baseURL = URL(string: appConfig.parseAPIBaseURL)
    default:
      throw DIContainer.Error.notImplemented
    }// end switch case
    guard let baseURL = baseURL,
          let headers = headers else {
      throw DIContainer.Error.notImplemented
    } // end guard
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    ) // end let config
    return config
  }// end public static var networkServiceConfig
  
  /// Type property closure for `OSCANetworkService`
  static var networkService = { (diContainer: Resolvable) throws -> OSCANetworkService in
#if DEBUG
    print("make NetworkService closure")
#endif
    @InjectedSafe(.by(type: OSCANetworkConfiguration.self),
                      container: diContainer,
                      mode: .shared)
    var networkConfig: OSCANetworkConfiguration?
    guard let networkConfig = networkConfig else { throw DIContainer.Error.notImplemented }
    let dependencies = OSCANetworkServiceDependencies(config: networkConfig,
                                                      userDefaults: UserDefaults.standard)
    let networkService = OSCANetworkService.create(with: dependencies)
    return networkService
  }// public static var networkService
}// end extension DIContainer
