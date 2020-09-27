//
//  Optional+String.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 09.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Optional {
	@inlinable var orNilString: String {
		switch self {
		case .none:
			return "nil"
		case .some(let value):
			return "\(value)"
		}
	}
}
