// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
	.unsafeFlags(["-warn-deprecated-declarations"], .when(configuration: .debug))
]

let package = Package(
    name: "QizhKit",
	platforms: [
		.iOS(.v16),
		.macOS(.v13),
		.macCatalyst(.v13),
		.visionOS(.v1),
	],
    products: [
        .library(
            name: "QizhKit",
            targets: ["QizhKit"]
		),
    ],
	dependencies: [
		/// Introspect
		.package(url: "https://github.com/siteline/swiftui-introspect", from: "1.3.0"),
		
		/// Networking
		.package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.1"),
		
		/// Device parameters
		.package(url: "https://github.com/devicekit/DeviceKit", from: "5.5.0"),
		// .package(url: "https://github.com/qizh/DeviceKit", from: "5.2.3"),
		
		/// In-app Safari
		.package(url: "https://github.com/qizh/BetterSafariView", from: "2.4.3"),
		// .package(url: "https://github.com/stleamist/BetterSafariView", from: "2.4.2"),
		// .package(url: "https://github.com/shantanubala/BetterSafariView", branch: "main"),
		
		/// Apple's
		.package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
		
		/// Macros
		.package(url: "https://github.com/qizh/QizhMacroKit", exact: "1.0.12"),
	],
    targets: [
        .target(
            name: "QizhKit",
			dependencies: [
				/// Introspect
				.product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
				
				/// Networking
				"Alamofire",
				
				/// Device parameters
				"DeviceKit",
				
				/// In-app Safari
				"BetterSafariView",
				
				/// Apple's
				.product(name: "OrderedCollections", package: "swift-collections"),
				
				/// Macros
				.product(name: "QizhMacroKit", package: "QizhMacroKit"),
				.product(name: "QizhMacroKitClient", package: "QizhMacroKit"),
			],
			resources: [
				.process("PrivacyInfo.xcprivacy")
			]
		),
    ]
)
