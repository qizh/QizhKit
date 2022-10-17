//
//  OptionalDateCompare.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 31.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Optional: Comparable where Wrapped: Comparable {
	/// Makes `some` bigger than `none`
	public static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
		switch rhs {
		case .none:
			/// lhs `<` nil
			/// nil `<` nil
			return false
		case .some(let r):
			switch lhs {
			case .none:
				/// nil `<` rhs
				return true
			case .some(let l):
				/// lhs `<` rhs
				return l < r
			}
		}
	}
}
