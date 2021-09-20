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

public extension UIColor {
	static let almostClear = UIColor.systemBackground.withAlphaComponent(0.001)
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
	
	static let link 			= Color(.link)
	static let placeholderText 	= Color(.placeholderText)
	static let separator 		= Color(.separator)
	static let opaqueSeparator 	= Color(.opaqueSeparator)
	static let lightText 		= Color(.lightText)
	static let darkText 		= Color(.darkText)
	
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
	
	@inlinable static func white(_ opacity: Double) -> Color { Color.white.opacity(opacity) }
	@inlinable static func black(_ opacity: Double) -> Color { Color.black.opacity(opacity) }
	@inlinable static func gray(_ opacity: Double) -> Color { Color.gray.opacity(opacity) }
	
	// MARK: Rainbow
	
	@inlinable static func red(_ opacity: Double) -> Color { Color.red.opacity(opacity) }
	@inlinable static func orange(_ opacity: Double) -> Color { Color.orange.opacity(opacity) }
	@inlinable static func yellow(_ opacity: Double) -> Color { Color.yellow.opacity(opacity) }
	@inlinable static func green(_ opacity: Double) -> Color { Color.green.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func mint(_ opacity: Double) -> Color { Color.mint.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func teal(_ opacity: Double) -> Color { Color.teal.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func cyan(_ opacity: Double) -> Color { Color.cyan.opacity(opacity) }
	@inlinable static func blue(_ opacity: Double) -> Color { Color.blue.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func indigo(_ opacity: Double) -> Color { Color.indigo.opacity(opacity) }
	@inlinable static func purple(_ opacity: Double) -> Color { Color.purple.opacity(opacity) }
	@inlinable static func pink(_ opacity: Double) -> Color { Color.pink.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func brown(_ opacity: Double) -> Color { Color.brown.opacity(opacity) }
	
	// MARK: System Grayscale
	
	static let systemGray = Color(.systemGray)
	static let systemGray2 = Color(.systemGray2)
	static let systemGray3 = Color(.systemGray3)
	static let systemGray4 = Color(.systemGray4)
	static let systemGray5 = Color(.systemGray5)
	static let systemGray6 = Color(.systemGray6)
}

// MARK: White

public extension Color {
	@inlinable static func white(_ value: Double, _ opacity: Double = 1) -> Color { .init(white: value, opacity: opacity) }
}

// MARK: Shape Style

public extension ShapeStyle where Self == Color {
	// MARK: System
	
	@inlinable static var label: Color { Color(.label) }
	@inlinable static var systemBackground: Color { Color(.systemBackground) }
	
	@inlinable static func label(_ opacity: Double) -> Color {
		Color(.label).opacity(opacity)
	}
	@inlinable static func systemBackground(_ opacity: Double) -> Color {
		Color(.systemBackground).opacity(opacity)
	}
	
	// MARK: B&W
	
	@inlinable static func white(_ opacity: Double) -> Color { Color.white.opacity(opacity) }
	@inlinable static func black(_ opacity: Double) -> Color { Color.black.opacity(opacity) }
	@inlinable static func gray(_ opacity: Double) -> Color { Color.gray.opacity(opacity) }
	
	// MARK: Rainbow
	
	@inlinable static func red(_ opacity: Double) -> Color { Color.red.opacity(opacity) }
	@inlinable static func orange(_ opacity: Double) -> Color { Color.orange.opacity(opacity) }
	@inlinable static func yellow(_ opacity: Double) -> Color { Color.yellow.opacity(opacity) }
	@inlinable static func green(_ opacity: Double) -> Color { Color.green.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func mint(_ opacity: Double) -> Color { Color.mint.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func teal(_ opacity: Double) -> Color { Color.teal.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func cyan(_ opacity: Double) -> Color { Color.cyan.opacity(opacity) }
	@inlinable static func blue(_ opacity: Double) -> Color { Color.blue.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func indigo(_ opacity: Double) -> Color { Color.indigo.opacity(opacity) }
	@inlinable static func purple(_ opacity: Double) -> Color { Color.purple.opacity(opacity) }
	@inlinable static func pink(_ opacity: Double) -> Color { Color.pink.opacity(opacity) }
	@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
	@inlinable static func brown(_ opacity: Double) -> Color { Color.brown.opacity(opacity) }
	
	// MARK: System Grayscale
	
	@inlinable static var systemGray: Color { Color(.systemGray) }
	@inlinable static var systemGray2: Color { Color(.systemGray2) }
	@inlinable static var systemGray3: Color { Color(.systemGray3) }
	@inlinable static var systemGray4: Color { Color(.systemGray4) }
	@inlinable static var systemGray5: Color { Color(.systemGray5) }
	@inlinable static var systemGray6: Color { Color(.systemGray6) }
}
