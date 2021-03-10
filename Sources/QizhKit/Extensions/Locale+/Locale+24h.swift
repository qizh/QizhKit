//
//  Locale+24h.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Locale {
	@inlinable var isUsing12HFormat: Bool {
		DateFormatter
			.dateFormat(fromTemplate: "j", options: 0, locale: self)!
			.contains("a")
	}
	
	@inlinable var isUsing24HFormat: Bool {
		!isUsing12HFormat
	}
}

public extension Locale {
	func localizedCurrencySymbol(forCurrencyCode currencyCode: String) -> String? {
		guard let languageCode = languageCode, let regionCode = regionCode else { return nil }

		/*
		 Each currency can have a symbol ($, £, ¥),
		 but those symbols may be shared with other currencies.
		 For example, in Canadian and American locales,
		 the $ symbol on its own implicitly represents CAD and USD, respectively.
		 Including the language and region here ensures that
		 USD is represented as $ in America and US$ in Canada.
		*/
		let components: [String: String] = [
			NSLocale.Key.languageCode.rawValue: languageCode,
			NSLocale.Key.countryCode.rawValue: regionCode,
			NSLocale.Key.currencyCode.rawValue: currencyCode,
		]

		let identifier = Locale.identifier(fromComponents: components)

		return Locale(identifier: identifier).currencySymbol
	}
}
