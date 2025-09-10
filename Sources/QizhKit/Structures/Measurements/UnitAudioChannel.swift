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
		converter: UnitConverterLinear(coefficient: 5)
	)
	
	public override class func baseUnit() -> UnitAudioChannel { .channel }
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


/// Convenience helpers for localization keys and comments.
extension UnitAudioChannelLocalization {
	/// The key used to look up a localized unit name.
	public var localizationKey: StaticString {
		switch self {
		case .channel_wide:	"UnitAudioChannel.channel_wide"
		case .channel_abbrev:	"UnitAudioChannel.channel_abbrev"
		case .channel_narrow:	"UnitAudioChannel.channel_narrow"
		case .mono_wide:		"UnitAudioChannel.mono_wide"
		case .mono_abbrev:		"UnitAudioChannel.mono_abbrev"
		case .mono_narrow:		"UnitAudioChannel.mono_narrow"
		case .stereo_wide:		"UnitAudioChannel.stereo_wide"
		case .stereo_abbrev:	"UnitAudioChannel.stereo_abbrev"
		case .stereo_narrow:	"UnitAudioChannel.stereo_narrow"
		case .quad_wide:		"UnitAudioChannel.quad_wide"
		case .quad_abbrev:		"UnitAudioChannel.quad_abbrev"
		case .quad_narrow:		"UnitAudioChannel.quad_narrow"
		case .surround_wide:	"UnitAudioChannel.surround_wide"
		case .surround_abbrev:	"UnitAudioChannel.surround_abbrev"
		case .surround_narrow:	"UnitAudioChannel.surround_narrow"
		}
	}

	/// A localized-comment describing the unit name.
	public var comment: StaticString {
		switch self {
		case .channel_wide:	"Wide Audio Channel unit name"
		case .channel_abbrev:	"Abbreviated Audio Channel unit name"
		case .channel_narrow:	"Narrow Audio Channel unit name"
		case .mono_wide:		"Wide mono Audio Channel unit name"
		case .mono_abbrev:		"Abbreviated mono Audio Channel unit name"
		case .mono_narrow:		"Narrow mono Audio Channel unit name"
		case .stereo_wide:		"Wide stereo Audio Channel unit name"
		case .stereo_abbrev:	"Abbreviated stereo Audio Channel unit name"
		case .stereo_narrow:	"Narrow stereo Audio Channel unit name"
		case .quad_wide:		"Wide quad Audio Channel unit name"
		case .quad_abbrev:		"Abbreviated quad Audio Channel unit name"
		case .quad_narrow:		"Narrow quad Audio Channel unit name"
		case .surround_wide:	"Wide surround Audio Channel unit name"
		case .surround_abbrev:	"Abbreviated surround Audio Channel unit name"
		case .surround_narrow:	"Narrow surround Audio Channel unit name"
		}
	}
}
// MARK: ┣ Format Style

public struct UnitAudioChannelFormatStyle: FormatStyle {
	public typealias FormatInput = Measurement<UnitAudioChannel>
	public typealias FormatOutput = String
	
	public var width: FormatInput.FormatStyle.UnitWidth = .abbreviated
	public var locale: Locale = .autoupdatingCurrent
	/// customize digits, grouping, etc.
	public var number: FloatingPointFormatStyle<Double> = .number
	
	
	public func format(_ value: Measurement<UnitAudioChannel>) -> FormatOutput {
		let formattedNumber = number.locale(locale).format(value.value)
		let loc = localization(for: value.unit, width: width)
		let localizedUnit = String(
			localized: loc.localizationKey,
			defaultValue: loc.rawValue,
			table: "Units",
			bundle: .module,
			locale: locale,
			comment: loc.comment
		)
		return String(
			localized: "UnitAudioChannel.Measurement",
			defaultValue: "\(formattedNumber) \(localizedUnit)",
			table: "Units",
			bundle: .module,
			locale: locale,
			comment: "Amount of a specific Audio Channel unit"
		)
	}

