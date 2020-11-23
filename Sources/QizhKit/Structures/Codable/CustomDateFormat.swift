//
//  CustomDateFormat.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol CanFormatDate {
	func string(from date: Date) -> String
	func date(from string: String) -> Date?
}

public protocol DateFormatterProvidable {
	static var dateFormatter: CanFormatDate { get }
}

@propertyWrapper
public struct CustomDate<FormatterProvider: DateFormatterProvidable>: Codable, Hashable {
    public var wrappedValue: Date?
    
	public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let text = try container.decode(String.self)
        wrappedValue = FormatterProvider.dateFormatter.date(from: text)
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
	
    public enum CustomDateError: Error {
        case general
    }
}

public extension KeyedDecodingContainer {
	func decode<FormatterProvider>(_: CustomDate<FormatterProvider>.Type, forKey key: Key) -> CustomDate<FormatterProvider> where FormatterProvider: DateFormatterProvidable {
        (try? decodeIfPresent(CustomDate<FormatterProvider>.self, forKey: key))
			?? CustomDate<FormatterProvider>(wrappedValue: nil)
    }
}

extension DateFormatter: CanFormatDate { }
extension ISO8601DateFormatter: CanFormatDate { }

public struct ISO8601DashedDateFormatterProvider: DateFormatterProvidable {
	/// "2020-11-25"
	public static var dateFormatter: CanFormatDate {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [
			.withFullDate,
			.withDashSeparatorInDate
		]
		return formatter
	}
}

public struct ISO8601DashedDateTimeFormatterProvider: DateFormatterProvidable {
	/// "2020-11-25 10:00:00 +0800"
	public static var dateFormatter: CanFormatDate {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [
			.withFullDate,
			.withDashSeparatorInDate,
			.withFullTime,
			.withSpaceBetweenDateAndTime,
			.withColonSeparatorInTime,
			.withTimeZone,
		]
		return formatter
	}
}

public typealias ISO8601DashedDate = CustomDate<ISO8601DashedDateFormatterProvider>
public typealias ISO8601DashedDateTime = CustomDate<ISO8601DashedDateTimeFormatterProvider>
