//
//  StringInterpolation+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Nil

public struct NilReplacement:
	ExpressibleByStringLiteral,
	CustomStringConvertible
{
	public let description: String
	public init(stringLiteral value: StringLiteralType) { description = value }
	
	public static let `nil`         : Self = "nil"
	public static let  undefined    : Self = "undefined"
	public static let  questionMark : Self = "?"
	public static let  x            : Self = "×"
	public static let  emptySet     : Self = "∅"
}

public extension DefaultStringInterpolation {
	// MARK: Optional
	
	private static let patternMatch: String = "$0"
	
	/*
	mutating func appendInterpolation<Wrapped>(
		map value: Wrapped?,
		or fallback: NilReplacement? = nil
	) where Wrapped: CustomStringConvertible {
		appendInterpolation(map: value, String?.none, or: fallback)
	}
	
	mutating func appendInterpolation(
		map value: String?,
		or fallback: NilReplacement? = nil
	) {
		appendInterpolation(map: value, String?.none, or: fallback)
	}
	*/
	
	mutating func appendInterpolation(
		  map value: String?,
		  _ pattern: String? = nil,
		or fallback: NilReplacement? = nil
	) {
		value.map { value in
			pattern.map { pattern in
				let result = pattern
					.replacingOccurrences(
						of: Self.patternMatch,
						with: value
					)
				appendInterpolation(result)
			} ?? appendInterpolation(value)
		} ?? fallback.map { fallback in
			appendInterpolation(fallback)
		}
	}
	
	mutating func appendInterpolation<Wrapped>(
		   map value: Wrapped?,
		   _ pattern: String? = nil,
		 or fallback: NilReplacement? = nil
	)
		where Wrapped: TextOutputStreamable
	{
		value.map { value in
			pattern.map { pattern in
				let result = pattern
					.replacingOccurrences(
						of: Self.patternMatch,
						with: "\(value)"
				)
				appendInterpolation(result)
			} ?? appendInterpolation(value)
		} ?? fallback.map { fallback in
			appendInterpolation(fallback)
		}
	}

	mutating func appendInterpolation<Wrapped>(
		   map value: Wrapped?,
		   _ pattern: String? = nil,
		 or fallback: NilReplacement? = nil
	)
		where Wrapped: CustomStringConvertible
	{
		value.map { value in
			pattern.map { pattern in
				let result = pattern
					.replacingOccurrences(
						of: Self.patternMatch,
						with: "\(value)"
					)
				appendInterpolation(result)
			} ?? appendInterpolation(value)
		} ?? fallback.map { fallback in
			appendInterpolation(fallback)
		}
	}
	
	// MARK: Condition
	
	mutating func appendInterpolation<S>(
		 _ value: S,
		if condition: @autoclosure () -> Bool
	)
		where S: CustomStringConvertible
	{
		guard condition() else { return }
		appendInterpolation(value)
	}
	
	// MARK: Float Fraction Digits
	
	mutating func appendInterpolation<F: BinaryFloatingPoint>(_ value: F, f fractionDigits: Int) {
		let formatter = NumberFormatter()
		formatter.maximumFractionDigits = fractionDigits
		
		if let result = formatter.string(from: Double(value) as NSNumber) {
			appendLiteral(result)
		}
	}
	
	// MARK: Spell a Number
	
	mutating func appendInterpolation<N: NSNumber>(
		spell value: N,
		locale: Locale
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
	
	// MARK: Debug Encode
	
	mutating func appendInterpolation<T: Encodable>(debug value: T) {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		do {
			let encoded = try encoder.encode(value)
			let string = String(decoding: encoded, as: UTF8.self)
			appendLiteral(string)
		} catch {
			appendLiteral(error.localizedDescription)
		}
	}
	
	mutating func appendInterpolation(debug value: Any?) {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		do {
			let encoded = try encoder.encode(AnyEncodable(value))
			let string = String(decoding: encoded, as: UTF8.self)
			appendLiteral(string)
		} catch {
			appendLiteral(error.localizedDescription)
		}
	}
}
