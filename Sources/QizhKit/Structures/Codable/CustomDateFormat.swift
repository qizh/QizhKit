//
//  CustomDateFormat.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Protocol

public protocol CanFormatDate {
	func string(from date: Date) -> String
	func date(from string: String) -> Date?
}

public protocol DateFormatterProvidable {
	static var dateFormatter: CanFormatDate { get }
}

extension DateFormatter: CanFormatDate { }
extension ISO8601DateFormatter: CanFormatDate { }

@available(iOS 15.0, *)
extension Date.ISO8601FormatStyle: CanFormatDate {
	@inlinable public func string(from date: Date) -> String {
		date.formatted(self)
	}
	
	@inlinable public func date(from string: String) -> Date? {
		try? self.parse(string)
	}
}

// MARK: Property Wrappers

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

// MARK: Decoding Container +

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

// MARK: Format Providers

/// "2020-11-25" in current TimeZone
public struct ISO8601DashedDateFormatterProvider: DateFormatterProvidable {
	/// "2020-11-25" in current TimeZone
	@inlinable public static var dateFormatter: CanFormatDate {
		if #available(iOS 15.0, *) {
			return Date.ISO8601FormatStyle(timeZone: .current)
				.dateSeparator(.dash)
				.year().month().day()
		} else {
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [
				.withFullDate,
				.withDashSeparatorInDate
			]
			formatter.timeZone = .current
			// TimeZone(abbreviation: "UTC")
			// TimeZone(secondsFromGMT: 0)
			// .autoupdatingCurrent
			return formatter
		}
	}
}

/// "2020-11-25 10:00:00 +0800", in current TimeZone by default
public struct ISO8601DashedDateTimeFormatterProvider: DateFormatterProvidable {
	/// "2020-11-25 10:00:00 +0800", in current TimeZone by default
	public static var dateFormatter: CanFormatDate {
		if #available(iOS 15.0, *) {
			return Date.ISO8601FormatStyle(timeZone: .current)
				.year().month().day()
				.time(includingFractionalSeconds: false)
				.timeZone(separator: .omitted)
				.dateSeparator(.dash)
				.dateTimeSeparator(.space)
		} else {
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [
				.withFullDate,
				.withDashSeparatorInDate,
				.withFullTime,
				.withSpaceBetweenDateAndTime,
				.withColonSeparatorInTime,
				.withTimeZone,
			]
			formatter.timeZone = .current
			return formatter
		}
	}
}

// MARK: > UTC

/// "2020-11-25" in UTC TimeZone
public struct ISO8601DashedDateFormatterProviderUTC: DateFormatterProvidable {
	/// "2020-11-25" in UTC TimeZone
	@inlinable public static var dateFormatter: CanFormatDate {
		if #available(iOS 15.0, *) {
			return Date.ISO8601FormatStyle(timeZone: .utc)
				.dateSeparator(.dash)
				.year().month().day()
		} else {
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [
				.withFullDate,
				.withDashSeparatorInDate
			]
			formatter.timeZone = .utc
			// TimeZone(abbreviation: "UTC")
			// TimeZone(secondsFromGMT: 0)
			// .autoupdatingCurrent
			return formatter
		}
	}
}

/// "2020-11-25 10:00:00 +0800", in UTC TimeZone by default
public struct ISO8601DashedDateTimeFormatterProviderUTC: DateFormatterProvidable {
	/// "2020-11-25 10:00:00 +0800", in UTC TimeZone by default
	public static var dateFormatter: CanFormatDate {
		if #available(iOS 15.0, *) {
			return Date.ISO8601FormatStyle(timeZone: .utc)
				.year().month().day()
				.time(includingFractionalSeconds: false)
				.timeZone(separator: .omitted)
				.dateSeparator(.dash)
				.dateTimeSeparator(.space)
		} else {
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
}

// MARK: > Other

/// `2022-04-27T18:19:15.363Z`
public struct ISO8601FullDateTimeFormatterProvider: DateFormatterProvidable {
	public static var dateFormatter: CanFormatDate {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = .utc // TimeZone(abbreviation: "UTC") // TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}
}

// MARK: Typealiases

/// `2020-11-25` in current
public typealias ISO8601DashedDate = CustomDate<ISO8601DashedDateFormatterProvider>
/// `2020-11-25 10:00:00 +0800`, in current TimeZone by default
public typealias ISO8601DashedDateTime = CustomDate<ISO8601DashedDateTimeFormatterProvider>
/// `2020-11-25` in current
public typealias ISO8601MandatoryDashedDate =
	MandatoryCustomDate<ISO8601DashedDateFormatterProvider>
/// `2020-11-25 10:00:00 +0800`, in current TimeZone by default
public typealias ISO8601MandatoryDashedDateTime =
	MandatoryCustomDate<ISO8601DashedDateTimeFormatterProvider>

/// `2020-11-25` in UTC
public typealias ISO8601DashedDateUTC = CustomDate<ISO8601DashedDateFormatterProviderUTC>
/// `2020-11-25 10:00:00 +0800`, in UTC TimeZone by default
public typealias ISO8601DashedDateTimeUTC = CustomDate<ISO8601DashedDateTimeFormatterProviderUTC>
/// `2020-11-25` in UTC
public typealias ISO8601MandatoryDashedDateUTC =
	MandatoryCustomDate<ISO8601DashedDateFormatterProviderUTC>
/// `2020-11-25 10:00:00 +0800`, in UTC TimeZone by default
public typealias ISO8601MandatoryDashedDateTimeUTC =
	MandatoryCustomDate<ISO8601DashedDateTimeFormatterProviderUTC>
