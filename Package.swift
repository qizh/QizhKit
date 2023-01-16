// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
	.unsafeFlags(["-warn-deprecated-declarations"], .when(configuration: .debug))
]

let package = Package(
    name: "QizhKit",
	platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "QizhKit",
            targets: ["QizhKit"]
		),
    ],
	dependencies: [
		.package(url: "https://github.com/qizh/SwiftUI-Introspect", from: "0.1.6"),
		.package(url: "https://github.com/Alamofire/Alamofire", from: "5.6.4"),
		.package(url: "https://github.com/devicekit/DeviceKit", from: "4.9.0"),
		.package(url: "https://github.com/stleamist/BetterSafariView", from: "2.4.1"),
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
