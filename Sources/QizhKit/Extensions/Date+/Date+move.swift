//
//  Date+move.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 28.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Date {
	func movedDay(to target: Date) -> Date {
		var targetDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: target)
		let currentTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
		targetDayComponents.hour = currentTimeComponents.hour
		targetDayComponents.minute = currentTimeComponents.minute
		targetDayComponents.second = currentTimeComponents.second
		return Calendar.current.date(from: targetDayComponents) ?? self
	}
	
	@inlinable mutating func moveDay(to target: Date) {
		self = self.movedDay(to: target)
	}
}

public extension Date {
	@inlinable func adding(_ value: Double) -> Date {
		self + TimeInterval(value)
	}
}

public extension Date {
	/// Changes time while keeping the day
	/// - Parameter value: `Double` value of `TimeInterval` since the beginning of the day
	/// - Returns: `Date` with different time in the same day
	/// - Requires: `value` should be within a day range.
	/// Otherwise a truncating remainder dividing by day will be used.
	@inlinable func time(_ value: Double) -> Date {
		with(time: value)
//		dayStart + TimeInterval(value.truncatingRemainder(dividingBy: TimeInterval.day))
	}
	
	/// Creates another `Date` by setting provided time since the beginning of the day
	/// - Parameter time: `TimeInterval` since the beginning of the day
	/// - Requires: `time` should be within a day range.
	/// Otherwise a truncating remainder dividing by day will be used.
	/// - Returns: Same day `Date` with provided time
	@inlinable func with(time: TimeInterval) -> Date {
		dayStart + time.withinDay
	}
	
	/// Updating Date by setting provided time since the beginning of the day
	/// - Parameter time: `TimeInterval` since the beginning of the day
	/// - Requires: `time` should be within a day range.
	/// Otherwise a truncating remainder dividing by day will be used.
	@inlinable mutating func set(time: TimeInterval) {
		self = dayStart + time.withinDay
	}

}
