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
	
	public func asTimeRange(from date: Date) -> Range<TimeInterval> {
			lowerBound.timeIntervalSince(date)
		..< upperBound.timeIntervalSince(date)
	}
}

extension Range where Bound == TimeInterval {
	public var duration: TimeInterval {
		upperBound - lowerBound
	}
	
	public func asDateRange(from date: Date) -> Range<Date> {
			date.addingTimeInterval(lowerBound)
		..< date.addingTimeInterval(upperBound)
	}
}
