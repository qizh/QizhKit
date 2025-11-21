//
//  TimeInterval+as.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.02.2023.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

public import Foundation

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
	
	///  Converts this `TimeInterval` to a `CGFloat`.
	///
	///  - Returns: The current value cast as `CGFloat`.
	///  - Discussion:
	///    Use this property when you need a `CGFloat` representation of a time
	///    interval (for example, in animation durations or geometric calculations).
	@inlinable public var cg: CGFloat {
		CGFloat(self)
	}
}

extension TimeInterval {
	public func asDuration() -> Duration {
		Duration.seconds(self)
	}
}
