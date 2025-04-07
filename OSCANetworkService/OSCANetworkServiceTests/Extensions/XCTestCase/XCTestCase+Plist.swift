//
//  XCTestCase+Plist.swift
//  OSCATestCaseExtension
//
//  Created by Stephan Breidenbach on 10.02.22.
//  Reviewed by Stephan Breidenbach on 10.06.2022.
//  Reviewed by Stephan Breidenbach on 15.06.22
// currentPlatformSupportsXCTest &&
#if canImport(XCTest)

import Foundation
import XCTest
import OSCAEssentials

///  [XCTestCase-Extension](https://dr-rost.medium.com/using-xctest-extension-in-a-swift-package-c954b8ed4d62)
extension XCTestCase {
  /// get a `dict` from `Info.plist`
  public var devPlistDict: [String: Any]? {
    // configure secrets
    var resolvedFilePath: String?
#if SWIFT_PACKAGE
    let bundle = Bundle.module
    var resourceName: String?
    
    resourceName = "API_Develop"
    guard let resourceName = resourceName,
          let filePath = bundle.path(forResource: resourceName, ofType: "plist") else { return nil }
    resolvedFilePath = filePath
#else
    let bundle: Bundle = Bundle(for: type(of: self))
    guard let filePath  = bundle.path(forResource: "API_Develop", ofType: "plist") else { return nil }
    resolvedFilePath = filePath
#endif
    guard let resolvedFilePath = resolvedFilePath
    else { return nil }
    let pathURL = URL(fileURLWithPath: resolvedFilePath)
    var apiData: Data?
    var dict: [String: Any]?
    do {
      apiData    = try Data(contentsOf: pathURL)
      dict        = try PropertyListSerialization.propertyList(from: apiData!,
                                                               options: [],
                                                               format: nil) as? [String: Any]
    } catch {
      print(error)
    }// end do catch
    return dict
  }// end var devPlistDict
  
  public var productionPlistDict: [String: Any]? {
    // configure secrets
    var resolvedFilePath: String?
#if SWIFT_PACKAGE
    let bundle = Bundle.module
    var resourceName: String?
    
    resourceName = "API_Release"
    guard let resourceName = resourceName,
          let filePath = bundle.path(forResource: resourceName, ofType: "plist") else { return nil }
    resolvedFilePath = filePath
#else
    let bundle: Bundle = Bundle(for: type(of: self))
    guard let filePath  = bundle.path(forResource: "API_Release", ofType: "plist") else { return nil }
    resolvedFilePath = filePath
#endif
    guard let resolvedFilePath = resolvedFilePath
    else { return nil }
    let pathURL = URL(fileURLWithPath: resolvedFilePath)
    var apiData: Data?
    var dict: [String: Any]?
    do {
      apiData    = try Data(contentsOf: pathURL)
      dict        = try PropertyListSerialization.propertyList(from: apiData!,
                                                               options: [],
                                                               format: nil) as? [String: Any]
    } catch {
      print(error)
    }// end do catch
    return dict
  }// end var productionPlistDict
  
  public func getDevDefaultLocation() throws -> (OSCAGeoPoint) {
    guard let dict = self.devPlistDict
    else { throw XCTestCaseError.plistNotFound }
    guard let defaultGeoPointLatitude = dict[Keys.Plist.defaultGeoPointLatitude] as? CustomStringConvertible,
          let defaultGeoPointLatitudeString = defaultGeoPointLatitude as? String,
          let defaultGeoPointLatitudeValue = Double(defaultGeoPointLatitudeString)
    else { throw XCTestCaseError.defaultGeoPointLatitudeNotFound}
    guard let defaultGeoPointLongitude = dict[Keys.Plist.defaultGeoPointLongitude] as? CustomStringConvertible,
          let defaultGeoPointLongitudeString = defaultGeoPointLongitude as? String,
          let defaultGeoPointLongitudeValue = Double(defaultGeoPointLongitudeString)
    else { throw XCTestCaseError.defaultGeoPointLongitudeNotFound}
    
    return OSCAGeoPoint(latitude: defaultGeoPointLatitudeValue, longitude: defaultGeoPointLongitudeValue)
  }// end func getDevDefaultLocation
  
  public func getProductionDefaultLocation() throws -> (OSCAGeoPoint) {
    guard let dict = self.productionPlistDict
    else { throw XCTestCaseError.plistNotFound }
    guard let defaultGeoPointLatitude = dict[Keys.Plist.defaultGeoPointLatitude] as? CustomStringConvertible,
          let defaultGeoPointLatitudeString = defaultGeoPointLatitude as? String,
          let defaultGeoPointLatitudeValue = Double(defaultGeoPointLatitudeString)
    else { throw XCTestCaseError.defaultGeoPointLatitudeNotFound}
    guard let defaultGeoPointLongitude = dict[Keys.Plist.defaultGeoPointLongitude] as? CustomStringConvertible,
          let defaultGeoPointLongitudeString = defaultGeoPointLongitude as? String,
          let defaultGeoPointLongitudeValue = Double(defaultGeoPointLongitudeString)
    else { throw XCTestCaseError.defaultGeoPointLongitudeNotFound}
    
    return OSCAGeoPoint(latitude: defaultGeoPointLatitudeValue, longitude: defaultGeoPointLongitudeValue)
  }// end func getProductionDefaultLocation
  
  public var jsonData: Data? {
    let name = String(describing: type(of: self))
    let data = try? getData(name: name)
    return data
  }// end var mockContentData
  
  public func getData(name: String, withExtension: String = ".json") throws -> Data {
    let bundle = Bundle(for: type(of: self))
    let fileUrl = bundle.url(forResource: name, withExtension: withExtension)
    let data = try Data(contentsOf: fileUrl!)
    return data
  }// end func getData
}// end extension XCTestCase

#endif
