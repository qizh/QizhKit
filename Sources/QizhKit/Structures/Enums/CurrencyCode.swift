//
//  CurrencyCode.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public enum CurrencyCode:
	String,
	Codable,
	Hashable,
	CaseComparable,
	DefaultCaseFirst,
	AcceptingOtherValues
{
	case usd = "USD"
	case eur = "EUR"
	case gbp = "GBP"
	case rur = "RUR"
	case uah = "UAH"
	case thb = "THB"

	@inlinable public func formatter(_ locale: Locale) -> NumberFormatter {
		CurrencyCode.formatter(for: rawValue, locale)
	}
	
	fileprivate static var formatters = [String: NumberFormatter]()
	public static func formatter(for code: String, _ locale: Locale) -> NumberFormatter {
		let key: String = code + locale.identifier
		if let formatter = CurrencyCode.formatters[key] {
			return formatter
		} else {
			let formatter = NumberFormatter.currency(code, locale)
			CurrencyCode.formatters[key] = formatter
			return formatter
		}
	}
}

public typealias AnyCurrencyCode = ExtraCase<CurrencyCode>

public extension AnyCurrencyCode {
	static let usd = Self(.usd)
	static let eur = Self(.eur)
	static let gbp = Self(.gbp)
	static let rur = Self(.rur)
	static let uah = Self(.uah)
	static let thb = Self(.thb)

	@inlinable var code: String { rawValue }
	func formatter(_ locale: Locale) -> NumberFormatter { CurrencyCode.formatter(for: code, locale) }
	
	@inlinable func string(for price: NSNumber, _ locale: Locale) -> String {
		formatter(locale)
			.string(from: price)
			.or("\(price) \(code)")
	}
	
	@inlinable func string(for price: Decimal, _ locale: Locale) -> String {
		string(for: price.number, locale)
	}
	
	@inlinable func string(for price: Double, _ locale: Locale) -> String {
		string(for: NSNumber(value: price), locale)
	}
}
