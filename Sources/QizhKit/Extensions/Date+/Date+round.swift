//
//  Date+round.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.12.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//  Based on https://stackoverflow.com/a/19123570/674741
//

import Foundation

extension Date {
	/// To nearest or away from zero
	@inlinable public func rounded(precision: TimeInterval) -> Date {
		rounded(precision: precision, .toNearestOrAwayFromZero)
	}
	
	/// Up
	@inlinable public func ceiled(precision: TimeInterval) -> Date {
		rounded(precision: precision, .up)
	}
	
	/// Down
	@inlinable public func floored(precision: TimeInterval) -> Date {
		rounded(precision: precision, .down)
	}
	
	@inlinable public func rounded(
		precision: TimeInterval,
		_ rule: FloatingPointRoundingRule
	) -> Date {
		Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.rounded(precision: precision, rule))
	}
}

// MARK: Deprecated

extension Date {
	/// To nearest or away from zero
	@available(*, deprecated, renamed: "rounded(precision:)")
	@inlinable public func round(precision: TimeInterval) -> Date {
		round(precision: precision, .toNearestOrAwayFromZero)
	}
	
	/// Up
	@available(*, deprecated, renamed: "ceiled(precision:)")
	@inlinable public func ceil(precision: TimeInterval) -> Date {
		round(precision: precision, .up)
	}
	
	/// Down
	@available(*, deprecated, renamed: "floored(precision:)")
	@inlinable public func floor(precision: TimeInterval) -> Date {
		round(precision: precision, .down)
	}
	
	@available(*, deprecated, renamed: "rounded(precision:_:)")
	@inlinable public func round(
		precision: TimeInterval,
		_ rule: FloatingPointRoundingRule
	) -> Date {
		Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.rounded(precision: precision, rule))
	}
}
