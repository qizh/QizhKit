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
	
	func format(as formatType: FormatType, _ locale: Locale = .current) -> String {
		switch formatType {
		case .string:
			return NumberFormatter.decimal(locale)
				.string(from: self)
				.or("\(self)")
		case .currency(let code):
			return NumberFormatter.currency(code, locale)
				.string(from: self)
				.or(format(as: .string) + " " + code.uppercased())
		case .percent:
			return NumberFormatter.percent(locale)
				.string(from: self / 100)
				.or(format(as: .string) + "%")
		}
	}
	
	enum FormatType {
		case string
		case currency(_ code: String)
		case percent
	}
}
