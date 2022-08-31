//
//  Bundle+app.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.08.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Bundle {
	/// Return the main bundle when in the app or an app extension.
	public static var app: Bundle {
		var components = main.bundleURL.path.split(separator: "/")
		var bundle: Bundle?

		if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
			components.removeLast((components.count - 1) - index)
			bundle = Bundle(path: components.joined(separator: "/"))
		}

		return bundle ?? main
	}
	
	/// Finds the main app's bundle and returns its bundle identifier.
	/// - Warning: Unwrapping an optional identifier since the app should always have an identifier.
	public static var appIdentifier: String {
		Bundle.app.bundleIdentifier.forceUnwrap(because: "App will always have an identifier")
	}
}
