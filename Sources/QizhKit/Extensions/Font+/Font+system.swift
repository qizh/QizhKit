//
//  Font+sugar.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension View {
	typealias FMod = FontModification
	
	@inlinable func fontSize(_ value: CGFloat, _ weight: Font.Weight = .regular, _ mod: FMod = .none) -> some View {
		font(Font.system(size: value, weight: weight).apply(mod))
	}
	
	@inlinable func ultraLight(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .ultraLight, mod) }
	@inlinable func       thin(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .thin, mod) }
	@inlinable func      light(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .light, mod) }
	@inlinable func    regular(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .regular, mod) }
	@inlinable func     medium(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .medium, mod) }
	@inlinable func   semibold(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .semibold, mod) }
	@inlinable func       bold(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .bold, mod) }
	@inlinable func      heavy(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .heavy, mod) }
	@inlinable func      black(_ size: CGFloat, _ mod: FMod = .none) -> some View { fontSize(size, .black, mod) }
}

public extension Text {
	typealias FMod = FontModification
	
	@inlinable func fontSize(_ value: CGFloat, _ weight: Font.Weight = .regular, _ mod: FMod = .none) -> Text {
		font(Font.system(size: value, weight: weight).apply(mod))
	}
	
	@inlinable func ultraLight(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .ultraLight, mod) }
	@inlinable func       thin(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .thin, mod) }
	@inlinable func      light(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .light, mod) }
	@inlinable func    regular(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .regular, mod) }
	@inlinable func     medium(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .medium, mod) }
	@inlinable func   semibold(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .semibold, mod) }
	@inlinable func       bold(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .bold, mod) }
	@inlinable func      heavy(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .heavy, mod) }
	@inlinable func      black(_ size: CGFloat, _ mod: FMod = .none) -> Text { fontSize(size, .black, mod) }
}

public extension Font {
	@inlinable static func size(_ value: CGFloat, weight: Font.Weight = .regular) -> Font {
		.system(size: value, weight: weight)
	}
	
	@inlinable static func ultraLight(_ size: CGFloat) -> Font { .system(size: size, weight: .ultraLight) }
	@inlinable static func       thin(_ size: CGFloat) -> Font { .system(size: size, weight: .thin) }
	@inlinable static func      light(_ size: CGFloat) -> Font { .system(size: size, weight: .light) }
	@inlinable static func    regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
	@inlinable static func     medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium) }
	@inlinable static func   semibold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
	@inlinable static func       bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold) }
	@inlinable static func      heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy) }
	@inlinable static func      black(_ size: CGFloat) -> Font { .system(size: size, weight: .black) }
	
	func apply(_ mod: FontModification) -> Font {
		switch mod {
		case .none: 				return self
		case .smallCaps: 			return self.smallCaps()
		case .lowercaseSmallCaps: 	return self.lowercaseSmallCaps()
		case .uppercaseSmallCaps: 	return self.uppercaseSmallCaps()
		case .italic: 				return self.italic()
		case .monospacedDigit: 		return self.monospacedDigit()
		case .tight:
			if #available(iOS 14.0, *) {
				return self.leading(.tight)
			} else {
				return self
			}
		case .loose:
			if #available(iOS 14.0, *) {
				return self.leading(.loose)
			} else {
				return self
			}
		}
	}
}

public enum FontModification {
	case none
	case smallCaps
	case lowercaseSmallCaps
	case uppercaseSmallCaps
	case italic
	case monospacedDigit
	@available(iOS 14, *)
	case tight
	@available(iOS 14, *)
	case loose
}
