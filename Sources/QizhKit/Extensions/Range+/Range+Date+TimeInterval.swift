//
//  Range+Date+TimeInterval.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.06.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Range where Bound == Date {
	public var duration: TimeInterval {
		upperBound.timeIntervalSince(lowerBound)
	}
	
	/// With manual reference date, use `.dayStart` for your input
	/// - Parameter date: Reference date to calculate distance from
	/// - Returns: Range of ``TimeInterval``s since ``date``
	public func asTimeRange(from date: Date) -> Range<TimeInterval> {
			lowerBound.timeIntervalSince(date)
		..< upperBound.timeIntervalSince(date)
	}
	
	/// With automatic reference date
	/// - Returns: Range of ``TimeInterval``s from ``lowerBound``'s ``Date/dayStart``
	public func asTimeRange() -> Range<TimeInterval> {
		asTimeRange(from: lowerBound.dayStart)
	}
}

extension Range where Bound == TimeInterval {
	public var duration: TimeInterval {
		upperBound - lowerBound
	}
	
	/// With manual reference date, use `.dayStart` for your input
	public func asDateRange(from date: Date) -> Range<Date> {
			date.addingTimeInterval(lowerBound)
		..< date.addingTimeInterval(upperBound)
	}
	
	/// With automatic reference date – start of today is used
	public func asDateRange() -> Range<Date> {
		asDateRange(from: .now.dayStart)
	}
}
