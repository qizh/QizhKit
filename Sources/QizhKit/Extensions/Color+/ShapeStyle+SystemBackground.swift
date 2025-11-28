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

extension ShapeStyle where Self == Color {
	/// A platform-adaptive system background shape style.
	///
	/// Use this property to apply the system’s default background color in a way that
	/// respects the current platform and appearance (`light`/`dark` mode).
	///
	/// - Behavior:
	///   - `iOS`, `iPadOS`, `tvOS`, `watchOS`, and `macCatalyst`:
	///     maps to `UIColor.systemBackground`
	///   - `macOS`: maps to `NSColor.windowBackgroundColor`
	///   - Other platforms: falls back to `.white`
	///
	/// - Typical usage:
	///   - As a background fill for shapes:
	///     ```swift
	///     .background(.systemBackground, in: RoundedRectangle(cornerRadius: 12))
	///     ```
	///   - As a view background:
	///     ```swift
	///     .background(.systemBackground)
	///     ```
	///
	/// - Note:
	///   - Automatically adapts to `light`/`dark` mode on supported platforms.
	///   - On `macOS`, aligns with window background conventions to blend with system UI.
	///
	/// - Returns a `Color` but is exposed via `ShapeStyle`
	///   for ergonomic use in SwiftUI modifiers.
	public static var systemBackground: Color {
		#if canImport(UIKit)
		Color(uiColor: .systemBackground)
		#elseif canImport(AppKit)
		Color(nsColor: .windowBackgroundColor) /// Alternative: `.controlBackgroundColor`
		#else
		Color.fromHexColors(light: .white, dark: .black)
		#endif
	}
	
	/// A platform-adaptive secondary system background shape style.
	///
	/// Use this property to apply the system’s secondary background color in a way that
	/// respects the current platform and appearance (`light`/`dark` mode).
	/// This is typically subtler than the primary system background and is useful for
	/// grouping content or layering surfaces.
	///
	/// - Behavior:
	///   - `iOS`, `iPadOS`, `tvOS`, `watchOS`, and `macCatalyst`:
	///     maps to `UIColor.secondarySystemBackground`.
	///   - `macOS`: maps to `NSColor.controlBackgroundColor`
	///     (a reasonable secondary/background equivalent).
	///   - Other platforms: falls back to white.
	///
	/// - Typical usage:
	///   - As a background fill for shapes:
	///     ```swift
	///     .background(.secondarySystemBackground, in: RoundedRectangle(cornerRadius: 12))
	///     ```
	///   - As a view background:
	///     ```swift
	///     .background(.secondarySystemBackground)
	///     ```
	///
	/// - Note:
	///   - Automatically adapts to `light`/`dark` mode on supported platforms.
	///   - On `macOS`, uses a control background to provide a layered, subtle surface that
	///     complements the primary window background.
	///
	/// - Returns: A `Color` exposed via `ShapeStyle`
	///   for ergonomic use in `SwiftUI` modifiers.
	public static var secondarySystemBackground: Color {
		#if canImport(UIKit)
		Color(uiColor: .secondarySystemBackground)
		#elseif canImport(AppKit)
		Color(nsColor: .controlBackgroundColor) /// Alternative: `.underPageBackgroundColor`
		#else
		Color.fromHexColors(light: 0xF2F2F7, dark: 0x1C1C1E)
		#endif
	}
	
	/// A platform-adaptive tertiary system background shape style.
	///
	/// Use this property to apply the system’s tertiary background color in a way that
	/// respects the current platform and appearance (`light`/`dark` mode).
	/// This is typically the most subtle of the layered background colors and is useful for
	/// grouping content on top of secondary backgrounds or for deeper visual hierarchies.
	///
	/// - Behavior:
	///   - `iOS`, `iPadOS`, `tvOS`, `watchOS`, and `macCatalyst`:
	///     maps to `UIColor.tertiarySystemBackground`.
	///   - `macOS`: there is no direct `NSColor` equivalent; uses calibrated colors that
	///     approximate the iOS palette for light and dark appearances.
	///   - Other platforms: falls back to calibrated `light`/`dark` hex colors.
	///
	/// - Typical usage:
	///   - As a background fill for shapes:
	///     ```swift
	///     .background(.tertiarySystemBackground, in: RoundedRectangle(cornerRadius: 12))
	///     ```
	///   - As a view background:
	///     ```swift
	///     .background(.tertiarySystemBackground)
	///     ```
	///   - For layered surfaces, such as cards within grouped or inset lists.
	///
	/// - Note:
	///   - Automatically adapts to `light`/`dark` mode on supported platforms.
	///   - Intended for surfaces layered above secondary backgrounds to provide subtle depth.
	///
	/// - Returns: A `Color` exposed via `ShapeStyle`
	///   for ergonomic use in `SwiftUI` modifiers.
	///
	/// - See also: ``systemBackground``, ``secondarySystemBackground``.
	public static var tertiarySystemBackground: Color {
		#if canImport(UIKit)
		Color(uiColor: .secondarySystemBackground)
		#elseif canImport(AppKit)
		Color.fromHexColors(light: 0xFFFFFF, dark: 0x2C2C2E) /// No macOS alternative
		#else
		Color.fromHexColors(light: 0xFFFFFF, dark: 0x2C2C2E)
		#endif
	}
}
