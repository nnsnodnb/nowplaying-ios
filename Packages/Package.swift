// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Packages",
    products: [
        .library(name: "Packages", targets: ["Packages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.6.0"),
        .package(url: "https://github.com/RxSwiftCommunity/Action.git", from: "5.0.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", from: "5.0.2"),
        .package(url: "https://github.com/krimpedance/KRProgressHUD.git", from: "3.4.7"),
        .package(url: "https://github.com/nnsnodnb/ScrollFlowLabel.git", from: "1.0.4"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "4.1.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "Packages",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "Action", package: "Action"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "KRProgressHUD", package: "KRProgressHUD"),
                .product(name: "ScrollFlowLabel", package: "ScrollFlowLabel"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "SnapKit", package: "SnapKit"),
            ]
        ),
    ]
)
