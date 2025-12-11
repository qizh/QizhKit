//
//  HexStringColor.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Pair of Hex Colors

public struct HexStringColorsPair: Codable,
								   Hashable,
								   Sendable,
								   WithDefault,
								   CustomStringConvertible,
								   ExpressibleByStringLiteral,
								   ExpressibleByArrayLiteral {
	
	public let light: HexStringColor
	public let dark: HexStringColor
	
	public init(light: HexStringColor, dark: HexStringColor) {
		self.light = light
		self.dark = dark
	}
	
	@_disfavoredOverload
	public init(light: HexStringColor?, dark: HexStringColor?) {
		self.init(light: light ?? Self.default.light, dark: dark ?? Self.default.dark)
	}
	
	@inlinable public init(_ light: HexStringColor, _ dark: HexStringColor) {
		self.init(light: light, dark: dark)
	}
	
	@inlinable public init(same hexColor: HexStringColor) {
		self.init(light: hexColor, dark: hexColor)
	}
	
	@inlinable public init(_ colors: HexStringColor...) { self.init(colors) }
	public init(_ colors: [HexStringColor]) {
		switch colors.count {
		case 0: self = .default
		case 1: self.init(same: colors[0])
		default: self.init(light: colors[0], dark: colors[1])
		}
	}
	
	public init(stringLiteral value: String) {
		let invertedHexColorSet = HexStringColor.characterSet.inverted
		
		let hexColors = value
			.components(separatedBy: invertedHexColorSet)
			.compactMap { s in
				s.replacing(invertedHexColorSet, with: .empty).nonEmpty
			}
			.map { s in
				HexStringColor(stringLiteral: s)
			}
		
		self.init(hexColors)
	}
	
	public init(arrayLiteral elements: UInt64...) {
		self.init(elements.map(HexStringColor.init(integerLiteral:)))
	}
	
	public static let `default`: HexStringColorsPair = .init(
		light: .violentVioletLight,
		dark: .violentVioletDark
	)
	
	public var description: String {
		if isDefault {
			"default"
		} else if light == dark {
			light.description
		} else {
			"[\(light == Self.default.light ? "null" : light.description.inQuotes), \(dark == Self.default.dark ? "null" : dark.description.inQuotes)]"
		}
	}
	
	public var color: Color {
		if light == dark {
			light.color
		} else {
			.fromHexColors(light: light, dark: dark)
		}
	}
}

// MARK: - Hex Color

