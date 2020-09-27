//
//  BinaryInteger+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension BinaryInteger {
	/// Четное
	@inlinable var isEven: Bool { isMultiple(of: 2) }
	/// Нечетное
	@inlinable var isOdd: Bool { !isEven }
}
