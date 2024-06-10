//
//  Optional+String.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 09.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Optional {
	@inlinable public var orNilString: String {
		switch self {
		case .none: 			"nil"
		case .some(let value): 	"\(value)"
		}
	}
	
	@inlinable public var orXmarkString: String {
		switch self {
		case .none: 			"✕"
		case .some(let value): 	"\(value)"
		}
	}
	
	@inlinable public var orEmptyString: String {
		switch self {
		case .none: 			""
		case .some(let value): 	"\(value)"
		}
	}
	
	@inlinable public func orString(_ string: String) -> String {
		switch self {
		case .none: 			string
		case .some(let value): 	"\(value)"
		}
	}
}
