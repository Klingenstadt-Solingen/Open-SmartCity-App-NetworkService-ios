// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")

let package = Package(
  name: "OSCANetworkService",
  defaultLocalization: "de",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(name: "OSCANetworkService",
             targets: ["OSCANetworkService"])
  ],// end products
  
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion))
  ],// end dependencies
  
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCANetworkService",
      dependencies: [
        /* OSCAEssentials */
        .product(name: "OSCAEssentials",
                 package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
      ],
      path: "OSCANetworkService/OSCANetworkService",
      exclude:["Info.plist"],
      resources: [.process("Resources")]
      ),

    .testTarget(
      name: "OSCANetworkServiceTests",
      dependencies: ["OSCANetworkService"],
      path: "OSCANetworkService/OSCANetworkServiceTests",
      exclude: ["Info.plist"],
      resources: [.process("Resources")]
    ),// end testTarget
  ]// end targets
)// end Package
