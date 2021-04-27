//
//  Decimal+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Decimal {
	@inlinable
	var negated: Decimal {
		-self
	}
	
	@inlinable
	var percents: Decimal {
		self / 100
	}
	
	@inlinable
	var number: NSDecimalNumber {
		self as NSDecimalNumber
	}
	
	@inlinable
	var intValue: Int {
		number.intValue
	}
	
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
}

// MARK: Code through Data

public extension KeyedEncodingContainer {
	mutating func encode(_ value: Decimal, forKey key: K) throws {
		try encode(value.data, forKey: key)
	}
	
	mutating func encodeIfPresent(_ value: Decimal?, forKey key: K) throws {
		guard let value = value else { return }
		try encode(value, forKey: key)
	}
}

extension KeyedDecodingContainer {
	func decode(_ type: Decimal.Type, forKey key: K) throws -> Decimal {
		try decode(Data.self, forKey: key).decode(codingPath, key: key)
	}
	
	func decodeIfPresent(_ type: Decimal.Type, forKey key: K) throws -> Decimal? {
		try decodeIfPresent(Data.self, forKey: key)?.decode(codingPath, key: key)
	}
}
