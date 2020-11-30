//
//  Decimal+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Decimal {
	var negated: Decimal {
		var copy = self
		copy.negate()
		return copy
	}
	
	@inlinable var percents: Decimal {
		self / 100
	}
	
	@inlinable var number: NSDecimalNumber {
		self as NSDecimalNumber
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
		case .currency(let code):
			return NumberFormatter.currency(code, position: context, for: locale)
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
		case currency(_ code: String)
		case percent
	}
}
