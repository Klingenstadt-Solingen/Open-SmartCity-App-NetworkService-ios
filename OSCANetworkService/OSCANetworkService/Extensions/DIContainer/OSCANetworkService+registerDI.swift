//
//  OSCANetworkService+registerDI.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 07.02.23.
//

import Foundation
import OSCAEssentials

// MARK: OSCANetworkService dependencies
extension OSCANetworkService {
  /// register `OSCANetworkService` and it's dependencies to `config` respecting `DIContainer`
  /// * `AppConfiguration`
  /// * `UserDefaults`
  /// * `OSCANetworkConfiguration`
  /// * `OSCANetworkService`
  /// - Parameter config: default `.production`
  public static func registerDI(_ config: OSCAConfig = .production) throws -> Void {
    let diContainer = DIContainer.container(for: config)
    // register developer app configuration closure to DI Container
    diContainer.register(.by(type: AppConfiguration.self),
                            DIContainer.appConfiguration)
    // register developer user defaults closure to DI Container
    diContainer.register(.by(type: UserDefaults.self),
                            DIContainer.userDefaults)
    // register developer network configuration closure to DI Container
    diContainer.register(.by(type: OSCANetworkConfiguration.self),
                            DIContainer.networkServiceConfig)
    // register developer network service closure to DI container
    diContainer.register(.by(type: OSCANetworkService.self),
                            DIContainer.networkService)
  }// end public static func registerDI
}// end extension public final class OSCANetworkService
