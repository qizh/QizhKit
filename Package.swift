// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QizhKit",
	platforms: [
		.iOS(.v13),
	],
    products: [
        .library(
            name: "QizhKit",
//			type: .dynamic,
            targets: [
				"QizhKit"
			]
		),
    ],
    dependencies: [
		/*
		.package(
			name: "PhoneNumberKit",
			url: "https://github.com/marmelroy/PhoneNumberKit",
			from: "3.3.0"
		),
		*/
		.package(
			name: "Introspect",
			url: "https://github.com/siteline/SwiftUI-Introspect",
			from: "0.1.0"
		),
		.package(
			name: "Alamofire",
			url: "https://github.com/Alamofire/Alamofire",
			from: "5.0.0"
		),
		/*
		.package(
			name: "SwiftDate",
			url: "https://github.com/malcommac/SwiftDate",
			from: "6.2.0"
		),
		*/
		/*
		.package(
			name: "swift-nonempty",
			url: "https://github.com/pointfreeco/swift-nonempty",
			from: "0.3.1"
		),
		*/
		.package(
			name: "DeviceKit",
			url: "https://github.com/devicekit/DeviceKit",
			from: "4.2.1"
		),
		.package(
			name: "BetterSafariView",
			url: "https://github.com/stleamist/BetterSafariView.git",
			from: "2.3.1"
		),
    ],
    targets: [
        .target(
            name: "QizhKit",
            dependencies: [
				/*
				"PhoneNumberKit",
				*/
				"Introspect",
				"Alamofire",
				/*
				"SwiftDate",
				*/
				/*
				.product(
					name: "NonEmpty",
					package: "swift-nonempty"
				),
				*/
				"DeviceKit",
				"BetterSafariView",
			]
		),
		/*
        .testTarget(
            name: "QizhKitTests",
            dependencies: ["QizhKit"]
		),
		*/
    ]
)
