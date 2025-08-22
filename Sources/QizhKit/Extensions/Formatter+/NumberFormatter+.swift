//
//  NumberFormatter+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension NumberFormatter {
	@available(iOS, deprecated: 15.0, renamed: "decimal.formatted(_:)", message: "Switch to modern `decimal.formatted(_ format: FormatStyle)`")
	public func string(
		from decimal: Decimal,
		as formatType: Decimal.FormatType = .string,
		position context: Formatter.Context = .unknown,
		locale: Locale = .current
	) -> String? {
		string(from: decimal as NSDecimalNumber)
	}
	
	@available(iOS, deprecated: 15.0, message: "Switch to modern `.formatted(_ format: FormatStyle)`")
	public static func percent(
		position context: Formatter.Context,
		for locale: Locale
	) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.locale = locale
		formatter.formattingContext = context
		formatter.maximumFractionDigits = 2
		return formatter
	}
	
	@available(iOS, deprecated: 15.0, message: "Switch to modern `.formatted(_ format: FormatStyle)`")
	public static func decimal(
		position context: Formatter.Context,
		for locale: Locale
	) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = locale
		formatter.formattingContext = context
		return formatter
	}
	
	/// - Parameter code: ISO 4217 code
	@available(iOS, deprecated: 15.0, message: "Switch to modern `.formatted(_ format: FormatStyle)`")
	public static func currency(
		_ code: String,
		position context: Formatter.Context,
		for locale: Locale,
		alwaysShowFraction: Bool
	) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = code
		formatter.locale = locale
		if not(alwaysShowFraction) {
			formatter.minimumFractionDigits = 0
		}
		formatter.formattingContext = context
		return formatter
	}
}
