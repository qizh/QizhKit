// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation // ← for ProcessInfo

// MARK: Prepare

/// Base swift settings for the package.
var swiftSettings: [SwiftSetting] = []

/// Helper function to define `Trait`s in `SwiftSetting`s
@MainActor func addSwiftSetting(_ traits: Trait..., platforms: [Platform] = []) {
	for trait in traits {
		for traitName in trait.enabledTraits {
			swiftSettings.append(
				.define(traitName, .when(platforms: platforms, traits: [trait.name]))
			)
		}
	}
}

/// Helper function to define macros `Set<String>` (compiler conditions) in `SwiftSetting`s
@MainActor func addSwiftSetting(_ macros: Set<String>, condition: BuildSettingCondition? = nil) {
	for name in macros {
		swiftSettings.append(.define(name, condition))
	}
}

/// Helper function to define macros (compiler conditions) in `SwiftSetting`s
@MainActor func addSwiftSetting(_ macros: String..., condition: BuildSettingCondition? = nil) {
	addSwiftSetting(Set(macros), condition: condition)
}

// MARK: HDR

/// `Trait` checking for `QIZHKIT_ENABLE_HDR` and assigning `RESOLVED_HDR_AVAILABLE`.
public let resolvedHDRAvailable: Trait = .trait(
	name: "RESOLVED_HDR_AVAILABLE",
	description: "SwiftUI Color resolving HDR API is available"
)

/// `Trait` checking for `QIZHKIT_ENABLE_HDR` and assigning `RESOLVED_HDR_AVAILABLE`.
public let conditionalResolvedHDRAvailable: Trait = .trait(
	name: "QIZHKIT_ENABLE_HDR",
	description: """
		Enables resolving SwiftUI Colors in HDR by turning on the `\(resolvedHDRAvailable.name)` \ 
		(\(resolvedHDRAvailable.description ?? "no description provided")) trait
		""",
	enabledTraits: [resolvedHDRAvailable.name]
)

/// HDR is disabled by default
public let defaultTrait: Trait = .default(enabledTraits: [])

let traits: Set<Trait> = [
	resolvedHDRAvailable,
	conditionalResolvedHDRAvailable,
	defaultTrait,
]

addSwiftSetting(conditionalResolvedHDRAvailable)

/// Get `ProcessInfo` & `Context` `environment` value for traits
let envValues = [
	ProcessInfo.processInfo.environment[resolvedHDRAvailable.name],
	ProcessInfo.processInfo.environment[conditionalResolvedHDRAvailable.name],
	Context.environment[resolvedHDRAvailable.name],
	Context.environment[conditionalResolvedHDRAvailable.name],
]

/// Decide if HDR APIs should be enabled for `QizhKit`.
/// On your Mac, set `QIZHKIT_ENABLE_HDR=1` in the environment when building.
/// - Experiment:
///   ```zsh
///   launchctl setenv QIZHKIT_ENABLE_HDR 1
///   launchctl getenv QIZHKIT_ENABLE_HDR
///   # should output 1
///
///   env | grep -E "HDR|QIZH"
///   # Will output assigned environment values containing `HDR` or `QIZH`
///   ```
let isHDREnabled: Bool = envValues
	.compactMap(\.self)
	.contains { value in
		value == "1" || value.lowercased() == "true"
	}


/// Add the define only when HDR is explicitly enabled.
if isHDREnabled {
	addSwiftSetting(resolvedHDRAvailable.name)
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
	traits: traits,
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
		.package(url: "https://github.com/qizh/QizhMacroKit", from: "1.1.18"),
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
				// .product(name: "QizhMacroKitClient", package: "QizhMacroKit"),
			],
			exclude: [
				"Off/",
			],
			resources: [
				.process("Localizations"),
				.process("PrivacyInfo.xcprivacy"),
			],
			swiftSettings: swiftSettings
		),
		.testTarget(
			name: "QizhKitTests",
			dependencies: [
				"QizhKit",
			],
			swiftSettings: swiftSettings
		)
	],
	swiftLanguageModes: [
		.v6,
	]
)
