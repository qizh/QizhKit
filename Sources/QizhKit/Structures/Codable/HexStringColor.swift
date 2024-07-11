//
//  HexStringColor.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct HexStringColor: Codable,
							  Hashable,
							  Sendable,
							  WithDefault,
							  CustomStringConvertible,
							  ExpressibleByStringLiteral {
	public let value: UInt64
	public let hasAlphaChannel: Bool
	
	public static let `default`: HexStringColor = .init(0x000000)
	public static let black: HexStringColor = .init(0x000000)
	public static let white: HexStringColor = .init(0xffffff)
	
	public init(_ value: UInt64, isWithAlpha: Bool = false) {
		self.value = value
		self.hasAlphaChannel = isWithAlpha
	}
	
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
	
	@inlinable
	public init(stringLiteral value: String) {
		self.init(value)
	}
	
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
	
	@inlinable
	public func combinedColor(dark: HexStringColor) -> Color {
		Color(uiColor: combinedColor(dark: dark))
	}

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

public extension KeyedDecodingContainer {
	func decode(_: HexStringColor.Type, forKey key: Key) throws -> HexStringColor {
		if let rawValue = try? decodeIfPresent(String.self, forKey: key) {
			return HexStringColor(rawValue)
		}
		return .default
	}
}
