//
//  TimeInterval+round.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.06.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension TimeInterval {
	/// To nearest or away from zero
	@inlinable public func rounded(
		precision: TimeInterval
	) -> TimeInterval {
		rounded(precision: precision, .toNearestOrAwayFromZero)
	}
	
	/// Up
	@inlinable public func ceiled(precision: TimeInterval) -> TimeInterval {
		rounded(precision: precision, .up)
	}
	
	/// Down
	@inlinable public func floored(precision: TimeInterval) -> TimeInterval {
		rounded(precision: precision, .down)
	}
	
	@inlinable public func rounded(
		precision: TimeInterval,
		_ rule: FloatingPointRoundingRule
	) -> TimeInterval {
		(self / precision).rounded(rule) * precision
	}
}
