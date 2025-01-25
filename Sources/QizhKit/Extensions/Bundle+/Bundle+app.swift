//
//  Bundle+app.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.08.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

fileprivate final class BundleKeeper {
	fileprivate static let cachedAppBundle: Bundle? = {
		var result: Bundle? = .none
		var components = Bundle.main.bundleURL.path.split(separator: .slashChar)
		
		if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
			components.removeLast((components.count - 1) - index)
			result = Bundle(path: components.joined(separator: .slash))
		}
		
		return result
	}()
}

extension Bundle {
	/// Return the main bundle when in the app or an app extension.
	public static var app: Bundle {
		BundleKeeper.cachedAppBundle ?? .main
	}
	
	/*
	@MainActor private static func findAppBundle() -> Bundle? {
		var components = main.bundleURL.path.split(separator: .slashChar)
		
		if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
			components.removeLast((components.count - 1) - index)
			cachedAppBundle = Bundle(path: components.joined(separator: .slash))
		}
		
		return cachedAppBundle
	}
	*/
	
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
