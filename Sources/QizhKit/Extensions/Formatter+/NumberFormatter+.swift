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
	
	public static func percent(_ locale: Locale = .current) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .percent
		formatter.locale = locale
		return formatter
	}
	
	public static func decimal(_ locale: Locale = .current) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = locale
		return formatter
	}
	
	/// - Parameter code: ISO 4217 code
	public static func currency(_ code: String, _ locale: Locale = .current) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = code
		formatter.locale = locale
		formatter.minimumFractionDigits = 0
		return formatter
	}
}
