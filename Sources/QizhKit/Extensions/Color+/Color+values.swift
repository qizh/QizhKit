//
//  Color+values.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 07.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Almost Clear

public extension Color {
	static let almostClear = Color(.systemBackground).opacity(0.001)
}

// MARK: From UIColor

public extension Color {
	static let systemBackground          = Color(.systemBackground)
	static let secondarySystemBackground = Color(.secondarySystemBackground)
	static let tertiarySystemBackground  = Color(.tertiarySystemBackground)
	
	static let label                     = Color(.label)
	static let secondaryLabel            = Color(.secondaryLabel)
	static let tertiaryLabel             = Color(.tertiaryLabel)
	static let quaternaryLabel           = Color(.quaternaryLabel)
	
	static let systemFill                = Color(.systemFill)
	static let secondarySystemFill       = Color(.secondarySystemFill)
	static let tertiarySystemFill        = Color(.tertiarySystemFill)
	static let quaternarySystemFill      = Color(.quaternarySystemFill)
	
	// MARK: System
	
	@inlinable static func systemBackground(_ opacity: Double) -> Color {
		Color(.systemBackground).opacity(opacity)
	}
	@inlinable static func secondarySystemBackground(_ opacity: Double) -> Color {
		Color(.secondarySystemBackground).opacity(opacity)
	}
	@inlinable static func label(_ opacity: Double) -> Color {
		Color(.label).opacity(opacity)
	}
	@inlinable static func secondaryLabel(_ opacity: Double) -> Color {
		Color(.secondaryLabel).opacity(opacity)
	}
	@inlinable static func systemFill(_ opacity: Double) -> Color {
		Color(.systemFill).opacity(opacity)
	}
	@inlinable static func secondarySystemFill(_ opacity: Double) -> Color {
		Color(.secondarySystemFill).opacity(opacity)
	}
	@inlinable static func accentColor(_ opacity: Double) -> Color {
		Color.accentColor.opacity(opacity)
	}
	
	// MARK: B&W
	
	@inlinable static func white(_ opacity: Double) -> Color {
		Color.white.opacity(opacity)
	}
	@inlinable static func black(_ opacity: Double) -> Color {
		Color.black.opacity(opacity)
	}
	
	// MARK: Rainbow
	
	@inlinable static func red(_ opacity: Double) -> Color {
		Color.red.opacity(opacity)
	}
	@inlinable static func green(_ opacity: Double) -> Color {
		Color.green.opacity(opacity)
	}
	@inlinable static func blue(_ opacity: Double) -> Color {
		Color.blue.opacity(opacity)
	}
	@inlinable static func orange(_ opacity: Double) -> Color {
		Color.orange.opacity(opacity)
	}
	@inlinable static func yellow(_ opacity: Double) -> Color {
		Color.yellow.opacity(opacity)
	}
	@inlinable static func pink(_ opacity: Double) -> Color {
		Color.pink.opacity(opacity)
	}
	@inlinable static func purple(_ opacity: Double) -> Color {
		Color.purple.opacity(opacity)
	}
}

// MARK: White

public extension Color {
	@inlinable static func white(_ value: Double, _ opacity: Double = 1) -> Color { .init(white: value, opacity: opacity) }
}
