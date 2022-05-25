//
//  FloatingPoint+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension FloatingPoint {
	@inlinable var finite: Self? { isFinite ? self : nil }
}

public extension BinaryFloatingPoint where Self: CVarArg {
	@inlinable func toString(fractionDigits: Int) -> String {
		"\(self, f: fractionDigits)"
	}
	
	@inlinable var wholeValueString: String { "\(self, f: 0)" }
	
	@inlinable var s0: String { "\(self, f: 0)" }
	@inlinable var s1: String { "\(self, f: 1)" }
	@inlinable var s2: String { "\(self, f: 2)" }
}

public extension BinaryFloatingPoint {
	/// Rounded using `.toNearestOrAwayFromZero` rule
	@inlinable var int: Int { Int(rounded(.toNearestOrAwayFromZero)) }
	@inlinable func int(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Int {
		Int(rounded(rule))
	}
	
	/// Rounded using `.toNearestOrAwayFromZero` rule
	@inlinable var uint: UInt { UInt(rounded(.toNearestOrAwayFromZero)) }
	@inlinable func uint(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> UInt {
		UInt(rounded(rule))
	}
}

public extension FloatingPoint {
	@inlinable var rounded: Self { rounded() }
	@inlinable var isRounded: Bool { self == rounded }
	
	/// Rounds the double to decimal places value
	@inlinable
	func rounded(dp: UInt) -> Self {
		let divisor: Self = .ten ↗︎ dp
		return (self * divisor).rounded() / divisor
	}
}
