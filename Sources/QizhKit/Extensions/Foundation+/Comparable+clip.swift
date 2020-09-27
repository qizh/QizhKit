//
//  Comparable+clip.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Comparable {
	func clipped(from f: Self, to t: Self) -> Self {
		switch self {
		case let v where v < f: return f
		case let v where v > t: return t
		default: 				return self
		}
	}
}

public extension Strideable {
	func clipped(_ range: ClosedRange<Self>) -> Self {
		switch self {
		case let v where v < range.lowerBound: 	return range.lowerBound
		case let v where v > range.upperBound: 	return range.upperBound
		default: 								return self
		}
	}
}

public extension FloatingPoint {
	var zeroOneClipped: Self {
		switch self {
		case let v where v < .zero: return .zero
		case let v where v > .one: 	return .one
		default: 					return self
		}
	}
	
	var oneMinusOneClipped: Self {
		switch self {
		case let v where v < .minusOne: return .minusOne
		case let v where v > .one: 		return .one
		default: 						return self
		}
	}
}

public extension Numeric where Self: Comparable {
	func clippedFromZero(to t: Self) -> Self {
		switch self {
		case let v where v < .zero: return .zero
		case let v where v > t: 	return t
		default: 					return self
		}
	}
	
	var hundredClipped: Self {
		switch self {
		case let v where v < 0: 	return 0
		case let v where v > 100: 	return 100
		default: 					return self
		}
	}
}

public extension SignedNumeric where Self: Comparable {
	@inlinable func clippedAboveZero() -> Self {
		isNegative ? .zero : self
	}
	
	@inlinable func clippedBelowZero() -> Self {
		isPositive ? .zero : self
	}
}