public struct HexStringColor: Codable,
							  Hashable,
							  Sendable,
							  WithDefault,
							  CustomStringConvertible,
							  ExpressibleByStringLiteral,
							  ExpressibleByIntegerLiteral {
	public let value: UInt64
	public let hasAlphaChannel: Bool
	
	public static let characterSet = CharacterSet(charactersIn: "#0123456789abcdefABCDEF")
	
	public static let `default`: HexStringColor = .init(0x000000)
	public static let black: HexStringColor = 0x000000
	public static let white: HexStringColor = 0xffffff
	public static let violentVioletLight: HexStringColor = 0x1D0E64
	public static let violentVioletDark: HexStringColor = 0xA7B9E3
	
	/// Creates a hexadecimal color from a numeric value.
	///
	/// - Parameters:
	///   - value: The hexadecimal color value. When `isWithAlpha` is `false`,
	///     interpret this as `0xRRGGBB`. When `isWithAlpha` is `true`,
	///     interpret it as `0xRRGGBBAA`, where the least significant byte
	///     is the alpha channel.
	///   - isWithAlpha: A Boolean value indicating whether the provided `value`
	///     contains an alpha channel (8 hex digits). Pass `true` for `RRGGBBAA`,
	///     or `false` for `RRGGBB`.
	/// - Note:
	///   ### Behavior:
	///   - If `isWithAlpha` is `false` and `value` exceeds `0xFFFFFF`,
	///     the color representation will be capped to `0xFFFFFF` when converted to
	///     platform colors to avoid overflow.
	///   - Component order is assumed to be `red`, `green`, `blue`, then `alpha`
	///     (when present).
	///   - This initializer does not validate color gamut; it simply stores the raw value
	///     and flag for later interpretation by `color` (`SwiftUI`) or `uiColor` (`UIKit`).
	/// - SeeAlso:
	///   - ``init(_:)`` for initializing from a hex string
	///     (e.g., `"#RRGGBB"` or `"#RRGGBBAA"`).
	///   - ``color`` for a `SwiftUI` `Color` representation.
	///   - ``uiColor`` for a `UIKit` `UIColor` representation (when available).
	public init(_ value: UInt64, isWithAlpha: Bool = false) {
		self.value = value
		self.hasAlphaChannel = isWithAlpha
	}
	
	/// Creates a hexadecimal color from a numeric value.
	///
	/// - Parameters:
	///   - value: The hexadecimal color value. When `isWithAlpha` is `false`,
	///     interpret this as `0xRRGGBB`. When `isWithAlpha` is `true`,
	///     interpret it as `0xRRGGBBAA`, where the least significant byte
	///     is the alpha channel.
	///   - isWithAlpha: A Boolean value indicating whether the provided `value`
	///     contains an alpha channel (`8` hex digits). Pass `true` for `RRGGBBAA`,
	///     or `false` for `RRGGBB`.
	/// - Note:
	///   - If `isWithAlpha` is `false` and `value` exceeds `0xFFFFFF`,
	///     the color representation will be capped to `0xFFFFFF` when converted to
	///     platform colors to avoid overflow.
	///   - Component order is assumed to be `red`, `green`, `blue`, then `alpha`
	///     (when present).
	///   - This initializer does not validate color gamut; it simply stores the raw value
	///     and flag for later interpretation by `color` (`SwiftUI`) or `uiColor` (`UIKit`).
	/// - SeeAlso:
	///   - ``init(_:)`` for initializing from a hex string
	///     (e.g., `"#RRGGBB"` or `"#RRGGBBAA"`).
	///   - ``color`` for a `SwiftUI` `Color` representation.
	///   - ``uiColor`` for a `UIKit` `UIColor` representation (when available).
	public init(_ hexString: String) {
		let hexString = hexString
			.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: .hash)))
		let scanner = Scanner(string: hexString)
		// scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		
		var color: UInt64 = 0
		if scanner.scanHexInt64(&color) {
			self.init(color, isWithAlpha: hexString.count >= 8)
		} else {
			self = .default
		}
	}
	
	/// Creates a hex color from a string literal.
	///
	/// Use this initializer to construct a `HexStringColor` directly from a
	/// string literal in source code. The string may optionally begin with a
	/// leading `#` and may contain either:
	/// - `6` hexadecimal digits for an `RGB` color (`#RRGGBB`)
	/// - `8` hexadecimal digits for an `RGBA` color (`#RRGGBBAA`)
	///
	/// If the string cannot be parsed as a valid hexadecimal value,
	/// the instance falls back to ``HexStringColor/default`` (`#000000`).
	/// - Example:
	///   ```swift
	///   let color: HexStringColor = "#ff9900"
	///   let colorWithAlpha: HexStringColor = "#ff9900cc"
	///   let noHash: HexStringColor = "336699"
	///   ```
	/// - Parameter value: A string literal containing a hex color, with or without
	///   a leading `#`. Six digits imply full opacity; eight digits include an
	///   explicit alpha channel.
	@inlinable public init(stringLiteral value: String) {
		self.init(value)
	}
	
	/// Creates a hexadecimal color from an integer literal.
	///
	/// Use this initializer to construct a `HexStringColor` directly from a numeric
	/// literal in source code. The literal is interpreted as a hexadecimal color value:
	/// - `0xRRGGBB` (`6` hex digits) for an opaque `RGB` color
	/// - `0xRRGGBBAA` (`8` hex digits) for an `RGBA` color,
	///   where the least significant byte (`AA`) is the alpha channel
	///
	/// If the literal exceeds `0xFFFFFF`, it is treated as including an alpha channel.
	///
	/// - Example:
	///   ```swift
	///   let rgb: HexStringColor = 0xFF9900      /// Opaque orange
	///   let rgba: HexStringColor = 0xFF9900CC   /// Orange with ~80% opacity
	///   ```
	///
	/// - Parameter value: A hexadecimal integer literal representing the color.
	///   Six digits imply full opacity; eight digits include an explicit alpha channel.
	public init(integerLiteral value: UInt64) {
		self.init(value, isWithAlpha: value > 0xFFFFFF)
	}
	
	/// A `SwiftUI` `Color` representation of the hexadecimal color value.
	///
	/// - Returns: A `Color` created from the receiver’s hexadecimal value.
	///   If the hex string contains an alpha channel (`8` hex digits),
	///   the resulting color uses that `alpha`; otherwise, full opacity
	///   (`alpha = 1.0`) is applied.
	/// - Note:
	///   ### Behavior:
	///   - Interprets the stored `value` as `RRGGBB` or `RRGGBBAA` depending on
	///     `hasAlphaChannel`.
	///   - When `hasAlphaChannel` is `false` and `value` exceeds `0xFFFFFF`,
	///     the value is capped to `0xFFFFFF` to avoid overflow.
	///   - The color components are normalized to the `0.0`–`1.0` range and mapped
	///     to the `sRGB` color space.
	/// - SeeAlso:
	///   - `uiColor` for a `UIKit` counterpart
	///   - `combinedColor(dark:)` for generating dynamic colors
	///     that adapt to `light`/`dark` appearance.
	public var color: Color {
		let mask      = UInt64(0xFF)
		let cappedHex = !hasAlphaChannel && value > 0xffffff ? 0xffffff : value
		
		let r = cappedHex >> (hasAlphaChannel ? 24 : 16) & mask
		let g = cappedHex >> (hasAlphaChannel ? 16 : 8) & mask
		let b = cappedHex >> (hasAlphaChannel ? 8 : 0) & mask
		let a = hasAlphaChannel ? cappedHex & mask : 255
		
		let red   = Double(r) / 255.0
		let green = Double(g) / 255.0
		let blue  = Double(b) / 255.0
		let alpha = Double(a) / 255.0
		
		return Color(
			Color.RGBColorSpace.sRGB,
			red: red,
			green: green,
			blue: blue,
			opacity: alpha
		)
	}
	
	#if canImport(UIKit)
	/// Returns a dynamic color that adapts to the current interface style
	/// (`light` or `dark`).
	///
	/// - Parameter dark: The color to use when the system is in Dark Mode.
	/// - Returns: A dynamic `Color` that resolves to:
	///   - The receiver (`light`) when the user interface style is `light`.
	///   - The provided `dark` color when the user interface style is `dark`.
	/// - Note:
	///   ### Behavior:
	///   - If both the `light` (receiver) and `dark` colors are `.default`,
	///     the method returns `.label` to match system text color and ensure appropriate
	///     contrast in both appearances.
	///   - If only one of the colors is `.default`, a sensible fallback is used:
	///     the non-default color is combined with `.black` (`light`) or `.white` (`dark`)
	///     as needed.
	/// - Precondition: Available when `UIKit` can be imported.
	public func combinedColor(dark: HexStringColor) -> UIColor {
		if dark.isDefault, self.isDefault {
			return .label
		}
		
		let  darkSchemeUIColor = dark.nonDefault?.uiColor ?? .white
		let lightSchemeUIColor = self.nonDefault?.uiColor ?? .black
		
		return UIColor { trait in
			trait.userInterfaceStyle == .dark
				?  darkSchemeUIColor
				: lightSchemeUIColor
		}
	}
	
	/// Returns a dynamic color that adapts to the current interface style
	/// (`light` or `dark`).
	///
	/// - Parameter dark: The color to use when the system is in Dark Mode.
	/// - Returns: A dynamic `Color` that resolves to:
	///   - The receiver (`light`) when the user interface style is `light`.
	///   - The provided `dark` color when the user interface style is `dark`.
	/// - Note:
	///   ### Behavior:
	///   - If both the `light` (receiver) and `dark` colors are `.default`,
	///     the method returns `.label` to match system text color and ensure appropriate
	///     contrast in both appearances.
	///   - If only one of the colors is `.default`, a sensible fallback is used:
	///     the non-default color is combined with `.black` (`light`) or `.white` (`dark`)
	///     as needed.
	/// - Precondition: Available when `UIKit` can be imported.
	@inlinable public func combinedColor(dark: HexStringColor) -> Color {
		Color(uiColor: combinedColor(dark: dark))
	}

	/// A `UIKit` representation of the hex color.
	///
	/// - Returns: A `UIColor` created from the receiver’s hexadecimal value.
	///   If the hex string contains an alpha channel (`8` hex digits),
	///   the resulting color uses that `alpha`; otherwise, full opacity
	///   (`alpha = 1.0`) is applied.
	/// - Note:
	///   ### Behavior:
	///   - Interprets the stored `value` as `RRGGBB` or `RRGGBBAA` depending on
	///     `hasAlphaChannel`.
	///   - When `hasAlphaChannel` is `false` and `value` exceeds `0xFFFFFF`,
	///     the value is capped to `0xFFFFFF` to avoid overflow.
	///   - The color components are normalized to the `0.0`–`1.0` range.
	/// - Precondition: Available when `UIKit` can be imported.
	public var uiColor: UIColor {
		let mask      = UInt64(0xFF)
		let cappedHex = !hasAlphaChannel && value > 0xffffff ? 0xffffff : value
		
		let r = cappedHex >> (hasAlphaChannel ? 24 : 16) & mask
		let g = cappedHex >> (hasAlphaChannel ? 16 : 8) & mask
		let b = cappedHex >> (hasAlphaChannel ? 8 : 0) & mask
		let a = hasAlphaChannel ? cappedHex & mask : 255
		
		let red   = CGFloat(r) / 255.0
		let green = CGFloat(g) / 255.0
		let blue  = CGFloat(b) / 255.0
		let alpha = CGFloat(a) / 255.0
		
		return UIColor(
			red: red,
			green: green,
			blue: blue,
			alpha: alpha
		)
	}
	#elseif canImport(AppKit)
	/// Returns a dynamic color that adapts to the current appearance (`light` or `dark`)
	/// on `macOS`.
	///
	/// - Parameter dark: The color to use when the system is in Dark Mode.
	/// - Returns: A dynamic color that resolves to:
	///   - The receiver (`light`) when the appearance is `light`.
	///   - The provided `dark` color when the appearance is `dark`.
	/// - Note:
	///   ### Behavior:
	///   - If both the light (receiver) and dark colors are `.default`,
	///     the method returns `.labelColor` to match system text color and ensure
	///     appropriate contrast in both appearances.
	///   - If only one of the colors is `.default`, a sensible fallback is used:
	///     the non-default color is combined with `.black` (`light`) or `.white` (`dark`)
	///     as needed.
	/// - Precondition: Available when `AppKit` can be imported.
	public func combinedColor(dark: HexStringColor) -> NSColor {
		if dark.isDefault, self.isDefault {
			return .labelColor
		}
		
		let  darkSchemeNSColor = dark.nonDefault?.nsColor ?? .white
		let lightSchemeNSColor = self.nonDefault?.nsColor ?? .black
		
		return NSColor(name: nil) { appearance in
			let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
			return isDark ? darkSchemeNSColor : lightSchemeNSColor
		}
	}
	
	/// Returns a dynamic color that adapts to the current appearance (`light` or `dark`)
	/// on `macOS`.
	///
	/// - Parameter dark: The color to use when the system is in Dark Mode.
	/// - Returns: A dynamic `SwiftUI` `Color` that resolves based on the current appearance.
	/// - Precondition: Available when `AppKit` can be imported.
	@inlinable public func combinedColor(dark: HexStringColor) -> Color {
		Color(nsColor: combinedColor(dark: dark))
	}
	
	/// An `AppKit` representation of the hex color.
	///
	/// - Returns: An `NSColor` created from the receiver’s hexadecimal value.
	///     If the hex string contains an alpha channel (`8` hex digits),
	///     the resulting color uses that alpha; otherwise, full opacity
	///     (`alpha = 1.0`) is applied.
	/// - Note:
	///   ### Behavior:
	///   - Interprets the stored `value` as `RRGGBB` or `RRGGBBAA` depending on
	///     `hasAlphaChannel`.
	///   - When `hasAlphaChannel` is `false` and `value` exceeds `0xFFFFFF`,
	///     the value is capped to `0xFFFFFF` to avoid overflow.
	///   - The color components are normalized to the `0.0`–`1.0` range.
	/// - Precondition: Available when `AppKit` can be imported.
	public var nsColor: NSColor {
		let mask      = UInt64(0xFF)
		let cappedHex = !hasAlphaChannel && value > 0xffffff ? 0xffffff : value
		
		let r = cappedHex >> (hasAlphaChannel ? 24 : 16) & mask
		let g = cappedHex >> (hasAlphaChannel ? 16 : 8) & mask
		let b = cappedHex >> (hasAlphaChannel ? 8 : 0) & mask
		let a = hasAlphaChannel ? cappedHex & mask : 255
		
		let red   = CGFloat(r) / 255.0
		let green = CGFloat(g) / 255.0
		let blue  = CGFloat(b) / 255.0
		let alpha = CGFloat(a) / 255.0
		
		return NSColor(
			red: red,
			green: green,
			blue: blue,
			alpha: alpha
		)
	}
	#endif

	public init(from decoder: Decoder) throws {
		let rawValue = try decoder.singleValueContainer().decode(String.self)
		self.init(rawValue)
	}
	
	public func encode(to encoder: Encoder) throws {
		try description.encode(to: encoder)
	}
	
	public var description: String {
		String(format: hasAlphaChannel ? "#%08x" : "#%06x", value)
	}
}

