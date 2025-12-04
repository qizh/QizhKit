//
//  BoolDisplayStyle.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.12.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation
import QizhMacroKit

/// A display style for presenting boolean values as pairs of strings or symbols.
///
/// Each case defines a pair of opposite strings (one for `true` and one for `false`)
/// encoded in its ``OppositeStrings`` raw value. The table above documents all
/// concrete mappings.
/// ## Values of the cases
/// | __case__ | __true__ | __false__ | Details |
/// |---------:|:--------:|:---------:|:--------|
/// | ``BoolDisplayStyle/truth`` | true | false | |
/// | ``BoolDisplayStyle/answer`` | yes | no | |
/// | ``BoolDisplayStyle/state`` | on | off | |
/// | ``BoolDisplayStyle/unipolarInt`` | 1 | 0 | |
/// | ``BoolDisplayStyle/bipolarInt`` | 1 | -1 | |
/// | ``BoolDisplayStyle/emojiColorMark`` | ✅ | ❌ | __OK__ / __not OK__ |
/// | ``BoolDisplayStyle/emojiColorMarkEmotional`` | 🌟 | ❌ | __OK__ / __not OK__ in more emotional interfaces |
/// | ``BoolDisplayStyle/emojiColorCircle`` | 🟢 | 🔴 | |
/// | ``BoolDisplayStyle/emojiColorRing`` | 🟢 | ⭕️ | |
/// | ``BoolDisplayStyle/emojiThumb`` | 👍 | 👎 | __Up__ / __Down__ |
/// | ``BoolDisplayStyle/sunMoon`` | ☼ | ⏾ | |
/// | ``BoolDisplayStyle/plusMinus`` | + | - | ± |
/// | ``BoolDisplayStyle/mark`` | ✓ | 𐄂 | __Checkmark__ / __Xmark__|
/// | ``BoolDisplayStyle/checkbox`` | ☑ | ☒ | > ☐ – unfilled |
/// | ``BoolDisplayStyle/arrowUpDown`` | ↑ | ↓ | > ⭥ – both |
/// | ``BoolDisplayStyle/arrowRightLeft`` | → | ← | > ⭤ – both |
/// | ``BoolDisplayStyle/fillSquare`` | ■ | □ | |
/// | ``BoolDisplayStyle/fillCircle`` | ● | ○ | |
/// | ``BoolDisplayStyle/power`` | ⏼ | ○ | > ⏻ – standby |
/// | ``BoolDisplayStyle/playPause`` | ⏵ | ⏸ | > ⏯ – play-pause |
/// | ``BoolDisplayStyle/playStop`` | ⏵ | ⏹ | |
/// | ``BoolDisplayStyle/logicalOutput`` | ⊨ | ⊭ | The model statement. >– suitable for displaying the results of checking conditions or rules. |
/// | ``BoolDisplayStyle/logicalValue`` | The classic __verum__ / __falsum__ in logic |||
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
	/// 1 | -1
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
	
	/// The default style used when displaying boolean values in labeled views.
	///
	/// This constant is intended to be the shared baseline for UI components that
	/// show a boolean as a filled/unfilled circle without having to choose a
	/// specific style at the call site.
	public static let labeledValueViewDefault: BoolDisplayStyle = .fillCircle
}

// MARK: Opposite String

