//
//  AdditiveArithmetic+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Zero

extension AdditiveArithmetic {
	@inlinable public var isZero: Bool { self == .zero }
	@inlinable public var isNotZero: Bool { self != .zero }
	@inlinable public var nonZero: Self? { isZero ? nil : self }
	
	@inlinable public var bool: Bool { isNotZero }
}

extension Collection {
	@inlinable
	public func sum <Output: AdditiveArithmetic> (
		of transform: (Element) -> Output
	) -> Output {
		map(transform).reduce(.zero, +)
	}
}

extension Collection where Element: AdditiveArithmetic {
	@inlinable
	public func elementsSum() -> Element {
		reduce(.zero, +)
	}
}
