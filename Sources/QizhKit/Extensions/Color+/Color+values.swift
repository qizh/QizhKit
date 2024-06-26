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
	static let almostClear = Color(uiColor: .systemBackground).opacity(0.001)
}

public extension UIColor {
	static let almostClear = UIColor.systemBackground.withAlphaComponent(0.001)
}

// MARK: From UIColor

public extension Color {
	static let systemBackground          = Color(uiColor: .systemBackground)
	static let secondarySystemBackground = Color(uiColor: .secondarySystemBackground)
	static let tertiarySystemBackground  = Color(uiColor: .tertiarySystemBackground)
	
	static let systemGroupedBackground  		= Color(uiColor: .systemGroupedBackground)
	static let secondarySystemGroupedBackground = Color(uiColor: .secondarySystemGroupedBackground)
	static let tertiarySystemGroupedBackground 	= Color(uiColor: .tertiarySystemGroupedBackground)
	
	static let label                     = Color(uiColor: .label)
	static let secondaryLabel            = Color(uiColor: .secondaryLabel)
	static let tertiaryLabel             = Color(uiColor: .tertiaryLabel)
	static let quaternaryLabel           = Color(uiColor: .quaternaryLabel)
	
	static let systemFill                = Color(uiColor: .systemFill)
	static let secondarySystemFill       = Color(uiColor: .secondarySystemFill)
	static let tertiarySystemFill        = Color(uiColor: .tertiarySystemFill)
	static let quaternarySystemFill      = Color(uiColor: .quaternarySystemFill)
	
	static let link 			= Color(uiColor: .link)
	static let placeholderText 	= Color(uiColor: .placeholderText)
	static let separator 		= Color(uiColor: .separator)
	static let opaqueSeparator 	= Color(uiColor: .opaqueSeparator)
	static let lightText 		= Color(uiColor: .lightText)
	static let darkText 		= Color(uiColor: .darkText)
	
	// MARK: System
	
	@inlinable static func systemBackground(_ opacity: Double) -> Color {
		Color(uiColor: .systemBackground).opacity(opacity)
	}
	@inlinable static func secondarySystemBackground(_ opacity: Double) -> Color {
		Color(uiColor: .secondarySystemBackground).opacity(opacity)
	}
	@inlinable static func label(_ opacity: Double) -> Color {
		Color(uiColor: .label).opacity(opacity)
	}
	@inlinable static func secondaryLabel(_ opacity: Double) -> Color {
		Color(uiColor: .secondaryLabel).opacity(opacity)
	}
	@inlinable static func systemFill(_ opacity: Double) -> Color {
		Color(uiColor: .systemFill).opacity(opacity)
	}
	@inlinable static func secondarySystemFill(_ opacity: Double) -> Color {
		Color(uiColor: .secondarySystemFill).opacity(opacity)
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
	
	static let systemGray = Color(uiColor: .systemGray)
	static let systemGray2 = Color(uiColor: .systemGray2)
	static let systemGray3 = Color(uiColor: .systemGray3)
	static let systemGray4 = Color(uiColor: .systemGray4)
	static let systemGray5 = Color(uiColor: .systemGray5)
	static let systemGray6 = Color(uiColor: .systemGray6)
}

// MARK: White

public extension Color {
	@inlinable static func white(_ value: Double, _ opacity: Double = 1) -> Color { .init(white: value, opacity: opacity) }
}

// MARK: Shape Style

public extension ShapeStyle where Self == Color {
	// MARK: System
	
	@inlinable static var systemBackground: Color 			{ Color(uiColor: .systemBackground) }
	@inlinable static var secondarySystemBackground: Color 	{ Color(uiColor: .secondarySystemBackground) }
	@inlinable static var tertiarySystemBackground: Color 	{ Color(uiColor: .tertiarySystemBackground) }
	
	@inlinable static var systemGroupedBackground: Color 			{ Color(uiColor: .systemGroupedBackground) }
	@inlinable static var secondarySystemGroupedBackground: Color 	{ Color(uiColor: .secondarySystemGroupedBackground) }
	@inlinable static var tertiarySystemGroupedBackground: Color 	{ Color(uiColor: .tertiarySystemGroupedBackground) }
	
	@inlinable static var label: Color 					{ Color(uiColor: .label) }
	@inlinable static var secondaryLabel: Color 		{ Color(uiColor: .secondaryLabel) }
	@inlinable static var tertiaryLabel: Color 			{ Color(uiColor: .tertiaryLabel) }
	@inlinable static var quaternaryLabel: Color 		{ Color(uiColor: .quaternaryLabel) }

	@inlinable static var systemFill: Color 			{ Color(uiColor: .systemFill) }
	@inlinable static var secondarySystemFill: Color 	{ Color(uiColor: .secondarySystemFill) }
	@inlinable static var tertiarySystemFill: Color 	{ Color(uiColor: .tertiarySystemFill) }
	@inlinable static var quaternarySystemFill: Color 	{ Color(uiColor: .quaternarySystemFill) }
	
	@inlinable static var link: Color 					{ Color(uiColor: .link) }
	@inlinable static var placeholderText: Color 		{ Color(uiColor: .placeholderText) }
	
	@available(iOS, obsoleted: 17, message: "Implemented as a SeparatorShapeStyle in SwiftUICore")
	@inlinable static var separator: Color 				{ Color(uiColor: .separator) }
	@inlinable static var opaqueSeparator: Color 		{ Color(uiColor: .opaqueSeparator) }
	@inlinable static var lightText: Color 				{ Color(uiColor: .lightText) }
	@inlinable static var darkText: Color 				{ Color(uiColor: .darkText) }
	
	@inlinable static func label(_ opacity: Double) -> Color {
		Color(uiColor: .label).opacity(opacity)
	}
	@inlinable static func systemBackground(_ opacity: Double) -> Color {
		Color(uiColor: .systemBackground).opacity(opacity)
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
	
	@inlinable static var systemGray: Color { Color(uiColor: .systemGray) }
	@inlinable static var systemGray2: Color { Color(uiColor: .systemGray2) }
	@inlinable static var systemGray3: Color { Color(uiColor: .systemGray3) }
	@inlinable static var systemGray4: Color { Color(uiColor: .systemGray4) }
	@inlinable static var systemGray5: Color { Color(uiColor: .systemGray5) }
	@inlinable static var systemGray6: Color { Color(uiColor: .systemGray6) }
}
