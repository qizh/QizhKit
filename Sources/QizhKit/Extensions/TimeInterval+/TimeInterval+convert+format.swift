//
//  TimeInterval+convert+format.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension TimeInterval {
	/// Returns a `Measurement<UnitDuration>` representing the receiver
	/// as a measurement in seconds.
	///
	/// This computed property creates a `Measurement` instance
	/// with the value set to the `TimeInterval` (which is expressed in seconds)
	/// and the unit set to `.seconds`.
	///
	/// This is useful when you want to use `TimeInterval` values with APIs
	/// or formatting styles that require the `Measurement<UnitDuration>` type.
	///
	/// - Returns: A `Measurement<UnitDuration>` with the value of `self` in seconds.
	///
	/// # Example
	/// ```swift
	/// let interval: TimeInterval = 120
	/// let measurement = interval.asMeasurement
	/// // measurement is Measurement(value: 120, unit: .seconds)
	/// ```
	@inlinable public var asMeasurement: Measurement<UnitDuration> {
		Measurement(value: self, unit: .seconds)
	}
}

extension TimeInterval {
	/// A format style for formatting `TimeInterval` values
	/// as measurements of duration in seconds.
	///
	/// `SecondsMeasurementFormatStyle` enables the conversion of a `TimeInterval`
	/// (which is always expressed in seconds) into a localized string representation,
	/// using the `Measurement` formatting APIs available on Apple platforms.
	/// This is especially useful when you want to display time intervals to users
	/// in a customizable format, including options for unit width, measurement usage intent,
	/// locale, and numeric formatting.
	///
	/// The format style allows you to control:
	/// - The width of the unit display
	/// 	(e.g., `.wide` for "seconds", `.abbreviated` for "sec", `.narrow` for "s").
	/// - The intended usage of the measurement
	/// 	(e.g., `.general`, or context-specific usages).
	/// - The numeric formatting applied to the value
	/// 	(e.g., precision, grouping, etc.).
	/// - The locale used for formatting the output string.
	///
	/// You can use this format style directly to format `TimeInterval` values,
	/// or via a convenience static function
	/// `timeIntervalMeasurement(width:usage:numberFormatStyle:locale:)`.
	///
	/// ### Example
	/// ```swift
	/// let interval: TimeInterval = 90
	/// let style = TimeInterval.SecondsMeasurementFormatStyle(
	///     width: .wide,
	///     usage: .general,
	///     numberFormatStyle: .number.precision(.significantDigits(2)),
	///     locale: .current
	/// )
	/// let formatted = style.format(interval)
	/// // formatted might be "1.5 minutes" or "90 seconds",
	/// // depending on localization and width
	/// ```
	///
	/// - Note: This format style is `Sendable` and can be safely used in concurrent code.
	/// - SeeAlso: `Measurement<UnitDuration>.FormatStyle`, `FormatStyle`
	public struct SecondsMeasurementFormatStyle: FormatStyle, Sendable {
		public let unitSymbol: String
		public let width: Measurement<UnitDuration>.FormatStyle.UnitWidth
		public let usage: MeasurementFormatUnitUsage<UnitDuration>
		public let numberFormatStyle: FloatingPointFormatStyle<Double>?
		public let locale: Locale
		
		/// Creates a new `SecondsMeasurementFormatStyle`
		/// for formatting a `TimeInterval` as a measurement of duration.
		///
		/// - Parameters:
		///   - width: The unit width to use for formatting, such as
		///   			`.wide` (e.g., "seconds"),
		///   			`.abbreviated` (e.g., "sec"), or
		///   			`.narrow` (e.g., "s").
		///   - usage: The intended usage context of the measurement unit,
		///   			determining how durations are presented
		///   			(e.g., `.general` or context-specific).
		///   			Defaults to `.general`.
		///   - numberFormatStyle: The numeric format style to apply to the value,
		///   			such as controlling precision or grouping.
		///   			If `nil`, uses the system default.
		///   - locale: The `Locale` to use for localization.
		///   			Defaults to `.autoupdatingCurrent`.
		///
		/// Use this initializer to configure how `TimeInterval` values
		/// will be converted to localized strings, providing options for unit width,
		/// usage intent, numeric formatting, and localization.
		/// This supports display of time durations tailored to your application's needs
		/// and the user's preferences.
		public init(
			in unit: UnitDuration,
			width: Measurement<UnitDuration>.FormatStyle.UnitWidth,
			usage: MeasurementFormatUnitUsage<UnitDuration> = .general,
			numberFormatStyle: FloatingPointFormatStyle<Double>? = nil,
			locale: Locale = .autoupdatingCurrent
		) {
			self.unitSymbol = unit.symbol
			self.width = width
			self.usage = usage
			self.numberFormatStyle = numberFormatStyle
			self.locale = locale
		}
		
