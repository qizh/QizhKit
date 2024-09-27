// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
	.unsafeFlags(["-warn-deprecated-declarations"], .when(configuration: .debug))
]

let package = Package(
    name: "QizhKit",
	platforms: [
		.iOS(.v16),
		.visionOS(.v1),
	],
    products: [
        .library(
            name: "QizhKit",
            targets: ["QizhKit"]
		),
    ],
	dependencies: [
		.package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
		.package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.1"),
		.package(url: "https://github.com/devicekit/DeviceKit", from: "5.5.0"),
		// .package(url: "https://github.com/qizh/DeviceKit", from: "5.2.3"),
		// .package(url: "https://github.com/stleamist/BetterSafariView", from: "2.4.2"),
		// .package(url: "https://github.com/shantanubala/BetterSafariView", branch: "main"),
		.package(url: "https://github.com/qizh/BetterSafariView", from: "2.4.3"),
		.package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
		
		/// Temporary, while I can't add New Package Dependency using Xcode
		.package(url: "https://github.com/qizh/CollectionConcurrencyKit", from: "0.2.1"),
	],
    targets: [
        .target(
            name: "QizhKit",
			dependencies: [
				.product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
				"Alamofire",
				"DeviceKit",
				"BetterSafariView",
				.product(name: "OrderedCollections", package: "swift-collections"),
				"CollectionConcurrencyKit",
			]
		),
    ]
)
