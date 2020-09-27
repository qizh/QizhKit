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
