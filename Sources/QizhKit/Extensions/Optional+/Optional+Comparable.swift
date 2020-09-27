//
//  OptionalDateCompare.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 31.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Optional: Comparable where Wrapped: Comparable {
	public static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		if let r = rhs {
			if let l = lhs {
				return l < r
			} else {
				return false
			}
		} else {
			return true
		}
	}
}
