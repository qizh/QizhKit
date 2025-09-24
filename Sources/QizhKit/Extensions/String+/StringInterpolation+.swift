//
//  StringInterpolation+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Nil

public struct NilReplacement: ExpressibleByStringLiteral,
							  CustomStringConvertible,
							  Sendable {
	public let description: String
	public init(stringLiteral value: StringLiteralType) { description = value }
	
	public static let `nil`         : NilReplacement = "nil"
	public static let  undefined    : NilReplacement = "undefined"
	public static let  questionMark : NilReplacement = "?"
	public static let  x            : NilReplacement = "×"
	public static let  emptySet     : NilReplacement = "∅"
}

extension String {
	fileprivate func replacingPatterns(
		_ patterns: [String] = DefaultStringInterpolation.patternsMatch,
		with replacement: String
	) -> String {
		if let pattern = patterns.first(where: self.contains(_:)) {
			self.replacingOccurrences(of: pattern, with: replacement)
		} else {
			self
		}
	}
}

#if canImport(os.log)
import os.log

extension DefaultStringInterpolation {
	public mutating func appendInterpolation(_ value: Bool, format: OSLogBoolFormat) {
		switch (value, format) {
		case ( true, .truth ): 	appendInterpolation("true")
		case (false, .truth ): 	appendInterpolation("false")
		case ( true, .answer): 	appendInterpolation("Yes")
		case (false, .answer): 	appendInterpolation("No")
		case (_, _): 			appendInterpolation(value)
		}
	}
	
	public mutating func appendInterpolation(_ value: some BinaryInteger, format: OSLogIntegerFormatting) {
		// TODO: Apply formatting
		appendInterpolation(value)
	}
	
	public mutating func appendInterpolation(_ value: some BinaryFloatingPoint, format: OSLogFloatFormatting) {
		// TODO: Apply formatting
		appendInterpolation(value)
	}
	
	public mutating func appendInterpolation<T>(_ value: T, privacy: OSLogPrivacy) {
		appendInterpolation(value)
	}
	
	public mutating func appendInterpolation<T>(_ value: T, attributes: String) {
		appendInterpolation("\(value) ❨\(attributes)❩")
	}
	
	public mutating func appendInterpolation<T>(_ value: T, align: OSLogStringAlignment) {
		appendInterpolation(value)
	}
}
#endif

extension DefaultStringInterpolation {
	public mutating func appendInterpolation<T>(_ optional: T?) {
		switch optional {
		case .none: 			appendInterpolation("✕⃣")
		case .some(let value): 	appendInterpolation(value)
		}
	}
}

public extension DefaultStringInterpolation {
	// MARK: Optional
	
	fileprivate static let patternsMatch = [
		"$0",
		"$@",
		"%@",
		"##",
	]
	
	mutating func appendInterpolation(
		map value: String?,
		_ pattern: String? = nil,
		or fallback: NilReplacement? = nil
	) {
		value.map { value in
			pattern.map { pattern in
				appendInterpolation(pattern.replacingPatterns(with: value))
			} ?? appendInterpolation(value)
		} ?? fallback.map { fallback in
			appendInterpolation(fallback)
		}
	}
	
	mutating func appendInterpolation <Wrapped: TextOutputStreamable> (
		map value: Wrapped?,
		_ pattern: String? = nil,
		or fallback: NilReplacement? = nil
	) {
		value.map { value in
			pattern.map { pattern in
				appendInterpolation(pattern.replacingPatterns(with: "\(value)"))
			} ?? appendInterpolation(value)
		} ?? fallback.map { fallback in
			appendInterpolation(fallback)
		}
	}
	
	/// - Requires: One of the following in the `pattern` attribute:
	/// `$0`, `$@`, `%@`, `##`
	mutating func appendInterpolation <Wrapped: CustomStringConvertible> (
		map value: Wrapped?,
		_ pattern: String? = nil,
		or fallback: NilReplacement? = nil
	) {
		value.map { value in
			pattern.map { pattern in
				appendInterpolation(pattern.replacingPatterns(with: value.description))
			} ?? appendInterpolation(value)
		} ?? fallback.map { fallback in
			appendInterpolation(fallback)
		}
	}
	
