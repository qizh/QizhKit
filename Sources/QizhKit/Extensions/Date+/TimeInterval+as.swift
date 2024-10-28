//
//  TimeInterval+as.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.02.2023.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: TimeInterval + as

extension TimeInterval {
	@available(*, deprecated, renamed: "asDateRangeAfter(_:)", message: "This method name better describes the result")
	public func asDateRange(from date: Date = .now) -> Range<Date> {
		date ..< date.addingTimeInterval(self)
	}
	
	public func asDateRangeAfter(_ date: Date = .now) -> Range<Date> {
		date ..< date.addingTimeInterval(self)
	}
	
	public func asDateRangeBefore(_ date: Date = .now) -> Range<Date> {
		date.addingTimeInterval(-self) ..< date
	}
	
	@inlinable public var asDateRangeAfterNow: Range<Date> {
		asDateRangeAfter(.now)
	}
	
	@inlinable public var asDateRangeBeforeNow: Range<Date> {
		asDateRangeBefore(.now)
	}
}

extension TimeInterval {
	public func asDuration() -> Duration {
		Duration.seconds(self)
	}
}
