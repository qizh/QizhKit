//
//  SignedNumeric+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Positive / Negative

public extension SignedNumeric where Self: Comparable {
	var signum: Self {
		switch self {
		case let p where p > .zero: return .one
		case let n where n < .zero: return .minusOne
		case .zero: fallthrough
		default: return .zero
		}
	}
	
	@inlinable var sign: NumericSign { NumericSign(of: self) }
	@inlinable var absolute: Self.Magnitude { magnitude }
	
	@inlinable var positive: Self? { isPositive ? self : nil }
	@inlinable var negative: Self? { isNegative ? self : nil }
	@inlinable var nonPositive: Self? { isPositive ? nil : self }
	@inlinable var nonNegative: Self? { isNegative ? nil : self }
	@inlinable var negated: Self? { -self }
	@inlinable var isPositive    : Bool { self > 0 }
	@inlinable var isNotPositive : Bool { self <= 0 }
	@inlinable var isNegative    : Bool { self < 0 }
	@inlinable var isNotNegative : Bool { self >= 0 }
}

public enum NumericSign: Int, CaseIterable, Hashable, Comparable {
	case minus = -1
	case none = 0
	case plus = 1
	
	public init<SN: SignedNumeric>(of sn: SN) {
		switch sn.magnitude {
		case let p where p > .zero: self = .plus
		case let n where n < .zero: self = .minus
		case .zero: fallthrough
		default: self = .none
		}
	}
	
	@inlinable public static func < (l: NumericSign, r: NumericSign) -> Bool {
		l.rawValue < r.rawValue
	}
}

/*
public extension FloatingPoint {
	@inlinable var isPositive: Bool { self.sign == .plus }
	@inlinable var isNegative: Bool { self.sign == .minus }
	
	var signum: Self {
		if magnitude.isZero { return .zero }
		return self / magnitude
	}
}
*/

/*
public extension BinaryInteger {
	@inlinable var isPositive: Bool { self.signum() ==  1 }
	@inlinable var isNegative: Bool { self.signum() == -1 }
}
*/
