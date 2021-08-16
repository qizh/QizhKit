//
//  Binding+convert.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Binding where Value == TimeInterval {
	func asDate() -> Binding<Date> {
		Binding<Date> {
			Date.reference0.time(wrappedValue)
		} set: { date in
			wrappedValue = date.timeIntervalToday
		}
	}
}

public extension Binding where Value == Date {
	func asTimeInterval() -> Binding<TimeInterval> {
		Binding<TimeInterval> {
			wrappedValue.timeIntervalToday
		} set: { timeInterval in
			wrappedValue = wrappedValue.time(timeInterval)
		}
	}
	
	static func combine(
		date: Binding<Date>,
		time: Binding<TimeInterval>
	) -> Binding<Date> {
		Binding<Date> {
			date.wrappedValue.time(time.wrappedValue)
		} set: { combined in
			date.wrappedValue = combined.dayStart
			time.wrappedValue = combined.timeIntervalToday
		}
	}
	
	func combined(with time: Binding<TimeInterval>) -> Binding<Date> {
		Binding<Date> {
			self.wrappedValue.time(time.wrappedValue)
		} set: { combined in
			self.wrappedValue = combined.dayStart
			time.wrappedValue = combined.timeIntervalToday
		}
	}
}

public extension Binding where Value == String {
	func asOptional(default defaultValue: String = .empty) -> Binding<String?> {
		Binding<String?> {
			wrappedValue == defaultValue ? .none : wrappedValue
		} set: { value in
			wrappedValue = value ?? defaultValue
		}
	}
}
