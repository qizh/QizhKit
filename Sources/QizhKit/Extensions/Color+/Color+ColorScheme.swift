//
//  Color+ColorScheme.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.07.2025.
//  Copyright © 2025 Bespokely. All rights reserved.
//

public import SwiftUI

extension Color {
	/// Resolve this color for a specific scheme.
	public func resolved(for scheme: ColorScheme) -> Color {
		var env = EnvironmentValues()
		env.colorScheme = scheme
		return Color(resolve(in: env))
	}

	/// The “light-mode” variant, even if the system is in dark mode.
	@inlinable public var light: Color {
		resolved(for: .light)
	}

	/// The “dark-mode” variant, even if the system is in light mode.
	@inlinable public var dark: Color {
		resolved(for: .dark)
	}
}
