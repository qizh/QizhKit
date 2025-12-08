// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation // ← for ProcessInfo

/// Decide if HDR APIs should be enabled for QizhKit.
/// On your Mac, set `QIZHKIT_ENABLE_HDR=1` in the environment when building.
/// - Experiment:
/// ```zsh
/// launchctl setenv QIZHKIT_ENABLE_HDR 1
/// launchctl getenv QIZHKIT_ENABLE_HDR # should output 1
/// ```
let isHDREnabled: Bool =
	if let value = ProcessInfo.processInfo.environment["QIZHKIT_ENABLE_HDR"] {
		value == "1" || value.lowercased() == "true"
	} else {
		false
	}

/*
print("QIZHKIT_ENABLE_HDR in Package.swift:",
	  ProcessInfo.processInfo.environment["QIZHKIT_ENABLE_HDR"] ?? "nil")
print("HDR enabled:", isHDREnabled)
*/

/// Base swift settings for QizhKit.
var qizhKitSwiftSettings: [SwiftSetting] = [
	// .defaultIsolation(MainActor.self)
	// .enableExperimentalFeature("StrictConcurrency=complete", .when(configuration: .debug)),
	// .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"], .when(configuration: .debug)),
	// .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
]

/// Add the define only when HDR is explicitly enabled.
if isHDREnabled {
	qizhKitSwiftSettings.append(.define("RESOLVED_HDR_AVAILABLE"))
}

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
		
		/// In-app Safari
		.package(url: "https://github.com/qizh/BetterSafariView", from: "2.4.4"),
		// .package(url: "https://github.com/stleamist/BetterSafariView", from: "2.4.2"),
		// .package(url: "https://github.com/shantanubala/BetterSafariView", branch: "main"),
		
		/// Apple's
		.package(url: "https://github.com/apple/swift-collections", from: "1.3.0"),
		
		/// Macros
		.package(url: "https://github.com/qizh/QizhMacroKit", from: "1.1.15"),
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
			swiftSettings: qizhKitSwiftSettings
		),
		.testTarget(
			name: "QizhKitTests",
			dependencies: [
				"QizhKit",
			],
			swiftSettings: qizhKitSwiftSettings
		)
	],
	swiftLanguageModes: [
		.v6,
	]
)
