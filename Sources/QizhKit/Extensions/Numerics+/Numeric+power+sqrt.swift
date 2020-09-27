//
//  Numeric+power.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

precedencegroup Exponentiative {
    higherThan: MultiplicationPrecedence
    associativity: right
}

prefix operator √
infix operator ↗︎ : Exponentiative

public extension Numeric {
	func powered(by power: UInt) -> Self {
		if power.isZero { return .one }
		if self as? Int == 2 {
			return (2 << Int(power - 1)) as! Self
		}
		return repeatElement(self, count: Int(power)).reduce(.one, *)
	}
	
	@inlinable static func ↗︎ (base: Self, power: UInt) -> Self {
		base.powered(by: power)
	}
	
	@inlinable var ²: Self { self ↗︎ 2 }
	@inlinable var ³: Self { self ↗︎ 3 }
}

public extension BinaryInteger {
	@inlinable static prefix func √ (value: Self) -> Double { Double(value).squareRoot() }
}

public extension FloatingPoint {
	@inlinable static prefix func √ (value: Self) -> Self { value.squareRoot() }
}