	// MARK: Condition
	
	mutating func appendInterpolation <S: CustomStringConvertible> (
		 _ value: S,
		if condition: @autoclosure () -> Bool
	) {
		if condition() {
			appendInterpolation(value)
		}
	}
	
	// MARK: Float Fraction Digits
	
	mutating func appendInterpolation<F: BinaryFloatingPoint>(_ value: F, f fractionDigits: Int) {
		appendLiteral(Double(value).formatted(.number.precision(.fractionLength(fractionDigits))))
	}
	
	// MARK: Spell a Number
	
	mutating func appendInterpolation<N: NSNumber>(
		spell value: N,
		locale: Locale = .autoupdatingCurrent
	) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .spellOut
		formatter.locale = locale
		
		if let result = formatter.string(from: value) {
			appendLiteral(result)
		}
	}
	
	mutating func appendInterpolation<N: NSNumber>(
		spell value: N,
		locale identifier: String
	) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .spellOut
		formatter.locale = Locale(identifier: identifier)
		
		if let result = formatter.string(from: value) {
			appendLiteral(result)
		}
	}
	
	@inlinable mutating func appendInterpolation(spell value: Int, locale: Locale = .autoupdatingCurrent) {
		appendInterpolation(spell: NSNumber(value: value), locale: locale)
	}
	
	@inlinable mutating func appendInterpolation(spell value: Int, locale identifier: String) {
		appendInterpolation(spell: NSNumber(value: value), locale: identifier)
	}
	
	@inlinable mutating func appendInterpolation(spell value: UInt, locale: Locale = .autoupdatingCurrent) {
		appendInterpolation(spell: NSNumber(value: value), locale: locale)
	}
	
	@inlinable mutating func appendInterpolation(spell value: UInt, locale identifier: String) {
		appendInterpolation(spell: NSNumber(value: value), locale: identifier)
	}
	
	// MARK: Encode JSON
	
	mutating func appendInterpolation(
		json value: some Encodable,
		encoder providedEncoder: JSONEncoder? = .none
	) {
		let encoder: JSONEncoder = providedEncoder ?? .prettyPrinted
		
		do {
			let jsonData = try encoder.encode(value)
			if let jsonString = String(data: jsonData, encoding: .utf8) {
				appendLiteral(jsonString)
			} else {
				let jsonString = String(decoding: jsonData, as: UTF8.self)
				appendLiteral(jsonString)
			}
		} catch {
			appendLiteral(error.localizedDescription)
		}
	}
	
	mutating func appendInterpolation(
		json value: (any Sendable)?,
		encoder providedEncoder: JSONEncoder? = .none
	) {
		let encoder: JSONEncoder = providedEncoder ?? .prettyPrinted

		do {
			let jsonData = try encoder.encode(AnyEncodable(value))
			if let jsonString = String(data: jsonData, encoding: .utf8) {
				appendLiteral(jsonString)
			} else {
				let jsonString = String(decoding: jsonData, as: UTF8.self)
				appendLiteral(jsonString)
			}
		} catch {
			appendLiteral(error.localizedDescription)
		}
	}
	
	// MARK: ┗ Deprecated
	
	@available(*, deprecated, renamed: "appendInterpolation(json:)", message: "Renamed debug to json")
	@inlinable mutating func appendInterpolation(debug value: some Encodable) {
		appendInterpolation(json: value)
	}
	
	@available(*, deprecated, renamed: "appendInterpolation(json:)", message: "Renamed debug to json")
	@inlinable mutating func appendInterpolation(debug value: (any Sendable)?) {
		appendInterpolation(json: value)
	}
}

// MARK: Offset

extension DefaultStringInterpolation {
	public mutating func appendInterpolation<T>(
		_ value: T,
		offset: StringOffset,
		first: Bool = false
	) {
		appendLiteral("\(value)".offsetting(by: offset, first: first))
	}
}