extension KeyedDecodingContainer {
	public func decode(_: HexStringColor.Type, forKey key: Key) throws -> HexStringColor {
		if let rawValue = try? decodeIfPresent(String.self, forKey: key) {
			return HexStringColor(rawValue)
		}
		return .default
	}
}

extension Color {
	/// Creates a dynamic `SwiftUI` `Color` from two hexadecimal colors that adapts
	/// to `light` and `dark` appearances.
	///
	/// Use this factory to supply separate colors for `light` and `dark` system appearance
	/// using `HexStringColor` values. On supported platforms, the returned `Color`
	/// resolves at runtime based on the current appearance.
	///
	/// - Parameters:
	///   - light: The color to use in `light` system appearance,
	///     represented as a `HexStringColor`.
	///   - dark: The color to use in `dark` system appearance,
	///     represented as a `HexStringColor`.
	/// - Returns: A `Color` that resolves to the
	///   - `light` color when the system appearance is `light`
	///   - `dark` color when the system appearance is `dark`
	/// - Note:
	///   ### Behavior:
	///   - If both `light` and `dark` are `.default`, the resulting `Color` resolves
	///     to the system label color to maintain appropriate contrast
	///     (on platforms that support dynamic system colors).
	///   - If only one of the provided colors is `.default`, a sensible fallback is used
	///     internally so the resulting `Color` remains legible across appearances.
	///   - Resolution is delegated to platform-specific capabilities when available:
	///     - `UIKit` on `iOS`/`iPadOS`/`tvOS`/`visionOS`
	///     - `AppKit` on `macOS`
	/// - SeeAlso:
	///   - ``HexStringColor``
	///   - ``HexStringColor/combinedColor(dark:)-7dc7e``
	///   - ``HexStringColor/combinedColor(dark:)->UIColor``
	///   - ``HexStringColor/combinedColor(dark:)->NSColor``
	@inlinable public static func fromHexColors(
		light: HexStringColor,
		dark: HexStringColor
	) -> Self {
		light.combinedColor(dark: dark)
	}
}
