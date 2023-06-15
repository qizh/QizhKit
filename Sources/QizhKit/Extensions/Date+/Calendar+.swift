//
//  Calendar+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.06.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Calendar {
	/// Same as ``autoupdatingCurrent``
	@inlinable public static var auto: Calendar { .autoupdatingCurrent }
	
	/// ``current`` with ``TimeZone/utc`` timezone
	@inlinable public static var utc: Calendar {
		var calendar = Calendar.current
		calendar.timeZone = .utc
		return calendar
	}
}
