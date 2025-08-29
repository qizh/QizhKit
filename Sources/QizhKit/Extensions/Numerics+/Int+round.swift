//
//  Int+round.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 14.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Int {
	func round(to interval: Int) -> Int {
		  (self / interval) * interval
		+ (self % interval) / (interval / 2) * interval
	}
}

extension FixedWidthInteger {
	public var s: String {
		switch self {
		case .max: 	".max"
		case .min : ".min"
		default: 	String(self)
		}
	}
}

extension FixedWidthInteger where Self: UnsignedInteger {
	public var s: String {
		switch self {
		case .max: 	".max"
		default: 	String(self)
		}
	}
}
