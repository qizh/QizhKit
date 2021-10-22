//
//  Locale+constants.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Locale {
	@inlinable public static var en_US: Locale { "en_US" }
	@inlinable public static var ru_UA: Locale { "ru_UA" }
	@inlinable public static var th_TH: Locale { "th_TH" }
}

extension Locale: ExpressibleByStringLiteral {
	@inlinable public init(stringLiteral value: String) {
		self.init(identifier: value)
	}
}
