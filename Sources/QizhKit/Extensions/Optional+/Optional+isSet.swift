//
//  Optional+isSet.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 20.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Optional {
	@inlinable var isSet: Bool { self != nil }
	@inlinable var isNotSet: Bool { self == nil }
}
