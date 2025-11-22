// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QizhKit",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v17),
		.macOS(.v14),
		.macCatalyst(.v17),
	],
    products: [
        .library(
            name: "QizhKit",
            targets: ["QizhKit"]
		),
    ],
	dependencies: [
		/// Introspect
		.package(url: "https://github.com/siteline/swiftui-introspect", from: "26.0.0"),
		
		/// Networking
		.package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.2"),
		
		/// Device parameters
		.package(url: "https://github.com/devicekit/DeviceKit", from: "5.7.0"),
		// .package(url: "https://github.com/qizh/DeviceKit", from: "5.2.3"),
		
		/// In-app Safari
		.package(url: "https://github.com/qizh/BetterSafariView", from: "2.4.4"),
		// .package(url: "https://github.com/stleamist/BetterSafariView", from: "2.4.2"),
		// .package(url: "https://github.com/shantanubala/BetterSafariView", branch: "main"),
		
		/// Apple's
		.package(url: "https://github.com/apple/swift-collections", from: "1.3.0"),
		
		/// Macros
		.package(url: "https://github.com/qizh/QizhMacroKit", exact: "1.1.11"),
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
			exclude: [
				"Off/",
			],
			resources: [
				.process("Localizations"),
				.process("PrivacyInfo.xcprivacy"),
			],
			swiftSettings: [
				// .defaultIsolation(MainActor.self)
				// .enableExperimentalFeature("StrictConcurrency=complete", .when(configuration: .debug)),
				// .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"], .when(configuration: .debug)),
				// .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
			]
		),
		.testTarget(
			name: "QizhKitTests",
			dependencies: [
				"QizhKit",
			]
		)
    ],
	swiftLanguageModes: [
		// .v5,
		.v6,
	]
)

