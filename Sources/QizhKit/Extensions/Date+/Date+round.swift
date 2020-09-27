//
//  Date+round.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 26.12.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//  Based on https://stackoverflow.com/a/19123570/674741
//

import Foundation

public extension Date {
	/// To nearest or away from zero
	@inlinable func round(precision: TimeInterval) -> Date {
		round(precision: precision, .toNearestOrAwayFromZero)
	}
	
	/// Up
	@inlinable func ceil(precision: TimeInterval) -> Date {
		round(precision: precision, .up)
	}
	
	/// Down
	@inlinable func floor(precision: TimeInterval) -> Date {
		round(precision: precision, .down)
	}
	
	@inlinable func round(precision: TimeInterval, _ rule: FloatingPointRoundingRule) -> Date {
		Date(timeIntervalSinceReferenceDate: (timeIntervalSinceReferenceDate / precision).rounded(rule) * precision)
	}
}

#if canImport(DateToolsSwift)
import DateToolsSwift

public extension Date {
	/// To nearest or away from zero
	@inlinable func round(precision: TimeChunk) -> Date {
		round(precision: TimeInterval(precision.to(.seconds)), .toNearestOrAwayFromZero)
	}
	
	/// Up
	@inlinable func ceil(precision: TimeChunk) -> Date {
		round(precision: TimeInterval(precision.to(.seconds)), .up)
	}
	
	/// Down
	@inlinable func floor(precision: TimeChunk) -> Date {
		round(precision: TimeInterval(precision.to(.seconds)), .down)
	}
}
#endif
