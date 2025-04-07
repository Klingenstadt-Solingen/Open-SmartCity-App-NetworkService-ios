//
//  DIContainerNetworkServiceTests.swift
//  OSCANetworkServiceTests
//
//  Created by Stephan Breidenbach on 07.02.23.
//

import XCTest
import Foundation
import Combine
import OSCAEssentials
@testable import OSCANetworkService

final class DIContainerNetworkServiceTests: XCTestCase {
  override func setUpWithError() throws -> Void {
    try super.setUpWithError()
    try OSCANetworkService.registerDI(.develop)
    try OSCANetworkService.registerDI(.production)
  }// end override func setUpWithError
  
  override func tearDownWithError() throws -> Void {
    DIContainer.container(for: .develop).removeAllDependencies()
    DIContainer.container(for: .production).removeAllDependencies()
    try super.tearDownWithError()
  }// end override func tearDownWithError
  
  /// Are two references to a `.shared`injected `OSCANetworkService`object  really referencing the same object?
  func testSharedInjected() throws -> Void {
    @Injected(container: DIContainer.container(for: .develop))
    var first: OSCANetworkService
    @Injected(container: DIContainer.container(for: .develop))
    var second: OSCANetworkService
    @Injected(container: DIContainer.container(for: .develop),
              mode: .new)
    var third: OSCANetworkService
    XCTAssertTrue(first === second, "first and second object are NOT the same!")
    XCTAssertFalse(first === third, "first and third object ARE the same!")
    XCTAssertFalse(second === third, "second and third object ARE the same!")
  }// end func testInjected
  
  /// Is a `lazy` injected reference to an `OSCANetworkService` object really evaluated and the object initialized first when accessed?
  func testLazyInjectedSafe() throws -> Void {
    @LazyInjectedSafe(container: DIContainer.container(for: .develop),
                      mode: .shared)
    var first: OSCANetworkService?
    DIContainer.container(for: .develop).remove(.by(type: OSCANetworkService.self))
    XCTAssertNil(first, "first object ALREADY exists!")
    DIContainer.container(for: .develop).register(.by(type: OSCANetworkService.self),
                                                  DIContainer.networkService)
    XCTAssertNil(first, "first object ALREADY exists!")
    @LazyInjectedSafe(container: DIContainer.container(for: .develop),
                      mode: .shared)
    var second: OSCANetworkService?
    XCTAssertNotNil(second, "second object was NOT lazy initialized and does NOT exist!")
  }// end func testLazyInjectedSafe
  
  /// Are two `weak` references to a `.shared` injected `OSCANetworkService` object really referencing the same object,
  /// and are these references automatically `nil`, when the object ist unregistered?
  func testWeakInjected() throws -> Void {
    @WeakInjected(container: DIContainer.container(for: .develop),
                  mode: .shared)
    var first: OSCANetworkService?
    XCTAssertNotNil(first, "first object does NOT exist!")
    
    @WeakInjected(container: DIContainer.container(for: .develop),
                  mode: .shared)
    var second: OSCANetworkService?
    XCTAssertNotNil(second, "second object does NOT exist!")
    XCTAssertTrue(first === second, "first and second object are NOT the same!")
    DIContainer.container(for: .develop).remove(.by(type: OSCANetworkService.self))
    XCTAssertNil(first, "first object still exists!")
    XCTAssertNil(second, "second object still exists!")
  }// end func testWeakInjected
  
}// end final class DIContainerNetworkServiceTests
