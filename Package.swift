// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookKit",
    platforms: [
        .macOS(.v10_14), .iOS(.v10), .tvOS(.v10), .watchOS(.v2)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BookKit",
            targets: ["BookKit", "EpubKit"]),
        //.executable(name: "BookView",
          //  targets: ["BookView"]),
        .library(name: "EpubKit",
            targets: ["EpubKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.9"),
    .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.9.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "BookKit",
            dependencies: ["ZIPFoundation", "XMLCoder"]),
        .target(name: "BookView",
            dependencies: ["BookKit"]),
        .target(name: "EpubKit",
            dependencies: ["BookKit"]),
        .testTarget(
            name: "BookKitTests",
            dependencies: ["BookKit"]),
    ]
)
