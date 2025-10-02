//
//  UnitAudioChannel.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 10.09.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation
import AVFAudio
import SwiftUI
import QizhMacroKit

extension Measurement<UnitFrequency>: @retroactive Strideable {
	public func distance(to other: Measurement<UnitFrequency>) -> Double {
		other.converted(to: unit).value - value
	}
	
	public func advanced(by n: Double) -> Self {
		self + .init(value: value + n, unit: unit)
	}
}

// MARK: - Unit Count

/// Count of items (base = piece)
public final class UnitCount: Dimension, @unchecked Sendable {
	/// base is `piece`
	public static let piece = UnitCount(
		symbol: "pc",
		converter: UnitConverterLinear(coefficient: 1)
	)
	
	/// `1` `dozen` = `12` `pieces`
	public static let dozen = UnitCount(
		symbol: "dz",
		converter: UnitConverterLinear(coefficient: 12)
	)
	
	/// `1` `pair` = `2` `pieces`
	public static let pair = UnitCount(
		symbol: "pair",
		converter: UnitConverterLinear(coefficient: 2)
	)
	
	/// `1` `thousand` = `1_000` `pieces`
	public static let thousand = UnitCount(
		symbol: "K",
		converter: UnitConverterLinear(coefficient: 1_000)
	)

	public override class func baseUnit() -> UnitCount { .piece }
}

// MARK: - Unit Audio Channel

/// Count of Audio Channels
public final class UnitAudioChannel: Dimension, @unchecked Sendable {
	/// Base unit
	public static let channel = UnitAudioChannel(
		symbol: "ch",
		converter: UnitConverterLinear(coefficient: 1)
	)
	
	/// Base unit
	public static let mono = UnitAudioChannel(
		symbol: "mono",
		converter: UnitConverterLinear(coefficient: 1)
	)
	
	/// 1 stereo = 2 mono
	public static let stereo = UnitAudioChannel(
		symbol: "stereo",
		converter: UnitConverterLinear(coefficient: 2)
	)
	
	/// 1 quad = 4 mono
	public static let quad = UnitAudioChannel(
		symbol: "quad",
		converter: UnitConverterLinear(coefficient: 4)
	)
	
	/// 1 surround = 5 mono + 1 mono
	public static let surround = UnitAudioChannel(
		symbol: "surround",
		converter: UnitConverterLinear(coefficient: 6)
	)
	
	public override class func baseUnit() -> UnitAudioChannel { .channel }
}

extension Measurement<UnitAudioChannel> {
	@inlinable public var amount: Int { value.int }
}

// MARK: ┣ Localized unit names

/// Keys you will put into Localizable.strings / .stringsdict
@CaseName @IsCase
public enum UnitAudioChannelLocalization: String, AcceptingOtherValues, CasesBridgeProvider, Sendable {
	/// channels
	case channel_wide       = "channels"
	case channel_abbrev     = "ch"
	case channel_narrow     = "chnl"

	/// mono
	case mono_wide       	= "mono channels"
	case mono_abbrev     	= "mn ch"
	case mono_narrow     	= "mono ch"

	/// stereo
	case stereo_wide       	= "stereo channels"
	case stereo_abbrev     	= "st ch"
	case stereo_narrow     	= "stereo ch"

	/// quad
	case quad_wide       	= "quad channels"
	case quad_abbrev     	= "qd ch"
	case quad_narrow     	= "quad ch"

	/// surround
	case surround_wide      = "surround channels"
	case surround_abbrev    = "ch5.1"
	case surround_narrow    = "5.1 ch"
}

/*
extension UnitAudioChannelLocalization {
	public var localizationKey: StaticString {
		switch self {
		case .channel_wide: 	"UnitAudioChannel.channel_wide"
		case .channel_abbrev: 	"UnitAudioChannel.channel_abbrev"
		case .channel_narrow: 	"UnitAudioChannel.channel_narrow"
		case .mono_wide: 		"UnitAudioChannel.mono_wide"
		case .mono_abbrev: 		"UnitAudioChannel.mono_abbrev"
		case .mono_narrow: 		"UnitAudioChannel.mono_narrow"
		case .stereo_wide: 		"UnitAudioChannel.stereo_wide"
		case .stereo_abbrev: 	"UnitAudioChannel.stereo_abbrev"
		case .stereo_narrow: 	"UnitAudioChannel.stereo_narrow"
		case .quad_wide: 		"UnitAudioChannel.quad_wide"
		case .quad_abbrev: 		"UnitAudioChannel.quad_abbrev"
		case .quad_narrow: 		"UnitAudioChannel.quad_narrow"
		case .surround_wide: 	"UnitAudioChannel.surround_wide"
		case .surround_abbrev: 	"UnitAudioChannel.surround_abbrev"
		case .surround_narrow: 	"UnitAudioChannel.surround_narrow"
		}
	}
}
*/

// MARK: ┣ Format Style

public struct UnitAudioChannelFormatStyle: FormatStyle {
	public typealias FormatInput = Measurement<UnitAudioChannel>
	public typealias FormatOutput = String
	
	public var width: FormatInput.FormatStyle.UnitWidth = .abbreviated
	public var locale: Locale = .autoupdatingCurrent
	/// customize digits, grouping, etc.
	public var number: FloatingPointFormatStyle<Double> = .number
	