	private func localization(
		for unit: UnitAudioChannel,
		width: Measurement<UnitAudioChannel>.FormatStyle.UnitWidth
	) -> UnitAudioChannelLocalization {
		switch (unit, width) {
		case (.channel, .wide):	.channel_wide
		case (.channel, .narrow):	.channel_narrow
		case (.channel, _):	.channel_abbrev
		case (.mono, .wide):	.mono_wide
		case (.mono, .narrow):	.mono_narrow
		case (.mono, _):	.mono_abbrev
		case (.stereo, .wide):	.stereo_wide
		case (.stereo, .narrow):	.stereo_narrow
		case (.stereo, _):	.stereo_abbrev
		case (.quad, .wide):	.quad_wide
		case (.quad, .narrow):	.quad_narrow
		case (.quad, _):	.quad_abbrev
		case (.surround, .wide):	.surround_wide
		case (.surround, .narrow):	.surround_narrow
		case (.surround, _):	.surround_abbrev
		default:	.channel_abbrev
		}
	}
	fileprivate var humanReadableWidth: String {
		switch width {
		case .wide: 		"wide"
		case .abbreviated: 	"abbreviated"
		case .narrow: 		"narrow"
		default: 			"unknown"
		}
	}
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



/*
extension MeasurementFormatUnitUsage<UnitAudioChannel> {
	public st
}
*/

/*
extension UnitCount {
	public convenience init(forLocale: Locale, usage: MeasurementFormatUnitUsage<UnitCount> = .general) {
		self.ini
		
	}
}
*/

extension Measurement<UnitAudioChannel> {
	@inlinable public init(value: UInt32, unit: UnitAudioChannel) {
		self.init(value: Double(value), unit: unit)
	}
	
	/*
	@_disfavoredOverload
	@inlinable public init(value: Int, unit: UnitAudioChannel) {
		self.init(value: Double(value), unit: unit)
	}
	*/
}

/*
public class AudioChannelUnit: Dimension, @unchecked Sendable {
	public static let audioChannel = AudioChannelUnit(
		symbol: "ch",
		converter: UnitConverterLinear(coefficient: 1.0)
	)
	
	public static let baseUnit = audioChannel
}

public final class UnitAmount: Unit, @unchecked Sendable {
	public override var symbol: String { "amount" }
}

public final class UnitAudioChannelsAmount: Unit, @unchecked Sendable {
	public override var symbol: String { "ch" }
	
	public static let audioChannelsAmount = UnitAudioChannelsAmount(symbol: "ch")
	
	public static let mono: Measurement<UnitAudioChannelsAmount> =
		Measurement(value: 1, unit: .audioChannelsAmount)
	public static let stereo: Measurement<UnitAudioChannelsAmount> =
		Measurement(value: 2, unit: .audioChannelsAmount)
	public static let quad: Measurement<UnitAudioChannelsAmount> =
		Measurement(value: 4, unit: .audioChannelsAmount)
	/// 5.1 ≈ 6 discrete channels
	public static let fiveOne: Measurement<UnitAudioChannelsAmount> =
		Measurement(value: 6, unit: .audioChannelsAmount)
}
*/

extension AVAudioFormat {
	public var humanReadableDescription: String {
		let channels = Measurement(value: self.channelCount, unit: UnitAudioChannel.channel)
		let sampleRate = Measurement(value: self.sampleRate, unit: UnitFrequency.hertz)
		return "\(sampleRate.formatted(Self.sampleRateFormatStyle)), \(channels.formatted(Self.channelsAmountFormatStyle))"
	}
	
	public static var sampleRateFormatStyle: Measurement<UnitFrequency>.FormatStyle {
		.measurement(
			width: .narrow,
			usage: .general,
			numberFormatStyle: .number.precision(.fractionLength(0))
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

