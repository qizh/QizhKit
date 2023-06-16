//
//  Date+is.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 22.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Date {
	@available(iOS, obsoleted: 15, message: "Implemented in Foundation")
	@_disfavoredOverload
	@inlinable static var now: Date       { Date() }
	@available(*, deprecated, renamed: "now", message: "Use Date.now instead")
	@inlinable static var today: Date     { Date() }
	@inlinable static var tomorrow: Date  { .now + 1.daysInterval }
	@inlinable static var yesterday: Date { .now - 1.daysInterval }
	@inlinable static func `in`(_ interval: TimeInterval) -> Date {
		Date(timeIntervalSinceNow: interval)
	}
	
	@inlinable static var reference0: Date { Date(timeIntervalSinceReferenceDate: 0) }
	@inlinable static var unix0: Date { Date(timeIntervalSince1970: 0) }
	@inlinable var isReference0: Bool { equals(.reference0) }
	@inlinable var isUnix0:      Bool { equals(.unix0) }
	
	@inlinable var isToday: Bool { Calendar.auto.isDateInToday(self) }
	@inlinable var isTomorrow: Bool { Calendar.auto.isDateInTomorrow(self) }
	@inlinable var isYesterday: Bool { Calendar.auto.isDateInYesterday(self) }
	
	@inlinable var isTodayUTC: Bool { Calendar.utc.isDateInToday(self) }
	@inlinable var isTomorrowUTC: Bool { Calendar.utc.isDateInTomorrow(self) }
	@inlinable var isYesterdayUTC: Bool { Calendar.utc.isDateInYesterday(self) }
	
	@inlinable var isInFuture: Bool { isLater(than: .now) }
	@inlinable var isInPast: Bool { isEarlier(than: .now) }
	@inlinable var isTodayOrInFuture: Bool { isToday || isInFuture }
	@inlinable var isTodayOrInPast: Bool   { isToday || isInPast }
	
	@inlinable var isTodayOrInFutureUTC: Bool { isTodayUTC || isInFuture }
	@inlinable var isTodayOrInPastUTC: Bool   { isTodayUTC || isInPast }
	
	@inlinable func    equals(   _ date: Date) -> Bool { compare(date) == .orderedSame }
	@inlinable func   isLater(than date: Date) -> Bool { compare(date) == .orderedDescending }
	@inlinable func isEarlier(than date: Date) -> Bool { compare(date) == .orderedAscending }
	
	@inlinable var secondComponent: Int { Calendar.auto.component(.second, from: self) }
	@inlinable var minuteComponent: Int { Calendar.auto.component(.minute, from: self) }
	@inlinable var   hourComponent: Int { Calendar.auto.component(.hour, from: self) }
	@inlinable var    dayComponent: Int { Calendar.auto.component(.day, from: self) }
	@inlinable var  monthComponent: Int { Calendar.auto.component(.month, from: self) }
	@inlinable var   yearComponent: Int { Calendar.auto.component(.year, from: self) }
	
	@inlinable var secondComponentUTC: Int { Calendar.utc.component(.second, from: self) }
	@inlinable var minuteComponentUTC: Int { Calendar.utc.component(.minute, from: self) }
	@inlinable var   hourComponentUTC: Int { Calendar.utc.component(.hour, from: self) }
	@inlinable var    dayComponentUTC: Int { Calendar.utc.component(.day, from: self) }
	@inlinable var  monthComponentUTC: Int { Calendar.utc.component(.month, from: self) }
	@inlinable var   yearComponentUTC: Int { Calendar.utc.component(.year, from: self) }
	
	@inlinable func isSameMinute(as other: Date) -> Bool { minuteStart.equals(other.minuteStart) }
	@inlinable func isSameHour  (as other: Date) -> Bool {   hourStart.equals(other  .hourStart) }
	@inlinable func isSameDay   (as other: Date) -> Bool {    dayStart.equals(other   .dayStart) }
	@inlinable func isSameMonth (as other: Date) -> Bool {  monthStart.equals(other .monthStart) }
	@inlinable func isSameYear  (as other: Date) -> Bool {   yearStart.equals(other  .yearStart) }
	
	func distance(in component: Calendar.Component, to date: Date = .now) -> Int {
		Calendar.autoupdatingCurrent
			.dateComponents([component], from: self, to: date)
			.value(for: component) ?? .zero
	}
}

public extension OptionalForcedUnwrapAssumption {
	static let validDateComponents = Self("Made out of valid date components")
}

public extension Int {
	@inlinable var secondsInterval: TimeInterval { TimeInterval(self) }
	@inlinable var minutesInterval: TimeInterval { TimeInterval.minute * double }
	@inlinable var   hoursInterval: TimeInterval { TimeInterval.hour * double }
	@inlinable var    daysInterval: TimeInterval { TimeInterval.day * double }
	@inlinable var   weeksInterval: TimeInterval { TimeInterval.week * double }
}

public extension Set where Element == Calendar.Component {
	static let minute: Set<Calendar.Component> = [.era, .year, .month, .day, .hour, .minute]
	static let hour:   Set<Calendar.Component> = [.era, .year, .month, .day, .hour]
	static let day:    Set<Calendar.Component> = [.era, .year, .month, .day]
	static let month:  Set<Calendar.Component> = [.era, .year, .month]
	static let year:   Set<Calendar.Component> = [.era, .year]
}

