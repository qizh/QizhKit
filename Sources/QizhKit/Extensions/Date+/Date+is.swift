//
//  Date+is.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 22.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Date {
	@inlinable static var now: Date       { Date() }
	@inlinable static var today: Date     { Date() }
	@inlinable static var tomorrow: Date  { .today + 1.daysInterval }
	@inlinable static var yesterday: Date { .today - 1.daysInterval }
	@inlinable static func `in`(_ interval: TimeInterval) -> Date {
		Date(timeIntervalSinceNow: interval)
	}
	
	@inlinable static var startOfToday: Date         { Date.today.start(.day) }
	@inlinable static var startOfTomorrow: Date   { Date.tomorrow.start(.day) }
	@inlinable static var startOfYesterday: Date { Date.yesterday.start(.day) }
	@inlinable static var startOfThisHour: Date        { Date.now.start(.hour) }
	@inlinable static var startOfNextHour: Date { (Date.now + 1.hoursInterval).start(.hour) }
	
	@inlinable static var endOfThisHour: Date { startOfNextHour - 1.secondsInterval }
	@inlinable static var endOfNextHour: Date { endOfThisHour + 1.hoursInterval }
	
	@inlinable static var reference0: Date { Date(timeIntervalSinceReferenceDate: 0) }
	@inlinable static var unix0: Date { Date(timeIntervalSince1970: 0) }
	@inlinable var isReference0: Bool { equals(.reference0) }
	@inlinable var isUnix0:      Bool { equals(.unix0) }
	
	@inlinable var isToday: Bool { Calendar.autoupdatingCurrent.isDateInToday(self) }
	@inlinable var isTomorrow: Bool { Calendar.autoupdatingCurrent.isDateInTomorrow(self) }
	@inlinable var isYesterday: Bool { Calendar.autoupdatingCurrent.isDateInYesterday(self) }
	
	@inlinable var isInFuture: Bool { isLater(than: .today) }
	@inlinable var isInPast: Bool { isEarlier(than: .today) }
	@inlinable var isTodayOrInFuture: Bool { isToday || isInFuture }
	@inlinable var isTodayOrInPast: Bool   { isToday || isInPast }

	@inlinable func    equals(   _ date: Date) -> Bool { compare(date) == .orderedSame }
	@inlinable func   isLater(than date: Date) -> Bool { compare(date) == .orderedDescending }
	@inlinable func isEarlier(than date: Date) -> Bool { compare(date) == .orderedAscending }
	
	@inlinable func start(_ components: Set<Calendar.Component>) -> Date {
		Calendar.auto
			.date(from: Calendar.auto.dateComponents(components, from: self))
			.forceUnwrap(because: .validDateComponents)
	}
	
	@inlinable func end(_ targetComponents: Set<Calendar.Component>) -> Date {
		var components = Calendar.auto.dateComponents(targetComponents, from: self)
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
		return Calendar.auto.date(from: components)
			.forceUnwrap(because: .validDateComponents)
			.addingTimeInterval(-1.thousandth)
	}
	
	@inlinable var secondComponent: Int { Calendar.autoupdatingCurrent.component(.second, from: self) }
	@inlinable var minuteComponent: Int { Calendar.autoupdatingCurrent.component(.minute, from: self) }
	@inlinable var   hourComponent: Int { Calendar.autoupdatingCurrent.component(.hour, from: self) }
	@inlinable var    dayComponent: Int { Calendar.autoupdatingCurrent.component(.day, from: self) }
	@inlinable var  monthComponent: Int { Calendar.autoupdatingCurrent.component(.month, from: self) }
	@inlinable var   yearComponent: Int { Calendar.autoupdatingCurrent.component(.year, from: self) }
	
	@inlinable var minuteStart: Date { start(.minute) }
	@inlinable var   hourStart: Date { start(.hour)   }
	@inlinable var    dayStart: Date { start(.day)    }
	@inlinable var  monthStart: Date { start(.month)  }
	@inlinable var   yearStart: Date { start(.year)   }
	
	@inlinable var minuteEnd: Date { end(.minute) }
	@inlinable var   hourEnd: Date { end(.hour)   }
	@inlinable var    dayEnd: Date { end(.day)    }
	@inlinable var  monthEnd: Date { end(.month)  }
	@inlinable var   yearEnd: Date { end(.year)   }
	
	@inlinable var isMinuteStart: Bool { compare(minuteStart) == .orderedSame }
	@inlinable var   isHourStart: Bool { compare(hourStart)   == .orderedSame }
	@inlinable var    isDayStart: Bool { compare(dayStart) 	  == .orderedSame }
	@inlinable var  isMonthStart: Bool { compare(monthStart)  == .orderedSame }
	@inlinable var   isYearStart: Bool { compare(yearStart)   == .orderedSame }
	
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
}

public extension Set where Element == Calendar.Component {
	static let minute: Set<Calendar.Component> = [.era, .year, .month, .day, .hour, .minute]
	static let hour:   Set<Calendar.Component> = [.era, .year, .month, .day, .hour]
	static let day:    Set<Calendar.Component> = [.era, .year, .month, .day]
	static let month:  Set<Calendar.Component> = [.era, .year, .month]
	static let year:   Set<Calendar.Component> = [.era, .year]
}

public extension Calendar {
	@inlinable static var auto: Calendar { .autoupdatingCurrent }
}

public extension Date {
	@inlinable var timeIntervalToday: TimeInterval { timeIntervalSinceDayStart }
	@inlinable var timeIntervalSinceDayStart: TimeInterval {
		timeIntervalSince(dayStart)
	}
}

public extension Date {
	@inlinable static var endOfToday:     Date { Date    .today.end(.day) }
	@inlinable static var endOfTomorrow:  Date { Date .tomorrow.end(.day) }
	@inlinable static var endOfYesterday: Date { Date.yesterday.end(.day) }
}
