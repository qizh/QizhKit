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
		try wrappedValue
			.map { value in
				FormatterProvider.dateFormatter.string(from: value)
			}
			.encode(to: encoder)
        // try wrappedValue.encode(to: encoder)
    }
}

@propertyWrapper
public struct MandatoryCustomDate<FormatterProvider: DateFormatterProvidable>: Codable, Hashable {
	public var wrappedValue: Date
	
	public init(wrappedValue: Date) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let text = try container.decode(String.self)
		if let date = FormatterProvider.dateFormatter.date(from: text) {
			wrappedValue = date
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "`\(text)` is not a valid date for provided `\(FormatterProvider.self)` formatter"
			)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		try FormatterProvider.dateFormatter
			.string(from: wrappedValue)
			.encode(to: encoder)
		// try wrappedValue.encode(to: encoder)
	}
}

public extension KeyedDecodingContainer {
	func decode <FormatterProvider> (
		_: CustomDate<FormatterProvider>.Type,
		forKey key: Key
	) -> CustomDate<FormatterProvider>
		where FormatterProvider: DateFormatterProvidable
	{
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
		formatter.timeZone = TimeZone(abbreviation: "UTC") // TimeZone(secondsFromGMT: 0)
		// formatter.timeZone = .autoupdatingCurrent
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

/// `2022-04-27T18:19:15.363Z`
public struct ISO8601FullDateTimeFormatterProvider: DateFormatterProvidable {
	public static var dateFormatter: CanFormatDate {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(abbreviation: "UTC") // TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}
}

/// `2020-11-25`
public typealias ISO8601DashedDate = CustomDate<ISO8601DashedDateFormatterProvider>
/// `2020-11-25 10:00:00 +0800`
public typealias ISO8601DashedDateTime = CustomDate<ISO8601DashedDateTimeFormatterProvider>
/// `2020-11-25`
public typealias ISO8601MandatoryDashedDate =
	MandatoryCustomDate<ISO8601DashedDateFormatterProvider>
/// `2020-11-25 10:00:00 +0800`
public typealias ISO8601MandatoryDashedDateTime =
	MandatoryCustomDate<ISO8601DashedDateTimeFormatterProvider>
