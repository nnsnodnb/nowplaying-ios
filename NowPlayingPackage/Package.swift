// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NowPlayingPackage",
  products: [
    .library(
      name: "NowPlayingPackage",
      targets: ["NowPlayingPackage"],
    ),
  ],
  targets: [
    .target(
      name: "NowPlayingPackage",
    ),
    .testTarget(
      name: "NowPlayingPackageTests",
      dependencies: ["NowPlayingPackage"],
    ),
  ]
)