	public func format(_ value: Measurement<UnitAudioChannel>) -> FormatOutput {
		/// 1) Format the numeric part using the requested `number` style & `locale`
		let formattedNumber = number.locale(locale).format(value.value)
		
		/// 2) Create a localized String for `unit`
		let localizedUnit: String =
			switch (value.unit, width) {
			case (.channel, .wide): 		
				String(
					localized: "UnitAudioChannel.channel_wide",
					defaultValue: "channels",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Wide Audio Channel unit name"
				)
			case (.channel, .abbreviated):
				String(
					localized: "UnitAudioChannel.channel_abbrev",
					defaultValue: "ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Abbreviated Audio Channel unit name"
				)
			case (.channel, .narrow):
				String(
					localized: "UnitAudioChannel.channel_narrow",
					defaultValue: "chnl",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Narrow Audio Channel unit name"
				)
			case (.channel, _):
				String(
					localized: "UnitAudioChannel.channel_unknown",
					defaultValue: "ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Default Audio Channel unit name"
				)
			case (.mono, .wide):
				String(
					localized: "UnitAudioChannel.mono_wide",
					defaultValue: "mono channels",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Wide mono Audio Channel unit name"
				)
			case (.mono, .abbreviated):
				String(
					localized: "UnitAudioChannel.mono_abbrev",
					defaultValue: "mn ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Abbreviated mono Audio Channel unit name"
				)
			case (.mono, .narrow):
				String(
					localized: "UnitAudioChannel.mono_narrow",
					defaultValue: "mono ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Narrow mono Audio Channel unit name"
				)
			case (.mono, _):
				String(
					localized: "UnitAudioChannel.mono_unknown",
					defaultValue: "mn ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Default mono Audio Channel unit name"
				)
			case (.stereo, .wide):
				String(
					localized: "UnitAudioChannel.stereo_wide",
					defaultValue: "stereo channels",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Wide stereo Audio Channel unit name"
				)
			case (.stereo, .abbreviated):
				String(
					localized: "UnitAudioChannel.stereo_abbrev",
					defaultValue: "st ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Abbreviated stereo Audio Channel unit name"
				)
			case (.stereo, .narrow):
				String(
					localized: "UnitAudioChannel.stereo_narrow",
					defaultValue: "stereo ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Narrow stereo Audio Channel unit name"
				)
			case (.stereo, _):
				String(
					localized: "UnitAudioChannel.stereo_unknown",
					defaultValue: "st ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Default stereo Audio Channel unit name"
				)
			case (.quad, .wide):
				String(
					localized: "UnitAudioChannel.quad_wide",
					defaultValue: "quad channels",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Wide quad Audio Channel unit name"
				)
			case (.quad, .abbreviated):
				String(
					localized: "UnitAudioChannel.quad_abbrev",
					defaultValue: "qd ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Abbreviated quad Audio Channel unit name"
				)
			case (.quad, .narrow):
				String(
					localized: "UnitAudioChannel.quad_narrow",
					defaultValue: "quad ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Narrow quad Audio Channel unit name"
				)
			case (.quad, _):
				String(
					localized: "UnitAudioChannel.quad_unknown",
					defaultValue: "qd ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Default quad Audio Channel unit name"
				)
			case (.surround, .wide):
				String(
					localized: "UnitAudioChannel.surround_wide",
					defaultValue: "surround channels",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Wide surround Audio Channel unit name"
				)
			case (.surround, .abbreviated):
				String(
					localized: "UnitAudioChannel.surround_abbrev",
					defaultValue: "ch5.1",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Abbreviated surround Audio Channel unit name"
				)
			case (.surround, .narrow):
				String(
					localized: "UnitAudioChannel.surround_narrow",
					defaultValue: "5.1 ch",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Narrow surround Audio Channel unit name"
				)
			case (.surround, _):
				String(
					localized: "UnitAudioChannel.surround_unknown",
					defaultValue: "ch5.1",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Default surround Audio Channel unit name"
				)
			default:
				String(
					localized: "UnitAudioChannel.unknown",
					defaultValue: "unknwn",
					table: "Units",
					bundle: .module,
					locale: locale,
					comment: "Default unknown Audio Channel unit name"
				)
			}
		
		return String(
			localized: "UnitAudioChannel.Measurement",
			defaultValue: "\(formattedNumber) \(localizedUnit)",
			table: "Units",
			bundle: .module,
			locale: locale,
			comment: "Amount of a specific Audio Channel unit"
		)
	}
	
	/*
	fileprivate var humanReadableWidth: String {
		switch width {
		case .wide: 		"wide"
		case .abbreviated: 	"abbreviated"
		case .narrow: 		"narrow"
		default: 			"unknown"
		}
	}
	*/
}

extension FormatStyle where Self == UnitAudioChannelFormatStyle {
	public static func unitEach(
		width: Measurement<UnitAudioChannel>.FormatStyle.UnitWidth = .abbreviated,
		locale: Locale = .current,
		number: FloatingPointFormatStyle<Double> = .number
	) -> UnitAudioChannelFormatStyle {
		.init(width: width, locale: locale, number: number)
	}
}

extension Measurement<UnitAudioChannel> {
	@inlinable public init(value: Int, unit: UnitAudioChannel) {
		self.init(value: Double(value), unit: unit)
	}
}

extension AVAudioFormat {
	public var humanReadableDescription: String {
		let channels = Measurement<UnitAudioChannel>(value: channelCount.double, unit: .channel)
		let sampleRate = Measurement<UnitFrequency>(value: sampleRate, unit: .hertz)
		return """
			\(sampleRate.formatted(Self.sampleRateFormatStyle)), \
			\(channels.formatted(Self.channelsAmountFormatStyle))
			"""
	}
	
	public static var sampleRateFormatStyle: Measurement<UnitFrequency>.FormatStyle {
		.measurement(
			width: .narrow,
			usage: .general,
			numberFormatStyle: .number.precision(.fractionLength(0...3))
		)
	}
	
	public static var channelsAmountFormatStyle: Measurement<UnitAudioChannel>.FormatStyle {
		.measurement(
			width: .narrow,
			usage: .general,
			numberFormatStyle: .number.precision(.fractionLength(0))
		)
	}
}

