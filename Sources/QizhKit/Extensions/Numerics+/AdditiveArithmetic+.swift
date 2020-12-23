//
//  AdditiveArithmetic+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Zero

public extension AdditiveArithmetic where Self: Equatable {
	@inlinable var isZero: Bool { self == .zero }
	@inlinable var isNotZero: Bool { self != .zero }
	@inlinable var nonZero: Self? { isZero ? nil : self }
	
	@inlinable var bool: Bool { isNotZero }
}

public extension Collection {
	@inlinable
	func sum <Output: AdditiveArithmetic> (
		of transform: (Element) -> Output
	) -> Output {
		map(transform).reduce(.zero, +)
	}
}
