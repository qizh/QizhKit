//
//  TimeInterval+values.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension TimeInterval {
	/// Amount of seconds in this interval
	@inlinable var seconds: Int {
		truncatingRemainder(dividingBy: .sixty).int
	}
	
	/// Amount of minutes in this interval
	@inlinable var minutes: Int {
		(self / .sixty).truncatingRemainder(dividingBy: .sixty).int
	}
	
	/// Amount of hours in this interval
	@inlinable var hours: Int {
		(self / Self.sixty.²).int
	}
	
	/// One minute interval
	static let minute: TimeInterval = .sixty
	
	/// One hour interval
	static let hour: TimeInterval = .sixty²
	
	/// One day (24 hours) interval
	static let day: TimeInterval = .twentyFour * hour
	
	/// One week (7 days) interval
	static let week: TimeInterval = .seven * day
	
	/// One month (30.44 days) interval
	static let month: TimeInterval = 30.44 * day
	
	/// One quarter (91.31 days) interval
	static let quarter: TimeInterval = 91.31 * day

	/// One year (365.25 days) interval
	static let year: TimeInterval = 365.25 * day
	
	/// Creates an interval by leaving only remainder
	/// after dividing current interval by day
	/// - Invariant: Makes no change in case
	/// the current interval fits in a day
	@inlinable var withinDay: TimeInterval {
		truncatingRemainder(dividingBy: .day)
	}
	
	/// Date made by adding this interval
	/// to a beginning of the current day
	@inlinable var today: Date {
		Date.startOfToday.with(time: self)
	}
	
	/// Date made by adding this interval
	/// to a beginning of the provided date's day
	@inlinable func of(_ date: Date) -> Date {
		date.dayStart.with(time: self)
	}
}
