//
//  String+timeInterval.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 19.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	/// Converts `12:25:00` `String` into a `TimeInterval`
	func asTimeInterval() -> TimeInterval {
		guard isNotEmpty else { return .zero }
		
		var result: Double = .zero
		
		let parts = components(separatedBy: String.colon)
		for (index, part) in parts.reversed().enumerated() {
			result += (Double(part) ?? .zero) * (Double.sixty ↗︎ UInt(index))
		}

		return result
	}
}
