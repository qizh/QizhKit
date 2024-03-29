//
//  Decimal+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Decimal {
	@inlinable
	var negated: Decimal {
		-self
	}
	
	@inlinable
	var percents: Decimal {
		self / 100
	}
	
	// MARK: Type convertion
	
	@inlinable var number: NSDecimalNumber { self as NSDecimalNumber }
	@inlinable var intValue: Int { number.intValue }
	@inlinable var double: Double { number.doubleValue }
	@inlinable var cg: CGFloat { CGFloat(double) }
	
	@inlinable
	var cents: Int {
		(self * .hundred).intValue
	}
	
	func format(
		as formatType: FormatType,
		position context: Formatter.Context,
		for locale: Locale
	) -> String {
		switch formatType {
		case .string:
			return NumberFormatter.decimal(position: context, for: locale)
				.string(from: self)
				.or("\(self)")
		case let .currency(code, alwaysShowFraction):
			return NumberFormatter
				.currency(
					code,
					position: context,
					for: locale,
					alwaysShowFraction: alwaysShowFraction
				)
				.string(from: self)
				.or(format(as: .string, position: context, for: locale) + .space + code.uppercased())
		case .percent:
			return NumberFormatter.percent(position: context, for: locale)
				.string(from: self / 100)
				.or(format(as: .string, position: context, for: locale) + .percent)
		}
	}
	
	enum FormatType {
		case string
		case currency(_ code: String, alwaysShowFraction: Bool)
		case percent
	}
}

// MARK: Round

public extension Decimal {
	mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
		var localCopy = self
		NSDecimalRound(&self, &localCopy, scale, roundingMode)
	}

	func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
		var result = Decimal()
		var localCopy = self
		NSDecimalRound(&result, &localCopy, scale, roundingMode)
		return result
	}
	
	mutating func round(toNearest: Decimal, _ roundingMode: NSDecimalNumber.RoundingMode) {
		self = (self / toNearest).rounded(0, roundingMode) * toNearest
	}
	
	@inlinable
	func rounded(toNearest: Decimal, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
		(self / toNearest).rounded(0, roundingMode) * toNearest
	}
}

// MARK: Fraction

extension Decimal {
	/// Can count up to 9
	@inlinable
	public var decimalDigitsCount: Int {
		max(-exponent, 0)
	}
}

// MARK: Pow

extension Decimal {
	public func pow(_ p: Int) -> Decimal {
		p < 0
			? 1.0 / Foundation.pow(self, -p)
			: Foundation.pow(self, p)
	}
}

// MARK: Ticks

extension Decimal {
	public static func tickSize(from min: Decimal, to max: Decimal, steps: UInt) -> Decimal {
		let range = (max - min).absolute
		let guess = range / Decimal(steps)
		let magnitude = log10(guess.double).rounded().int
		let powered = Decimal.ten.pow(magnitude)
		var digit = (guess/powered).rounded(0, .plain)
		switch digit {
		case ...1: digit = 1
		case ...2: digit = 2
		case ...5: digit = 5
		default: digit = 10
		}
		return digit * powered
	}
	
	public static func ticks(from min: Decimal, to max: Decimal, steps: UInt) -> [Decimal] {
		let step = tickSize(from: min, to: max, steps: steps)
		var results: [Decimal] = .empty
		var current = min.rounded(toNearest: step, .up)
		while current <= max {
			results.append(current)
			current += step
		}
		return results
	}
}

/*
// MARK: Code through Data

@propertyWrapper
public struct DataCodeDecimal: Codable, CustomStringConvertible {
	public var wrappedValue: Decimal
	
	public init(wrappedValue: Decimal) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode(Data.self)
		var value: Decimal = .zero
		guard withUnsafeMutableBytes(of: &value, data.copyBytes) == MemoryLayout.size(ofValue: value) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Data could not be converted to a numberic value: \(Array(data))")
		}
		self.wrappedValue = value
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue.data)
	}
	
	public var description: String {
		wrappedValue.format(as: .string, position: .standalone, for: .current)
	}
}

public extension KeyedEncodingContainer {
	mutating func encode(_ value: DataCodeDecimal, forKey key: K) throws {
		try encode(value.wrappedValue.data, forKey: key)
	}
	
	mutating func encodeIfPresent(_ value: DataCodeDecimal?, forKey key: K) throws {
		guard let value = value else { return }
		try encode(value, forKey: key)
	}
}

extension KeyedDecodingContainer {
	func decode(_ type: DataCodeDecimal.Type, forKey key: K) throws -> DataCodeDecimal {
		let value: Decimal = try decode(Data.self, forKey: key).decode(codingPath, key: key)
		return DataCodeDecimal(wrappedValue: value)
	}
	
	func decodeIfPresent(_ type: DataCodeDecimal.Type, forKey key: K) throws -> DataCodeDecimal? {
		if let value: Decimal = try decodeIfPresent(Data.self, forKey: key)?
			.decode(codingPath, key: key) {
			return DataCodeDecimal(wrappedValue: value)
		}
		return .none
	}
}
*/
