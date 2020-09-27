//
//  Bool+toggled.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Bool {
	@inlinable var toggled: Bool { !self }
}

@inlinable public func not(_ value: Bool) -> Bool {
	!value
}
