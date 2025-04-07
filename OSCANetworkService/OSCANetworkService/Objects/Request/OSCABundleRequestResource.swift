//
//  BundleRequestResource.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 18.03.22.
//

import Foundation
import OSCAEssentials

public struct OSCABundleRequestResource<T: OSCAParseClassObject & Hashable> {
  public typealias Response = T
  public init(bundle: Bundle,
              fileName: String) {
    self.bundle = bundle
    self.fileName = fileName
  }// end public init
  
  let bundle: Bundle
  let fileName: String
  
  public var requestJSON: (bundle: Bundle, fileURL: URL)? {
    guard !fileName.isEmpty else { return nil }
    let fileNameSplit = fileName.components(separatedBy: ".")
    guard fileNameSplit.count == 2,
          let fileURL = bundle.url(forResource: fileNameSplit[0], withExtension: fileNameSplit[1]) else { return nil }
    return (bundle: bundle, fileURL: fileURL)
  }// end requestJSON
}// end public struct OSCABundleRequestResource

extension OSCABundleRequestResource: OSCABundleRequestResourceProtocol {}
