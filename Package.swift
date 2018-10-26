// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "configen",
  products: [
    .executable(name: "configen", targets: ["configen"]),
    ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .branch("0.40200.0")), .package(url: "https://github.com/objecthub/swift-commandlinekit.git", .branch("0.2.5")),
    ],
  targets: [
    .target(
      name: "configen",
      dependencies: ["SwiftSyntax", "CommandLineKit"],
      path: "Sources"),
    ]
)
