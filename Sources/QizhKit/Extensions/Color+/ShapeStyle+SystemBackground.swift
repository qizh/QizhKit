//
//  ShapeStyle+SystemBackground.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 22.11.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public extension ShapeStyle {
	/// Platform-adaptive system background as a ShapeStyle.
	/// Use as: .background(.systemBackground, in: shape) or background(.systemBackground)
	static var systemBackground: Color {
		#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
		return Color(uiColor: .systemBackground)
		#elseif os(macOS)
		return Color(nsColor: .windowBackgroundColor)
		#else
		return Color(.white)
		#endif
	}
	
	// (Optional) add secondary/tertiary variants if you want parity with Color+values.swift:
	static var secondarySystemBackground: Color {
		#if canImport(UIKit)
		return Color(uiColor: .secondarySystemBackground)
		#elseif os(macOS)
		return Color(nsColor: .windowBackgroundColor) // or suitable macOS alternate
		#else
		return Color(.white)
		#endif
	}
}
