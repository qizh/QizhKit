//
//  CurrencyCode.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Enum

public enum CurrencyCode:
	String,
	Codable,
	Sendable,
	Hashable,
	CaseComparable,
	DefaultCaseFirst,
	AcceptingOtherValues,
	CaseInsensitiveStringRepresentable
{
	case usd = "USD"
	case eur = "EUR"
	case gbp = "GBP"
	case rur = "RUR"
	case uah = "UAH"
	case thb = "THB"
	
	public static func symbol(for currencyCode: String, locale: Locale = .current) -> String? {
		let style = FloatingPointFormatStyle<Double>.Currency(code: currencyCode)
			.locale(locale)
		
		// Format "0.00" (depending on the locale) to reveal symbol patterns
		let formattedZero = 0.0.formatted(style)
		
		// Identify locale separators so we can strip them out
		let decimalSeparator = locale.decimalSeparator ?? "."
		let groupingSeparator = locale.groupingSeparator ?? ","
		
		// Build a character set that includes digits, decimal/grouping separators, and whitespace
		var charsToRemove = CharacterSet.decimalDigits
		charsToRemove.insert(charactersIn: decimalSeparator)
		charsToRemove.insert(charactersIn: groupingSeparator)
		charsToRemove.formUnion(.whitespacesAndNewlines)
		
		// Filter out everything in that set, leaving the symbol or symbol-like text
		let symbolScalars = formattedZero.unicodeScalars.filter { scalar in
			!charsToRemove.contains(scalar)
		}
		
		// Clean up leading or trailing whitespace
		let symbol = String(symbolScalars).trimmingCharacters(in: .whitespacesAndNewlines)
		return symbol.isEmpty ? nil : symbol
	}
	
	/*
	private static var symbols: [String: String] = .empty
	public static func symbol(for code: String) -> String? {
		guard code.count == 3 else { return nil }
		if let cached = symbols[code] {
			return cached.nonEmpty
		}
		let value = findSymbol(by: code)
		symbols[code] = value
		return value.nonEmpty
	}
	
	private static func findSymbol(by code: String) -> String {
		var candidates: [String] = .init()
		let ids = NSLocale.availableLocaleIdentifiers
		
		for id in ids {
			guard let symbol = findSymbol(in: id, by: code) else { continue }
			if symbol.isAlone { return symbol }
			candidates.append(symbol)
		}
		
		return candidates.lazy.sorted(by: \.count).first.orEmpty
	}
	
	private static func findSymbol(
		in id: String,
		by code: String
	) -> String? {
		let locale = Locale(identifier: id)
		return code == locale.currency?.identifier
			? locale.currencySymbol
			: nil
	}
	
	public var symbol: String? {
		CurrencyCode.symbol(for: rawValue)
	}
	*/
	
	/*
	@inlinable public func formatter(
		position context: Formatter.Context,
		for locale: Locale,
		alwaysShowFraction: Bool
	) -> NumberFormatter {
		CurrencyCode.formatter(
			currency: rawValue,
			position: context,
			for: locale,
			alwaysShowFraction: alwaysShowFraction
		)
	}
	*/
	
	/*
	fileprivate static var formatters = [String: NumberFormatter]()
	
	public static func formatter(
		currency code: String,
		position context: Formatter.Context,
		for locale: Locale,
		alwaysShowFraction: Bool
	) -> NumberFormatter {
		let key: String = code + locale.identifier + context.stringValue
		if let formatter = CurrencyCode.formatters[key] {
			return formatter
		} else {
			let formatter = NumberFormatter
				.currency(
					code,
					position: context,
					for: locale,
					alwaysShowFraction: alwaysShowFraction
				)
			CurrencyCode.formatters[key] = formatter
			return formatter
		}
	}
	*/
	
	// fileprivate static var roundingScales: [String: Int] = .empty
	public static let isoFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currencyISOCode
		return formatter
	}()
}

// MARK: Any

public typealias AnyCurrencyCode = ExtraCase<CurrencyCode>

public extension AnyCurrencyCode {
	static let usd = Self(.usd)
	static let eur = Self(.eur)
	static let gbp = Self(.gbp)
	static let rur = Self(.rur)
	static let uah = Self(.uah)
	static let thb = Self(.thb)
	
	@inlinable var code: String { rawValue.uppercased() }
	
	/*
	func formatter(
		position context: Formatter.Context,
		for locale: Locale,
		alwaysShowFraction: Bool
	) -> NumberFormatter {
		CurrencyCode.formatter(
			currency: code,
			position: context,
			for: locale,
			alwaysShowFraction: alwaysShowFraction
		)
	}
	*/
	
	/*
	@inlinable func string(
		for price: NSNumber,
		position context: Formatter.Context,
		in locale: Locale,
		alwaysShowFraction: Bool
	) -> String {
		formatter(
			position: context,
			for: locale,
			alwaysShowFraction: alwaysShowFraction
		)
		.string(from: price)
		.or("\(price) \(code)")
	}
	*/
	
	@inlinable func string(
		for price: Decimal,
		position context: Formatter.Context,
		in locale: Locale,
		alwaysShowFraction: Bool
	) -> String {
		price
			.formatted(
				.currency(code: code)
				.locale(locale)
				.precision(
					alwaysShowFraction
					? .fractionLength(roundingScale)
					: .fractionLength(0...roundingScale)
				)
			)
		
		/*
		string(
			for: price.number,
			position: context,
			in: locale,
			alwaysShowFraction: alwaysShowFraction
		)
		*/
	}
	
	/*
	@inlinable func string(
		for price: Double,
		position context: Formatter.Context,
		in locale: Locale,
		alwaysShowFraction: Bool
	) -> String {
		string(
			for: NSNumber(value: price),
			position: context,
			in: locale,
			alwaysShowFraction: alwaysShowFraction
		)
	}
	*/
	
	@inlinable var symbol: String? {
		CurrencyCode.symbol(for: rawValue)
	}
	
	var roundingScale: Int {
		let formatter = CurrencyCode.isoFormatter
		formatter.currencyCode = code.uppercased()
		return formatter.maximumFractionDigits
	}
}