/// A pair of opposite strings used to represent the `true` and `false` values
/// of a boolean.
///
/// `OppositeStrings` is used as the raw value type of ``BoolDisplayStyle`` and
/// can also be used directly wherever you need a small, type-safe container for
/// two mutually exclusive labels. It supports convenient initialization from
/// explicit `String` values, string literals, and array literals.
///
/// The optional ``separator`` is used when the pair is rendered as a single
/// string via ``description``.
public struct OppositeStrings: Hashable, Sendable,
							   ExpressibleByStringLiteral,
							   ExpressibleByArrayLiteral,
							   LosslessStringConvertible {
	/// The string used to represent the boolean value `true`.
	public let `true`: String
	/// The string used to represent the boolean value `false`.
	public let `false`: String
	/// An optional separator that can be used when joining the two strings into
	/// a single value (for example, in ``description``).
	public let separator: Character?
	
	/// A fallback pair of strings used when initialization cannot infer a more
	/// specific representation.
	///
	/// This value is derived from ``BoolDisplayStyle/default`` and kept in sync
	/// with that case.
	public static let `default`: Self = BoolDisplayStyle.default.rawValue
	
	// MARK: Inits
	
	/// Creates a new pair of strings representing `true` and `false`.
	/// - Parameters:
	///   - t: The string used for the `true` value.
	///   - f: The string used for the `false` value.
	///   - s: An optional separator to be used when rendering the pair as a
	///     single string.
	public init(true t: String, false f: String, separator s: Character? = nil) {
		self.true = t
		self.false = f
		self.separator = s
	}
	
	/// Convenience initializer that infers `true` and `false` labels from two
	/// strings and an optional separator.
	@inlinable public init(_ t: String, _ f: String, _ s: Character? = nil) {
		self.init(true: t, false: f, separator: s)
	}
	
	/// Convenience initializer that builds the pair from two characters and an
	/// optional separator.
	@inlinable public init(_ t: Character, _ f: Character, _ s: Character? = nil) {
		self.init(t.s, f.s, s)
	}
	
	/// Convenience initializer that builds the pair from two substrings and an
	/// optional separator.
	@inlinable public init(_ t: Substring, _ f: Substring, _ s: Character? = nil) {
		self.init(t.s, f.s, s)
	}
	
	/// Convenience initializer that builds the pair from two values that can be
	/// losslessly converted to strings.
	@inlinable public init<LS>(_ t: LS, _ f: LS, _ s: Character? = nil)
	where LS: LosslessStringConvertible {
		self.init(t.s, f.s, s)
	}
	
	// MARK: Adoptions
	
	/// Creates an instance from a string array literal.
	/// - Note: The first two elements are used as the `true` and `false` labels.
	///   An optional third element can provide the separator.
	@inlinable public init(arrayLiteral elements: String...) { self.init(elements) }
	
	/// Creates an instance from an array of strings.
	/// - Parameter elements: An array whose first element is used for `true`, the
	///   second for `false`, and an optional third non-empty element for the
	///   separator. If the array does not provide enough information, the
	///   ``default`` value is used instead.
	public init(_ elements: [String]) {
		switch elements.count {
		case 1: self = .init(elements[0])
		case 2: self = .init(elements[0], elements[1])
		case 3... where elements[2].isNotEmpty:
			self = .init(elements[0], elements[1], elements[2].first)
		default: self = .default
		}
	}
	
	/// Convenience initializer that forwards to the string literal initializer.
	@inlinable public init(_ s: String) { self.init(stringLiteral: s) }
	
	/// Creates an instance from a single string literal.
	///
	/// The literal is split using ``String.line`` to obtain the `true` and
	/// `false` labels. If the value does not contain enough information, the
	/// ``default`` value is used instead.
	public init(stringLiteral value: String) {
		let stringsArray = value
			.split(separator: .line, omittingEmptySubsequences: true)
			.compactMap(\.s.nonEmpty)
		
		if stringsArray.count >= 2 {
			self.init(stringsArray)
		} else {
			self = .default
		}
	}
	
	/// A string representation that joins the `true` and `false` labels using
	/// the optional ``separator``.
	public var description: String {
		"\(self.true)\(separator.orEmptyString)\(self.false)"
	}
	
	// MARK: Tools
	
	/// Returns the appropriate label for a given boolean value.
	/// - Parameter boolean: The value to represent.
	/// - Returns: ``true`` when `boolean` is `true`, otherwise ``false``.
	public func string(for boolean: Bool) -> String {
		if boolean {
			self.true
		} else {
			self.false
		}
	}
}

// MARK: Bool +

/// Convenience API for converting a boolean into a string using a
/// ``BoolDisplayStyle``.
/// - Parameter style: The style that defines which pair of strings to use for
///   `true` and `false`.
/// - Returns: The string corresponding to the receiver’s value as defined by
///   `style`.
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
	/// Interpolates a boolean value using the provided display style.
	/// - Parameters:
	///   - value: The boolean value to interpolate.
	///   - style: The style that defines which pair of strings to use.
	@inlinable public mutating
	func appendInterpolation(_ value: Bool, _ style: BoolDisplayStyle) {
		appendInterpolation(value.s(style))
	}
	
	/// Interpolates a boolean value using the provided display style.
	/// - Parameters:
	///   - value: The boolean value to interpolate.
	///   - style: The style that defines which pair of strings to use.
	@inlinable public mutating
	func appendInterpolation(_ value: Bool, style: BoolDisplayStyle) {
		appendInterpolation(value.s(style))
	}
}
