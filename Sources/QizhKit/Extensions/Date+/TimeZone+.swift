//
//  TimeZone+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.06.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension TimeZone {
	/// Same as ``gmt`` for iOS 16, manually created on earlier
	@inlinable public static var utc: TimeZone {
		if #available(iOS 16, *) {
			return .gmt
		} else {
			return TimeZone(abbreviation: "UTC")!
		}
	}
}
