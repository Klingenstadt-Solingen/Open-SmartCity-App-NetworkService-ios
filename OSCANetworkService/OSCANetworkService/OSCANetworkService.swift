//
//  OSCANetworkService.swift
//
//
//  Created by Mammut Nithammer on 06.01.22.
//  reviewed by Stephan Breidenbach on 26.01.22
//  reviewed by Stephan Breidenbach on 17.06.2022
//
import OSCAEssentials
import Combine
import Foundation

public struct OSCANetworkServiceDependencies {
  public var config: OSCANetworkConfiguration
  public var userDefaults: UserDefaults
  public var analyticsModule: OSCAAnalyticsModule?
  public init(config: OSCANetworkConfiguration,
              userDefaults: UserDefaults,
              analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.userDefaults = userDefaults
    self.config = config
    self.analyticsModule = analyticsModule
  }// end public init
}// end public struct OSCANetworkServiceDependencies

public final class OSCANetworkService {
  public enum Keys: String {
    case userDefaults = "de.osca.networkservice"
  }// end public enum Keys
  /// version of the module
  public var version: String = "1.0.4"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.networkService"
  
  public private(set) var config: OSCANetworkConfiguration
  
  public private(set) var userDefaults: UserDefaults
  
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  
  /** This is the only way to initialize the module!!! **
  - Parameter moduleDependencies: module dependencies
  ```
call: OSCANetworkService.create()
  ```
  */
  public static func create(with dependencies: OSCANetworkServiceDependencies) -> OSCANetworkService {
    let module: OSCANetworkService = OSCANetworkService(config: dependencies.config, userDefaults: dependencies.userDefaults)
    return module
  }// end public static func create
  
  /// initializes the contact module
  ///  - Parameter networkService: Your configured network service
  private init(config: OSCANetworkConfiguration,
               userDefaults: UserDefaults) {
    self.config = config
    self.userDefaults = userDefaults
    var bundle: Bundle?
#if SWIFT_PACKAGE
    bundle = Bundle.module
#else
    bundle = Bundle(identifier: self.bundlePrefix)
#endif
    guard let bundle: Bundle = bundle else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
  }// end public init with network service
  
  let flatMapResponseToPublisherClosure: ((Data, URLResponse) -> AnyPublisher<Data, OSCANetworkError>) = { data, response -> AnyPublisher<Data, OSCANetworkError> in
    guard let response = response as? HTTPURLResponse
    else {
      return .fail(OSCANetworkError.invalidResponse)
    }// end guard
    
    guard 200 ..< 300 ~= response.statusCode
    else {
      return .fail(OSCANetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
    }// end guard
    
    return .just(data)
  }// end flatMap
  
  func getDataTaskPublisher(_ request: URLRequest) -> AnyPublisher<Data, OSCANetworkError> {
    return self.config.session.dataTaskPublisher(for: request)
      .mapError { (error: URLError) -> OSCANetworkError in
        if error.isInternetConnectionError {
          return OSCANetworkError.isInternetConnectionError
        } else {
          return OSCANetworkError.invalidRequest
        }// end if
      }// end map error
      .flatMap { self.flatMapResponseToPublisherClosure($0, $1) }
      .eraseToAnyPublisher()
  }// end func getDataTaskPublisher
}// end public final class OSCANetworkService

extension OSCANetworkService {
  public func addSessionTokenHeader(sessionToken: String) -> Void {
    self.config.headers["X-Parse-Session-Token"] = sessionToken
  }// end public func addSessionTokenHeader
}// end extension OSCANetworkService

// MARK: - Login
extension OSCANetworkService {
  public func login(with deviceInfo: OSCADeviceInfo) -> /*AnyPublisher<ParseUser,Error>*/ Void {
    if let parseInstallation: ParseInstallation = deviceInfo.parseInstallation {
      // parse installation exists in device info
      // # 2) get installation object on Parse
      
    } else {
      // parse installation doesn't exist in device info
      // # 1) update parse installations:
      //      let parseInstallation: ParseInstallation = ParseInstallation(objectId: nil,
      //                                                                   createdAt: nil,
      //                                                                   updatedAt: nil,
      //                                                                   deviceType: .ios)
      //      put(OSCAInstallationRequestResource(baseURL: self.config.baseURL,
      //                                                                      parseInstallation: parseInstallation,
      //                                                                      headers: self.config.headers).requestInstallation)
    }// end if
    // # 3) anonymous login dev Parse
  }// end public func login
  
  public func login<Auth>(_ resource: OSCALoginRequestResource<Auth>) -> AnyPublisher<ParseUser, OSCANetworkError> {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    
    // there is a well formed request!
    guard let request = resource.loginRequest else {
      // return NetworkError: invalid request
      return Fail.init(outputType: ParseUser.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }
    // initialize data task publisher for well formed request
    
    // <(data, response) , URLError> ->
    return self.config.session.dataTaskPublisher(for: request)
      .mapError({ (error: URLError) -> OSCANetworkError in
        if error.isInternetConnectionError { return .isInternetConnectionError } else {
          return .invalidResponse
        }
      })
    // evaluate response
      .flatMap {  data, response -> AnyPublisher<Data, OSCANetworkError> in
        // response is a valid http url response!
        guard let response = response as? HTTPURLResponse else {
          // invalid response error
          return Fail.init(outputType: Data.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }
        // response status code is between 200 and 299!
        guard 200..<300 ~= response.statusCode else {
          // data loading error with status code
          return Fail.init(outputType: Data.self, failure: OSCANetworkError.dataLoadingError(statusCode: response.statusCode, data: data))
            .eraseToAnyPublisher()
        }
        // return data
        return Just(data)
        // with failure type OSCANetworkError
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
      }// end flatMap
      .flatMap { data -> AnyPublisher<ParseUser, OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: ParseUser?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(ParseUser.self, from: data)
        } catch {
          // json decoding failure
          return Fail.init(outputType: ParseUser.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let parseUserResponse = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: ParseUser.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(parseUserResponse)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func login
}// end extension final class OSCANetworkService

extension OSCANetworkService: OSCAModule {
}// end extension public final class OSCANetworkService

extension OSCANetworkService: OSCANetworkServiceProtocol {}
