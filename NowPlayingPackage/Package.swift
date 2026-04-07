// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NowPlayingPackage",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v18),
  ],
  products: [
    .library(
      name: "NowPlayingPackage",
      targets: ["NowPlayingPackage"],
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/MasterJ93/ATProtoKit.git", from: "0.32.5"),
    .package(url: "https://github.com/stleamist/BetterSafariView.git", from: "2.4.2"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.11.0"),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
    .package(url: "https://github.com/maiyama18/LicensesPlugin.git", from: "0.2.0"),
    .package(url: "https://github.com/kean/Nuke.git", from: "13.0.1"),
    .package(url: "https://github.com/RevenueCat/purchases-ios-spm.git", from: "5.67.0"),
    .package(url: "https://github.com/nnsnodnb/ScrollFlowLabel.git", from: "1.0.4"),
    .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "7.0.0"),
    .package(url: "https://github.com/kateinoigakukun/StubKit.git", from: "0.1.7"),
    .package(url: "https://github.com/SVProgressHUD/SVProgressHUD.git", from: "2.3.1"),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.63.2"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      from: "1.25.4",
      traits: [
        "ComposableArchitecture2Deprecations",
        // "ComposableArchitecture2DeprecationOverloads",
      ],
    ),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.12.0"),
    .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro.git", from: "0.6.0"),
    .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "13.2.0"),
    .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", from: "3.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
    .package(url: "https://github.com/Jake-Short/swiftui-image-viewer.git", from: "2.3.1"),
    .package(url: "https://github.com/mxcl/Version.git", from: "2.2.0"),
  ],
  targets: [
    .target(
      name: "NowPlayingPackage",
      dependencies: [
        .atProtoKit,
        .betterSafariView,
        .composableArchitecture,
        .firebaseAnalytics,
        .googleMobileAds,
        .googleUserMessagingPlatform,
        .imageViewer,
        .keychainAccess,
        .memberwiseInit,
        .nukeUI,
        .revenueCat,
        .scrollFlowLabel,
        .sfSafeSymbols,
        .svProgressHUD,
        .tagged,
        .version,
      ],
      resources: [
        .process("Resources"),
      ],
      plugins: [
        .licensesPlugin,
      ]
    ),
    .testTarget(
      name: "NowPlayingPackageTests",
      dependencies: [
        "NowPlayingPackage",
        .composableArchitecture,
        .dependenciesTestSupport,
        .stubKit,
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)

// MARK: - Target.Dependency
extension Target.Dependency {
  static var atProtoKit: Self {
    .product(
      name: "ATProtoKit",
      package: "ATProtoKit",
    )
  }

  static var betterSafariView: Self {
    .product(
      name: "BetterSafariView",
      package: "BetterSafariView",
    )
  }

  static var composableArchitecture: Self {
    .product(
      name: "ComposableArchitecture",
      package: "swift-composable-architecture",
    )
  }

  static var dependencies: Self {
    .product(
      name: "Dependencies",
      package: "swift-dependencies",
    )
  }

  static var dependenciesTestSupport: Self {
    .product(
      name: "DependenciesTestSupport",
      package: "swift-dependencies",
    )
  }

  static var firebaseAnalytics: Self {
    .product(
      name: "FirebaseAnalytics",
      package: "firebase-ios-sdk",
    )
  }

  static var googleMobileAds: Self {
    .product(
      name: "GoogleMobileAds",
      package: "swift-package-manager-google-mobile-ads",
    )
  }

  static var googleUserMessagingPlatform: Self {
    .product(
      name: "GoogleUserMessagingPlatform",
      package: "swift-package-manager-google-user-messaging-platform",
    )
  }

  static var imageViewer: Self {
    .product(
      name: "ImageViewer",
      package: "swiftui-image-viewer",
    )
  }

  static var keychainAccess: Self {
    .product(
      name: "KeychainAccess",
      package: "KeychainAccess",
    )
  }

  static var memberwiseInit: Self {
    .product(
      name: "MemberwiseInit",
      package: "swift-memberwise-init-macro",
    )
  }

  static var nukeUI: Self {
    .product(
      name: "NukeUI",
      package: "Nuke",
    )
  }

  static var revenueCat: Self {
    .product(
      name: "RevenueCat",
      package: "purchases-ios-spm",
    )
  }

  static var scrollFlowLabel: Self {
    .product(
      name: "ScrollFlowLabel",
      package: "ScrollFlowLabel",
    )
  }

  static var sfSafeSymbols: Self {
    .product(
      name: "SFSafeSymbols",
      package: "SFSafeSymbols",
    )
  }

  static var stubKit: Self {
    .product(
      name: "StubKit",
      package: "StubKit",
    )
  }

  static var svProgressHUD: Self {
    .product(
      name: "SVProgressHUD",
      package: "SVProgressHUD"
    )
  }

  static var tagged: Self {
    .product(
      name: "Tagged",
      package: "swift-tagged",
    )
  }

  static var version: Self {
    .product(
      name: "Version",
      package: "Version",
    )
  }
}

// MARK: - Target.PluginUsage
extension Target.PluginUsage {
  static var licensesPlugin: Self {
    .plugin(
      name: "LicensesPlugin",
      package: "LicensesPlugin",
    )
  }

  static var swiftLintBuildToolPlugin: Self {
    .plugin(
      name: "SwiftLintBuildToolPlugin",
      package: "SwiftLintPlugins",
    )
  }
}

let debugOtherSwiftFlags = [
  "-Xfrontend", "-warn-long-expression-type-checking=500",
  "-Xfrontend", "-warn-long-function-bodies=500",
  "-strict-concurrency=complete",
  "-enable-actor-data-race-checks",
]

for target in package.targets {
  // swiftSettings
  target.swiftSettings = [
    .unsafeFlags(debugOtherSwiftFlags, .when(configuration: .debug)),
  ]
  // plugins
  target.plugins = (target.plugins ?? []) + [
    .swiftLintBuildToolPlugin,
  ]
}
