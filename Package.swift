// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
	.unsafeFlags(["-warn-deprecated-declarations"], .when(configuration: .debug))
]

let package = Package(
    name: "QizhKit",
	platforms: [
		.iOS(.v15),
		.visionOS(.v1),
	],
    products: [
        .library(
            name: "QizhKit",
            targets: ["QizhKit"]
		),
    ],
	dependencies: [
		.package(url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.12.0"),
		.package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.1"),
		.package(url: "https://github.com/devicekit/DeviceKit", from: "5.1.0"),
		.package(url: "https://github.com/stleamist/BetterSafariView", from: "2.4.2"),
	],
    targets: [
        .target(
            name: "QizhKit",
			dependencies: [
				.product(name: "Introspect", package: "SwiftUI-Introspect"),
				"Alamofire",
				"DeviceKit",
				"BetterSafariView",
			]
		),
    ]
)
