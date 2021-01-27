//
//  ColorScheme+is.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 30.01.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension ColorScheme: Identifiable, EasySelfComparable {
	@inlinable
	public var id: String {
		switch self {
		case .light: return "light"
		case .dark: return "dark"
		@unknown default: return "unknown"
		}
	}
	
	@inlinable
	public func `is`(_ other: Self) -> Bool {
		switch (self, other) {
		case (.light, .light): return true
		case (.dark, .dark): return true
		default: return false
		}
	}
}

public extension ColorScheme {
	@inlinable var isLight: Bool { self.is(.light) }
	@inlinable var isDark:  Bool { self.is(.dark) }
	
	@inlinable var opposite: ColorScheme {
		switch self {
		case .light: 		return .dark
		case .dark:  		return .light
		@unknown default: 	return .light
		}
	}
}

/*
extension ColorScheme: Identifiable {
	public var id: String { caseName }
}
*/

extension ColorScheme: WithDefault {
	public static var `default`: ColorScheme { .light }
}

public extension ColorScheme {
	@inlinable var name: String { caseName(of: self, .name).capitalized }
	@inlinable static func named(_ name: String) -> ColorScheme { .init(name: name) }
	
	init(name: String) {
		self = Self.allCases
			.first(
				where: \.name.localizedLowercase,
				equals: name.localizedLowercase
			)
			?? .default
	}
}