public extension Date {
	@inlinable var timeIntervalToday: TimeInterval { timeIntervalSinceDayStart }
	@inlinable var timeIntervalSinceDayStart: TimeInterval {
		timeIntervalSince(dayStart)
	}
	
	@inlinable var timeIntervalTodayUTC: TimeInterval { timeIntervalSinceDayStartUTC }
	@inlinable var timeIntervalSinceDayStartUTC: TimeInterval {
		timeIntervalSince(dayStartUTC)
	}
}

// MARK: Start

public extension Date {
	@inlinable func start(
		_ components: Set<Calendar.Component>,
		calendar: Calendar = .autoupdatingCurrent
	) -> Date {
		calendar
			.date(from: calendar.dateComponents(components, from: self))
			.forceUnwrap(because: .validDateComponents)
	}
	
	// MARK: > Properties
	
	@inlinable var minuteStart: Date { start(.minute) }
	@inlinable var   hourStart: Date { start(.hour)   }
	@inlinable var    dayStart: Date { start(.day)    }
	@inlinable var  monthStart: Date { start(.month)  }
	@inlinable var   yearStart: Date { start(.year)   }
	
	@inlinable var    dayStartUTC: Date { start(.day, calendar: .utc)    }
	@inlinable var  monthStartUTC: Date { start(.month, calendar: .utc)  }
	@inlinable var   yearStartUTC: Date { start(.year, calendar: .utc)   }
	
	// MARK: > static
	
	@inlinable static var startOfToday: Date           { Date.now.start(.day) }
	@inlinable static var startOfTomorrow: Date   { Date.tomorrow.start(.day) }
	@inlinable static var startOfYesterday: Date { Date.yesterday.start(.day) }
	@inlinable static var startOfThisHour: Date        { Date.now.start(.hour) }
	@inlinable static var startOfNextHour: Date { (Date.now + 1.hoursInterval).start(.hour) }
	
	@inlinable static var startOfTodayUTC: Date           { Date.now.start(.day, calendar: .utc) }
	@inlinable static var startOfTomorrowUTC: Date   { Date.tomorrow.start(.day, calendar: .utc) }
	@inlinable static var startOfYesterdayUTC: Date { Date.yesterday.start(.day, calendar: .utc) }
	
	// MARK: > is
	
	@inlinable var isMinuteStart: Bool { compare(minuteStart) == .orderedSame }
	@inlinable var   isHourStart: Bool { compare(hourStart)   == .orderedSame }
	@inlinable var    isDayStart: Bool { compare(dayStart) 	  == .orderedSame }
	@inlinable var  isMonthStart: Bool { compare(monthStart)  == .orderedSame }
	@inlinable var   isYearStart: Bool { compare(yearStart)   == .orderedSame }
	
	@inlinable var    isDayStartUTC: Bool { compare(dayStartUTC) 	== .orderedSame }
	@inlinable var  isMonthStartUTC: Bool { compare(monthStartUTC) 	== .orderedSame }
	@inlinable var   isYearStartUTC: Bool { compare(yearStartUTC) 	== .orderedSame }
}

// MARK: End

public extension Date {
	@inlinable func end(
		_ targetComponents: Set<Calendar.Component>,
		calendar: Calendar = .autoupdatingCurrent
	) -> Date {
		var components = calendar.dateComponents(targetComponents, from: self)
		if targetComponents.contains(.minute) {
			components.setValue(components.minute.orZero.next, for: .minute)
		} else if targetComponents.contains(.hour) {
			components.setValue(components.hour.orZero.next, for: .hour)
		} else if targetComponents.contains(.day) {
			components.setValue(components.day.orZero.next, for: .day)
		} else if targetComponents.contains(.month) {
			components.setValue(components.month.orZero.next, for: .month)
		} else if targetComponents.contains(.year) {
			components.setValue(components.year.orZero.next, for: .year)
		}
		return calendar
			.date(from: components)
			.forceUnwrap(because: .validDateComponents)
			.addingTimeInterval(-1.thousandth)
	}
	
	// MARK: > Properties
	
	@inlinable var minuteEnd: Date { end(.minute) }
	@inlinable var   hourEnd: Date { end(.hour)   }
	@inlinable var    dayEnd: Date { end(.day)    }
	@inlinable var  monthEnd: Date { end(.month)  }
	@inlinable var   yearEnd: Date { end(.year)   }
	
	// MARK: > static
	
	@inlinable static var endOfToday:     Date { Date      .now.end(.day) }
	@inlinable static var endOfTomorrow:  Date { Date .tomorrow.end(.day) }
	@inlinable static var endOfYesterday: Date { Date.yesterday.end(.day) }
	@inlinable static var endOfThisHour: Date { startOfNextHour - 1.secondsInterval }
	@inlinable static var endOfNextHour: Date { endOfThisHour + 1.hoursInterval }
}

// MARK: Convert Timezone

extension Date {
	/// Keeps the date and time, but changes the timezone.
	/// - Warning: It's not converting to another timezone
	/// - Parameters:
	///   - sourceTimeZone: Current date's ``TimeZone``, UTC by default
	///   - targetTimeZone: Target ``TimeZone``, ``current`` by default
	/// - Returns: Changed ``Date``
	@inlinable public func withTimeZoneChanged(
		from sourceTimeZone: TimeZone = .utc,
		to targetTimeZone: TimeZone = .current
	) -> Date {
		self.addingTimeInterval(
			TimeInterval(
				  targetTimeZone.secondsFromGMT()
				- sourceTimeZone.secondsFromGMT()
			)
		)
	}
}