		/// Creates a `FormatOutput` instance from `value`.
		public func format(_ value: TimeInterval) -> String {
			// Measurement(value: value, unit: .seconds)
			value.asMeasurement
				.converted(to: .unit(by: unitSymbol))
				.formatted(
					.measurement(
						width: width,
						usage: usage,
						numberFormatStyle: numberFormatStyle
					)
					.locale(locale)
				)
		}
		
		/// If the format allows selecting a locale, returns a copy of this format
		/// with the new locale set. Default implementation returns an unmodified self.
		public func locale(_ locale: Locale) -> Self {
			.init(
				in: .unit(by: unitSymbol),
				width: width,
				usage: usage,
				numberFormatStyle: numberFormatStyle,
				locale: locale
			)
		}
	}
}

extension UnitDuration {
	fileprivate static func unit(by symbol: String) -> UnitDuration {
		switch symbol {
		case UnitDuration.hours.symbol: 		.hours
		case UnitDuration.minutes.symbol: 		.minutes
		case UnitDuration.seconds.symbol: 		.seconds
		case UnitDuration.nanoseconds.symbol: 	.nanoseconds
		case UnitDuration.picoseconds.symbol: 	.picoseconds
		case UnitDuration.microseconds.symbol: 	.microseconds
		default: 								.seconds
		}
	}
}

extension FormatStyle where Self == TimeInterval.SecondsMeasurementFormatStyle {
	/// Returns a `TimeInterval.SecondsMeasurementFormatStyle`
	/// for formatting time intervals as measurements of duration.
	///
	/// - Parameters:
	///   - width: The width to use for the unit display,
	///   			such as `.wide`, `.abbreviated`, or `.narrow`.
	///   - usage: The intended usage of the measurement unit,
	///   			such as `.general` or context-specific usage. Defaults to `.general`.
	///   - numberFormatStyle: The format style for the numeric component.
	///   			Defaults to a style with up to 3 significant digits.
	///   - locale: The locale to use for formatting. Defaults to `.autoupdatingCurrent`.
	/// - Returns: A measurement format style that can be used to format a `TimeInterval`
	/// 			as a localized string representation of duration.
	@inlinable public static func timeIntervalMeasurement(
		in unit: UnitDuration = .seconds,
		width: Measurement<UnitDuration>.FormatStyle.UnitWidth = .wide,
		usage: MeasurementFormatUnitUsage<UnitDuration> = .general,
		numberFormatStyle: FloatingPointFormatStyle<Double>? = .number.precision(.significantDigits(0...2)),
		locale: Locale = .autoupdatingCurrent
	) -> Self {
		.init(
			in: unit,
			width: width,
			usage: usage,
			numberFormatStyle: numberFormatStyle,
			locale: locale
		)
	}
	
	@inlinable public static var timeIntervalMeasurement: Self {
		timeIntervalMeasurement()
	}
}

// TODO: Implement the extension
/// Создать struct Timespan или расширение TimeInterval, где:
/// • пересчитываешь в минуты, секунды, миллисекунды;
/// • собираешь строку вручную;
/// • можешь добавлять опциональные опции: includeMilliseconds, rounding.
///
/// Такой подход даёт максимальный контроль, например:
/// – включить только non‑zero единицы,
/// – округление миллисекунд,
/// – поддержка отображения "2 minutes, 10 seconds, 350 milliseconds"
///
/// Реализация такого подхода описана в:
/// https://msicc.net/crafting-a-swift-timespan-type-with-a-little-prompt-engineering-magic/?utm_source=chatgpt.com
/// https://www.swiftbysundell.com/articles/exploring-some-of-the-lesser-known-formatter-types?utm_source=chatgpt.com


