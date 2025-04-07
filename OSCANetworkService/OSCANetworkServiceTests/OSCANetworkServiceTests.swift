//
//  OSCANetworkServiceTests.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 18.01.22.
//  Reviewed by Stephan Breidenbach on 14.06.2022
//
import XCTest
import UIKit
import Combine
import OSCAEssentials
@testable import OSCANetworkService

final class OSCANetworkServiceTests: XCTestCase {
  static let moduleVersion = "1.0.4"
  public enum Keys: String {
    case userDefaults = "de.osca.networkservice"
  }// end public enum Keys
  
  let deviceUUID: String = AppConfiguration().deviceUUID
  
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws -> Void {
    super.setUp()
    cancellables = []
  }// end override func setUp
  
  func testModuleInit() throws -> Void {
    let devNetworkService = try makeDevNetworkService()
    XCTAssertNotNil(devNetworkService, "NetworkService initialization failed!")
    XCTAssertEqual(devNetworkService.version, OSCANetworkServiceTests.moduleVersion)
    XCTAssertEqual(devNetworkService.bundlePrefix, "de.osca.networkService")
    XCTAssertNotNil(OSCANetworkService.bundle)
    XCTAssertNotNil(devPlistDict)
    XCTAssertNotNil(productionPlistDict)
  }// end func testModuleInit
  
  func testLoadObjects() throws -> Void {
    var testObjects = [Test]()
    var error: Error?
    let devNetworkService = try makeDevNetworkService()
    let expectation = self.expectation(description: "GetTestObjects")
    
    devNetworkService
      .download(OSCAClassRequestResource<Test>.test(limit: 1, baseURL: devNetworkService.config.baseURL, headers: devNetworkService.config.headers))
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch case
        
        expectation.fulfill()
      }, receiveValue: { objects in
        testObjects = objects
      })
      .store(in: &cancellables)
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(error)
    XCTAssertEqual(testObjects.count, 1)
    XCTAssertEqual(testObjects.first?.test, "TestString")
    XCTAssertNotNil(testObjects.first?.createdAt)
  }// end func testLoadObjects
  
  func testUploadObject() throws -> Void {
    var testObject = Test(test: "TestString")
    var error: Error?
    let devNetworkService = try makeDevNetworkService()
    
    let expectation = self.expectation(description: "UploadTestObject")
    
    devNetworkService.upload(OSCAUploadClassRequestResource<Test>(baseURL: devNetworkService.config.baseURL,
                                                             parseClass: "TestClass",
                                                             uploadParseClassObject: testObject,
                                                             headers: devNetworkService.config.headers))
    .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        break
      case let .failure(encounteredError):
        error = encounteredError
      }
      
      expectation.fulfill()
    }, receiveValue: { receivedObject in
      testObject.objectId = receivedObject.objectId
      testObject.createdAt = receivedObject.createdAt
    })
    .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertEqual(testObject.test, "TestString")
    XCTAssertNotNil(testObject.objectId)
    XCTAssertNotNil(testObject.createdAt)
  }// end func testUploadObjects
  
#if !DEBUG
  func testFetchImageFileData() throws -> Void {
    let devNetworkService = try makeDevNetworkService()
    guard let baseURL = URL(string:"https://geoportal.solingen.de/buergerservice1/ol3/solingen_symbols") else { return }
    let requestResource = OSCAImageFileDataRequestResource(
      baseURL: baseURL,
      fileName: "XE_Erholung_Spielplatz",
      mimeType: ".png")
    var testObject: Data?
    var error: Error?
    
    let expectation = self.expectation(description: "FetchImageFileData")
    
    devNetworkService.fetch(requestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }
        expectation.fulfill()
      }, receiveValue: { dataObject in
        testObject = dataObject
      })
      .store(in: self.&cancellables)
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(error)
    XCTAssertNotNil(testObject)
    let uiImage: UIImage? = UIImage(data:testObject!)
    XCTAssertNotNil(uiImage)
  }// end func testFetchData
