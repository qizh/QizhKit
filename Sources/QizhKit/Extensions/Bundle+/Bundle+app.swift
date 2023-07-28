//
//  Bundle+app.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.08.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

fileprivate var cachedAppBundle: Bundle?

extension Bundle {
	/// Return the main bundle when in the app or an app extension.
	public static var app: Bundle {
		cachedAppBundle ?? findAppBundle() ?? .main
	}
	
	private static func findAppBundle() -> Bundle? {
		var components = main.bundleURL.path.split(separator: .slashChar)
		
		if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
			components.removeLast((components.count - 1) - index)
			cachedAppBundle = Bundle(path: components.joined(separator: .slash))
		}
		
		return cachedAppBundle
	}
	
	/// Finds the main app's bundle and returns its bundle identifier.
	/// - Warning: Unwrapping an optional identifier since the app should always have an identifier.
	public static var appIdentifier: String {
		app.bundleIdentifier
			.forceUnwrap(because: "App will always have an identifier")
	}
	
	public static var mainIdentifier: String {
		main.bundleIdentifier
			.forceUnwrap(because: "Bundle always have an identifier")
	}
}
