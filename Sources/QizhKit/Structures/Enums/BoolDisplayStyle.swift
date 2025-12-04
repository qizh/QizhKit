//
//  BoolDisplayStyle.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.12.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation
import QizhMacroKit

/// ## Output
/// | __case__ | __true__ | __false__ | Details |
/// |---------:|:--------:|:---------:|:--------|
/// | ``truth`` | true | false | |
/// | ``answer`` | yes | no | |
/// | ``state`` | on | off | |
/// | ``unipolarInt`` | 1 | 0 | |
/// | ``bipolarInt`` | 1 | -1 | |
/// | ``emojiColorMark`` | ✅ | ❌ | __OK__ / __not OK__ |
/// | ``emojiColorMarkEmotional`` | 🌟 | ❌ | __OK__ / __not OK__ in more emotional interfaces |
/// | ``emojiColorCircle`` | 🟢 | 🔴 | |
/// | ``emojiColorRing`` | 🟢 | ⭕️ | |
/// | ``emojiThumb`` | 👍 | 👎 | __Up__ / __Down__ |
/// | ``sunMoon`` | ☼ | ⏾ | |
/// | ``plusMinus`` | + | - | ± |
/// | ``mark`` | ✓ | 𐄂 | __Checkmark__ / __Xmark__|
/// | ``checkbox`` | ☑ | ☒ | > ☐ – unfilled |
/// | ``arrowUpDown`` | ↑ | ↓ | > ⭥ – both |
/// | ``arrowRightLeft`` | → | ← | > ⭤ – both |
/// | ``fillSquare`` | ■ | □ | |
/// | ``fillCircle`` | ● | ○ | |
/// | ``power`` | ⏼ | ○ | > ⏻ – standby |
/// | ``playPause`` | ⏵ | ⏸ | > ⏯ – play-pause |
/// | ``playStop`` | ⏵ | ⏹ | |
/// | ``logicalOutput`` | ⊨ | ⊭ | The model statement. >– suitable for displaying the results of checking conditions or rules. |
/// | ``logicalValue`` | The classic __verum__ / __falsum__ in logic |||
/// | ^ | ⊤ | | always __true__  |
/// | ^ | | ⊥ | always __a lie__ |
@IsCase @CaseName
public enum BoolDisplayStyle: OppositeStrings,
							  Hashable, Sendable, CaseIterable,
							  Codable,
							  DefaultCaseFirst {
	/// true | false
	case truth = "true|false"
	/// yes | no
	case answer = "yes|no"
	/// on | off
	case state = "on|off"
	/// 1 | 0
	case unipolarInt = "1|0"
	/// 1 | -
	case bipolarInt = "1|-1"
	/// ✅ | ❌
	case emojiColorMark = "✅|❌"
	/// 🌟 | ❌
	case emojiColorMarkEmotional = "🌟|❌"
	/// 🟢 | 🔴
	case emojiColorCircle = "🟢|🔴"
	/// 🟢 | ⭕️
	case emojiColorRing = "🟢|⭕️"
	/// 👍 | 👎
	case emojiThumb = "👍|👎"
	/// ☼ | ⏾
	case sunMoon = "☼|⏾"
	/// + | -
	case plusMinus = "+|-"
	/// ✓ | 𐄂
	case mark = "✓|𐄂"
	/// ☑ | ☒
	case checkbox = "☑|☒"
	/// ↑ | ↓
	case arrowUpDown = "↑|↓"
	/// → | ←
	case arrowRightLeft = "→|←"
	/// ■ | □
	case fillSquare = "■|□"
	/// ● | ○
	case fillCircle = "●|○"
	/// ⏼ | ○
	case power = "⏼|○"
	/// ⏵ | ⏸
	case playPause = "⏵|⏸"
	/// ⏵ | ⏹
	case playStop = "⏵|⏹"
	/// ⊨ | ⊭
	case logicalOutput = "⊨|⊭"
	/// ^ | ⊤
	case logicalValue = "⊤|⊥"
	
	public static let labeledValueViewDefault: BoolDisplayStyle = .fillCircle
}

// MARK: Opposite String

public struct OppositeStrings: Hashable, Sendable,
							   ExpressibleByStringLiteral,
							   ExpressibleByArrayLiteral,
							   LosslessStringConvertible {
	public let `true`: String
	public let `false`: String
	public let separator: Character?
	
	public static let `default`: Self = BoolDisplayStyle.default.rawValue
	
	// MARK: Inits
	
	public init(true t: String, false f: String, separator s: Character? = nil) {
		self.true = t
		self.false = f
		self.separator = nil
	}
	
	@inlinable public init(_ t: String, _ f: String, _ s: Character? = nil) {
		self.init(true: t, false: f, separator: s)
	}
	
	@inlinable public init(_ t: Character, _ f: Character, _ s: Character? = nil) {
		self.init(t.s, f.s, s)
	}
	@inlinable public init(_ t: Substring, _ f: Substring, _ s: Character? = nil) {
		self.init(t.s, f.s, s)
	}
	@inlinable public init<LS>(_ t: LS, _ f: LS, _ s: Character? = nil)
	where LS: LosslessStringConvertible {
		self.init(t.s, f.s, s)
	}
	
	// MARK: Adoptions
	
	@inlinable public init(arrayLiteral elements: String...) { self.init(elements) }
	public init(_ elements: [String]) {
		switch elements.count {
		case 1: self = .init(elements[0])
		case 2: self = .init(elements[0], elements[1])
		case 3... where elements[2].isNotEmpty:
			self = .init(elements[0], elements[1], elements[2].first)
		default: self = .default
		}
	}
	
	@inlinable public init(_ s: String) { self.init(stringLiteral: s) }
	public init(stringLiteral value: String) {
		if value.count >= 2 {
			self.init(value.components(separatedBy: String.line))
		} else {
			self = .default
		}
	}
	
	public var description: String {
		"\(self.true)\(separator.orEmptyString)\(self.false)"
	}
	
	// MARK: Tools
	
	public func string(for boolean: Bool) -> String {
		if boolean {
			self.true
		} else {
			self.false
		}
	}
}

// MARK: Bool +

extension Bool {
	public func s(_ style: BoolDisplayStyle) -> String {
		if self {
			style.rawValue.true
		} else {
			style.rawValue.false
		}
	}
}

// MARK: .s & .asString()

extension LosslessStringConvertible {
	/// Returns a `String` initialized with a caller.
	/// - Returns: A `String` initialized with caller.
	/// - SeeAlso:
	///   - ``s``: A variable doing the same.
	@inlinable public func asString() -> String { String(self) }
	/// Returns a `String` initialized with a caller.
	/// - Returns: A `String` initialized with caller.
	/// - SeeAlso:
	///   - ``asString()``: A function doing the same.
	@inlinable public var s: String { String(self) }
}

// MARK: String Interpolation +

extension DefaultStringInterpolation {
	@inlinable public mutating
	func appendInterpolation(_ value: Bool, _ style: BoolDisplayStyle) {
		appendInterpolation(value.s(style))
	}
	
	@inlinable public mutating
	func appendInterpolation(_ value: Bool, style: BoolDisplayStyle) {
		appendInterpolation(value.s(style))
	}
}