#endif
  
  func testDeviceUUID() throws -> Void {
    let deviceInfo = try makeDeviceInfo()
    for i in 0...99 {
      if i == 1 {}
      guard let deviceUUID = UIDevice.current.identifierForVendor?.uuidString,
            let uuid = deviceInfo.uuid
      else { XCTFail("Identifier for Vendor is not available on \(i). test run!"); throw XCTestCaseError.malformedDeviceInfo }
      XCTAssertEqual(uuid, deviceUUID,"Identifier for Vendor is not equal on \(i). test run!")
    }// end for in 0 ... 99
  }// end testDeviceUUID
  
  func testProductionLogin() throws -> Void {
    var error: Error?
    var productionUser: ParseUser?
    let expectation = self.expectation(description: "ProductionLoginTestWithAuthData")
    
    let productionNetworkService = try makeProductionNetworkService()
    let parseAuthData = try makeParseAuthData()
    
    let loginRequestResource = OSCALoginRequestResource<ParseAuthData>(baseURL: productionNetworkService.config.baseURL,
                                                                       parseInstallationId: self.deviceUUID,
                                                                       authDataObject: parseAuthData,
                                                                       headers: productionNetworkService.config.headers)
    productionNetworkService.login(loginRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedUser in
        productionUser = receivedUser
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(productionUser)
    XCTAssertNotNil(productionUser?.sessionToken)
  }// end func testProductionLogin
  
  func testProductionFetchSession() throws -> Void {}
  
  func testProductionPutInstallationRequest() throws -> Void {
    var error: Error?
    var receivedParseInstallation: ParseInstallation?
    var parseInstallation: ParseInstallation = try makeParseInstallation()
    let expectation = self.expectation(description: "productionPutInstallationRequest")
    let productionNetworkService = try makeProductionNetworkService()
    
    let installationRequestResource = OSCAInstallationRequestResource<ParseInstallation>(baseURL: productionNetworkService.config.baseURL,
                                                                      headers: productionNetworkService.config.headers,
                                                                      parseInstallation: parseInstallation)
    
    productionNetworkService.put(installationRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedInstallation in
        receivedParseInstallation = receivedInstallation
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedParseInstallation)
    parseInstallation.objectId = receivedParseInstallation?.objectId
    parseInstallation.createdAt = receivedParseInstallation?.createdAt
    // assert, the installation was fresh created on parse
    XCTAssertNil(receivedParseInstallation?.updatedAt)
    XCTAssertNotNil(parseInstallation.objectId)
    XCTAssertNotNil(parseInstallation.createdAt)
  }// end func testProductionPutInstallationRequest
  
  func testDevFetchSession() throws -> Void {}
  
  func testDevPutInstallationRequest() throws -> Void {
    var error: Error?
    let userDefaults: UserDefaults = try makeUserDefaults()
    var deviceInfo: OSCADeviceInfo
    do {
      deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      if let installationId = deviceInfo.parseInstallation?.installationId {
        deviceInfo.parseInstallation?.installationId = installationId.lowercased()
      }// end if
    } catch {
      deviceInfo = try makeDeviceInfo()
    }// end do catch

    var receivedParseInstallation: ParseInstallation?
    var parseInstallation: ParseInstallation
    if let parseInstallationFromDeviceInfo = deviceInfo.parseInstallation {
      parseInstallation = parseInstallationFromDeviceInfo
    } else {
      parseInstallation = try makeParseInstallation()
    }// end if
    
    let expectation = self.expectation(description: "devPutInstallationRequest")
    let devNetworkService = try makeDevNetworkService()
    
    let installationRequestResource = OSCAInstallationRequestResource<ParseInstallation>(baseURL: devNetworkService.config.baseURL,
                                                                      headers: devNetworkService.config.headers, parseInstallation: parseInstallation)
    
    devNetworkService.put(installationRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedInstallation in
        receivedParseInstallation = receivedInstallation
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedParseInstallation)
    guard var receivedParseInstallation = receivedParseInstallation,
          receivedParseInstallation.objectId != nil,
          receivedParseInstallation.createdAt != nil
    else {
      return XCTFail("No valid parse installation received!")
    }// end
    let expectation2 = self.expectation(description: "devPutInstallationRequest")
    devNetworkService.fetch(installationRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation2.fulfill()
      }, receiveValue: { receivedInstallation in
        receivedParseInstallation = receivedInstallation
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedParseInstallation)
    
    if deviceInfo.parseInstallation!.objectId != nil {
      // not the first time parse installation from server
      guard receivedParseInstallation.objectId == deviceInfo.parseInstallation!.objectId,
            receivedParseInstallation.createdAt == deviceInfo.parseInstallation!.createdAt
      else { return XCTFail("No valid parse installation received!") }
      // save new parse installation in device info
      deviceInfo.parseInstallation = receivedParseInstallation
    } else {
      // first time parse Installation from server
      deviceInfo.parseInstallation = receivedParseInstallation
    }// end if
    // save device info in user defaults
    XCTAssertNoThrow(try userDefaults.setObject(deviceInfo, forKey: OSCADeviceInfo.Keys.userDefaults.rawValue))
  }// end func testPutInstallationRequest
  
  func testDevUpdateInstallationRequest() throws -> Void {
    var error: Error?
    let userDefaults: UserDefaults = try makeUserDefaults()
    var deviceInfo: OSCADeviceInfo
    do {
      deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      if let installationId = deviceInfo.parseInstallation?.installationId {
        deviceInfo.parseInstallation?.installationId = installationId.lowercased()
      }// end if
    } catch {
      try testDevPutInstallationRequest()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end do catch
    var receivedParseInstallation: ParseInstallation?
    var parseInstallation: ParseInstallation
    if let parseInstallationFromDeviceInfo = deviceInfo.parseInstallation {
      parseInstallation = parseInstallationFromDeviceInfo
    } else {
      XCTFail("No valid user defaults object!")
      return
    }// end if
    XCTAssertNotNil(parseInstallation.objectId)
    XCTAssertNotNil(parseInstallation.installationId)
    // fill parse installation with additional data
    parseInstallation.deviceType = .ios
    if let model = deviceInfo.model {
      parseInstallation.deviceModel = model
    }
    if parseInstallation.deviceToken == nil {
      parseInstallation.deviceToken = UUID().uuidString.lowercased()
    }
    if parseInstallation.appVersion  == nil {
      parseInstallation.appVersion = "20220704.1"
    }
    if parseInstallation.osType == nil {
      parseInstallation.osType = deviceInfo.systemName
    }
    if parseInstallation.osVersion == nil {
      parseInstallation.osVersion = deviceInfo.systemVersion
    }
    parseInstallation.channels = ["baustellen-ios", "coronastats-ios", "meldungen-ios"]
    
    let expectation = self.expectation(description: "devUpdateInstallationRequest")
    let devNetworkService = try makeDevNetworkService()
    
    let installationRequestResource = OSCAInstallationRequestResource<ParseInstallation>(baseURL: devNetworkService.config.baseURL,
                                                                      headers: devNetworkService.config.headers, parseInstallation: parseInstallation)
    
    
    devNetworkService.update(installationRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedInstallation in
        receivedParseInstallation = receivedInstallation
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedParseInstallation)
    guard let receivedParseInstallation = receivedParseInstallation,
          receivedParseInstallation.updatedAt != nil
    else {
      return XCTFail("No valid parse installation received!")
    }// end
    
    if deviceInfo.parseInstallation!.objectId != nil {
      parseInstallation.updatedAt = receivedParseInstallation.updatedAt
      deviceInfo.parseInstallation = parseInstallation
    } else {
      // first time parse Installation from server
      deviceInfo.parseInstallation = receivedParseInstallation
    }// end if
    // save device info in user defaults
    XCTAssertNoThrow(try userDefaults.setObject(deviceInfo, forKey: OSCADeviceInfo.Keys.userDefaults.rawValue))
  }// end func updateInstallationRequest
  
  func testDevFetchInstallation() throws -> Void {
    var error: Error?
    let userDefaults: UserDefaults = try makeUserDefaults()
    var deviceInfo: OSCADeviceInfo
    do {
      deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      if let installationId = deviceInfo.parseInstallation?.installationId {
        deviceInfo.parseInstallation?.installationId = installationId.lowercased()
      }// end if
    } catch {
      try testDevPutInstallationRequest()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end do catch
    var receivedParseInstallation: ParseInstallation?
    var parseInstallation: ParseInstallation
    if let parseInstallationFromDeviceInfo = deviceInfo.parseInstallation {
      parseInstallation = parseInstallationFromDeviceInfo
    } else {
      XCTFail("No valid user defaults object!")
      return
    }// end if
    XCTAssertNotNil(parseInstallation.objectId)
    XCTAssertNotNil(parseInstallation.installationId)
    let expectation = self.expectation(description: "devFetchInstallationRequest")
    let devNetworkService = try makeDevNetworkService()
    
    let installationRequestResource = OSCAInstallationRequestResource<ParseInstallation>(baseURL: devNetworkService.config.baseURL,
                                                                      headers: devNetworkService.config.headers, parseInstallation: parseInstallation)
    
    devNetworkService.fetch(installationRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedInstallation in
        receivedParseInstallation = receivedInstallation
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedParseInstallation)
    guard let receivedParseInstallation = receivedParseInstallation,
          receivedParseInstallation.objectId != nil,
          receivedParseInstallation.createdAt != nil,
          let deviceInfoParseInstallation = deviceInfo.parseInstallation,
          let deviceInfoInstallationId = deviceInfoParseInstallation.installationId,
          let receivedInstallationId = receivedParseInstallation.installationId,
          deviceInfoInstallationId == receivedInstallationId else {
      return XCTFail("No valid parse installation received!")
    }// end
    
    if deviceInfo.parseInstallation!.objectId != nil {
      // not the first time parse installation from server
      guard receivedParseInstallation.objectId == deviceInfo.parseInstallation!.objectId,
            receivedParseInstallation.createdAt == deviceInfo.parseInstallation!.createdAt
      else { return XCTFail("No valid parse installation received!") }
      // save new parse installation in device info
      deviceInfo.parseInstallation = receivedParseInstallation
    } else {
      // first time parse Installation from server
      deviceInfo.parseInstallation = receivedParseInstallation
    }// end if
    // save device info in user defaults
    XCTAssertNoThrow(try userDefaults.setObject(deviceInfo, forKey: OSCADeviceInfo.Keys.userDefaults.rawValue))
  }// end func test fetch installation
  
  func testDevLogin() throws -> Void {
    var error: Error?
    // user defaults
    let userDefaults: UserDefaults = try makeUserDefaults()
    // device info
    var deviceInfo: OSCADeviceInfo
    // retrieve device info from UD
    do {
      deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      if let installationId = deviceInfo.parseInstallation?.installationId {
        deviceInfo.parseInstallation?.installationId = installationId.lowercased()
      }// end if
    } catch {
      try testDevPutInstallationRequest()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end do catch
    // develop parse user object
    var devUser: ParseUser?
    
    // develop parse network service
    let devNetworkService = try makeDevNetworkService()
    // parse auth data
    var parseAuthData: ParseAuthData?
    if let user = deviceInfo.parseUser,
       let authData = user.authData,
       let authDataId = authData.anonymous.id {
      parseAuthData = ParseAuthData(uuid: authDataId)
    } else {
      if let authData = try? makeParseAuthData() {
        parseAuthData = authData
      } else {
        XCTFail("No valid auth data id!")
      }// end if
    }// end if
    // parse installation id
    guard let parseInstallationId = deviceInfo.parseInstallation?.installationId
    else {
      XCTFail("No valid installation id!")
      return
    }// end guard
    // parse auth data
    guard let parseAuthData = parseAuthData else {
      XCTFail("No valid Auth Data!")
      return
    }// end guard

    // anonymous login with valid installation id
    let expectation = self.expectation(description: "DevLoginTestWithAuthData")
    // login request resource
    let loginRequestResource = OSCALoginRequestResource<ParseAuthData>(baseURL: devNetworkService.config.baseURL,
                                                                       parseInstallationId: parseInstallationId,
                                                                       authDataObject: parseAuthData,
                                                                       headers: devNetworkService.config.headers)
    devNetworkService.login(loginRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedUser in
        devUser = receivedUser
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(devUser)
    XCTAssertNotNil(devUser?.sessionToken)
    if deviceInfo.parseUser != nil {
      if let authData =  devUser?.authData {
        deviceInfo.parseUser!.authData = authData
      }// end if
      if let username = devUser?.username {
        deviceInfo.parseUser!.username = username
      }// end inf
      if let sessionToken = devUser?.sessionToken {
        deviceInfo.parseUser!.sessionToken = sessionToken
      } else {
        XCTFail("Invalid session Token in retrieved user!")
        return
      }// end if
    } else {
      deviceInfo.parseUser = devUser
    }// end if
    if let deviceAuthData = deviceInfo.parseUser!.authData,
       let authData = parseAuthData.authData {
      XCTAssertEqual(deviceAuthData, authData)
    } else {
      deviceInfo.parseUser!.authData = parseAuthData.authData
    }// end if
    // save device info in user defaults
    XCTAssertNoThrow(try userDefaults.setObject(deviceInfo, forKey: OSCADeviceInfo.Keys.userDefaults.rawValue))
  }// end func testDevLogin
  
  func testDevValidateSessionToken() throws -> Void {
    var error: Error?
    // user defaults
    let userDefaults: UserDefaults = try makeUserDefaults()
    // device info
    var deviceInfo: OSCADeviceInfo
    // retrieve device info from UD
    do {
      deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      if let installationId = deviceInfo.parseInstallation?.installationId {
        deviceInfo.parseInstallation?.installationId = installationId.lowercased()
      }// end if
    } catch {
      try testDevPutInstallationRequest()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end do catch
    
    // develop parse user object
    var devUser: ParseUser
    var receivedUser: ParseUser?
    
    if let user = deviceInfo.parseUser{
      devUser = user
    } else {
      try testDevLogin()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
        guard let user = deviceInfo.parseUser
        else {
          XCTFail("No valid User!")
          return
        }// end guard
        devUser = user
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end if
    
    // develop network service
    let devNetworkService = try makeDevNetworkService()
    
    guard let sessionToken = devUser.sessionToken
    else {
      XCTFail("no valid session token available!")
      return
    }// end guard
    let expectation = self.expectation(description: "SessionTokenValidation")
    
    // user request resource
    let userRequestResource = OSCAUserRequestResource<ParseUser>(baseURL: devNetworkService.config.baseURL,
                                                      parseSessionToken: sessionToken,
                                                      headers: devNetworkService.config.headers)
    devNetworkService.fetch(userRequestResource)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { parseUser in
        receivedUser = parseUser
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 20)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedUser)
    XCTAssertNotNil(receivedUser?.sessionToken)
    guard let receivedUser = receivedUser else {
      XCTFail("No valid User received!")
      return
    }// end guard
    guard let receivedSessionToken = receivedUser.sessionToken
    else {
      XCTFail("No valid session Token received!")
      return
    }// end guard
    XCTAssertEqual(receivedSessionToken, sessionToken)
    deviceInfo.parseUser = receivedUser
    // save device info in user defaults
    XCTAssertNoThrow(try userDefaults.setObject(deviceInfo, forKey: OSCADeviceInfo.Keys.userDefaults.rawValue))
  }// end func testDevValidateSessionToken
  
  func testFetchSession() throws -> Void {
    var error: Error?
    // user defaults
    let userDefaults: UserDefaults = try makeUserDefaults()
    // device info
    var deviceInfo: OSCADeviceInfo
    // retrieve device info from UD
    do {
      deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      if let installationId = deviceInfo.parseInstallation?.installationId {
        deviceInfo.parseInstallation?.installationId = installationId.lowercased()
      }// end if
    } catch {
      try testDevPutInstallationRequest()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end do catch
    
    // parse installation
    var parseInstallation: ParseInstallation
    
    if let devParseInstallation = deviceInfo.parseInstallation {
      parseInstallation = devParseInstallation
    } else {
      try testDevFetchSession()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
        guard let devParseInstallation = deviceInfo.parseInstallation
        else {
          XCTFail("No valid Parse Installation!")
          return
        }// end guard
        parseInstallation = devParseInstallation
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end if
    
    // develop parse user object
    var devUser: ParseUser
    
    if let user = deviceInfo.parseUser{
      devUser = user
    } else {
      try testDevLogin()
      do {
        deviceInfo = try userDefaults.getObject(forKey: OSCADeviceInfo.Keys.userDefaults.rawValue, castTo: OSCADeviceInfo.self)
        guard let user = deviceInfo.parseUser
        else {
          XCTFail("No valid User!")
          return
        }// end guard
        devUser = user
      } catch {
        XCTFail("No valid user defaults object!")
        return
      }// end do catch
    }// end if
    
    // develop network service
    let devNetworkService = try makeDevNetworkService()
    
    let expectation = self.expectation(description: "DevFetchParseSessionWithUserObject")
    // parse session
    var parseSession: ParseSession
    if let deviceSession = deviceInfo.parseSession {
      parseSession = deviceSession
    } else {
      parseSession = try makeParseSession(from: devUser, with: parseInstallation)
    }// end if
    
    var receivedParseSession: ParseSession?
    guard let sessionToken = parseSession.sessionToken else { XCTFail("invalid session token"); return  }
    
    let sessionRequestResource: OSCASessionRequestResource = OSCASessionRequestResource<ParseSession>(baseURL: devNetworkService.config.baseURL,
                                                                                        headers: devNetworkService.config.headers, sessionToken: sessionToken)
    let publisher: AnyPublisher<ParseSession, OSCANetworkError> = devNetworkService.fetch(sessionRequestResource)
    publisher
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          break
        case let .failure(encounteredError):
          error = encounteredError
        }// end switch completion
        expectation.fulfill()
      }, receiveValue: { receivedSession in
        receivedParseSession = receivedSession
      })
      .store(in: &self.cancellables)
    waitForExpectations(timeout: 100)
    XCTAssertNil(error)
    XCTAssertNotNil(receivedParseSession)
    guard let installationId = receivedParseSession?.installationId,
          let deviceInstallationId = parseInstallation.installationId
    else {
      XCTFail("No valid installation id received!")
      return
    }// end guard
    XCTAssertEqual(installationId, deviceInstallationId)
    
    guard let sessionToken = receivedParseSession?.sessionToken,
          let deviceSessionToken = devUser.sessionToken
    else {
      XCTFail("No valid session token received!")
      return
    }// end guard
    XCTAssertEqual(sessionToken, deviceSessionToken)
    
    deviceInfo.parseSession = receivedParseSession
    // save device info in user defaults
    XCTAssertNoThrow(try userDefaults.setObject(deviceInfo, forKey: OSCADeviceInfo.Keys.userDefaults.rawValue))
  }// end func testFetchSession
}// end final class OSCANetworkServiceTests

struct Test: OSCAParseClassObject {
  static var parseClassName: String = "TestClass"
  
  var updatedAt: Date?
  var objectId: String?
  var test: String?
  var createdAt: Date?
}// end struct Test: Codablew

extension OSCAClassRequestResource {
  static func test(limit: Int = 1000,
                   baseURL: URL,
                   headers: [String: CustomStringConvertible],
                   query: [String: CustomStringConvertible] = [:]) -> OSCAClassRequestResource<Test> {
    var parameters = query
    parameters["limit"] = "\(limit)"
    let parseClass = Test.parseClassName
    return OSCAClassRequestResource<Test>(baseURL: baseURL,
                                          parseClass: parseClass,
                                          parameters: parameters,
                                          headers: headers)
  }// end static func test
}// end extension public struct OSCAClassRequestResource

// MARK: - factory methods
extension OSCANetworkServiceTests {
  public func makeUserDefaults() throws -> UserDefaults {
    let domainString = Self.Keys.userDefaults.rawValue
    return try makeUserDefaults(domainString: domainString)
  }// end public func makeUserDefaults
}// end extension final class OSCANetworkServiceTests
