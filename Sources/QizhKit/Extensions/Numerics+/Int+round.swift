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

public extension Int {
	var s: String {
		switch self {
		case .max: 	return ".max"
		case .min: 	return ".min"
		default: 	return "\(self)"
		}
	}
}

public extension UInt {
	var s: String {
		switch self {
		case .max: 	return ".max"
		default: 	return "\(self)"
		}
	}
}
