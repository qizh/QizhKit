//
//  PriceUnit.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public enum PriceUnit:
	String,
	Codable,
	CaseIterable,
//	CaseInsensitiveStringRepresentable,
	EasyCaseComparable,
	DefaultCaseFirst,
	AcceptingOtherValues
{
	case item
	case person
	case hour
	case ticket
	case bottle
	case piece
	case day
	case night
	case trip
	case coin
}

public typealias AnyCountableUnit = ExtraCase<PriceUnit>

public extension AnyCountableUnit {
	static var item:    AnyCountableUnit { .known(.item) }
	static var person:  AnyCountableUnit { .known(.person) }
	static var hour:    AnyCountableUnit { .known(.hour) }
	static var ticket:  AnyCountableUnit { .known(.ticket) }
	static var bottle:  AnyCountableUnit { .known(.bottle) }
	static var piece:   AnyCountableUnit { .known(.piece) }
	static var day:     AnyCountableUnit { .known(.day) }
	static var night:   AnyCountableUnit { .known(.night) }
	static var trip:    AnyCountableUnit { .known(.trip) }
	static var coin:    AnyCountableUnit { .known(.coin) }

	@inlinable func string(for amount: UInt, spell: Bool = false, _ locale: Locale) -> String {
		string(for: Int(amount), spell: spell, locale)
//		string(for: Int(amount.clippedFromZero(to: UInt(Int.max))), spell: spell, locale)
	}
	
	@inlinable func string(for amount: Int, spell: Bool = false, _ locale: Locale) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = spell ? .spellOut : .decimal
		formatter.formattingContext = .dynamic
		formatter.locale = locale
		
		return (formatter.string(from: NSNumber(value: amount)).map { $0 + .space } ?? .empty)
			+ rawValue.pluralize(count: amount)
	}
	
	@inlinable
	var rawValue: String {
		switch self {
		case   .known(let known): return known.rawValue
		case .unknown(let value): return value.lowercased()
		}
	}
	
	@inlinable var rawValuePlural: String { rawValue.pluralize() }
}
