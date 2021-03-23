//
//  NumberFormatter+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension NumberFormatter {
	open func string(from decimal: Decimal) -> String? {
		string(from: decimal as NSDecimalNumber)
	}
	
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
	public static func currency(
		_ code: String,
		position context: Formatter.Context,
		for locale: Locale
	) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = code
		formatter.locale = locale
		formatter.minimumFractionDigits = 0
		formatter.formattingContext = context
		return formatter
	}
}
