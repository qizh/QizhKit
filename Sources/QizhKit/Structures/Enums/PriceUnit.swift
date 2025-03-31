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
	Sendable,
	CaseIterable,
	EasyCaseComparable,
	DefaultCaseFirst,
	AcceptingOtherValues
{
	case item
	
	case access
	case action
	case audience
	case book
	case bottle
	case call
	case `class`
	case coffee
	case coin
	case content
	case day
	case event
	case file
	case gift
	case giftCard
	case googleReview
	case hour
	case map
	case masterclass
	case membership
	case minute
	case month
	case night
	case person
	case piece
	case pizza
	case request
	case screenshot
	case session
	case spot
	case ticket
	case trip
	case year
}

public typealias AnyCountableUnit = ExtraCase<PriceUnit>

extension AnyCountableUnit {
	@inlinable public static var access: 		AnyCountableUnit { .known(.access) }
	@inlinable public static var action: 		AnyCountableUnit { .known(.action) }
	@inlinable public static var audience: 		AnyCountableUnit { .known(.audience) }
	@inlinable public static var book: 			AnyCountableUnit { .known(.book) }
	@inlinable public static var bottle: 		AnyCountableUnit { .known(.bottle) }
	@inlinable public static var call: 			AnyCountableUnit { .known(.call) }
	@inlinable public static var `class`: 		AnyCountableUnit { .known(.`class`) }
	@inlinable public static var coffee: 		AnyCountableUnit { .known(.coffee) }
	@inlinable public static var coin: 			AnyCountableUnit { .known(.coin) }
	@inlinable public static var content: 		AnyCountableUnit { .known(.content) }
	@inlinable public static var day: 			AnyCountableUnit { .known(.day) }
	@inlinable public static var event: 		AnyCountableUnit { .known(.event) }
	@inlinable public static var file: 			AnyCountableUnit { .known(.file) }
	@inlinable public static var gift: 			AnyCountableUnit { .known(.gift) }
	@inlinable public static var giftCard: 		AnyCountableUnit { .known(.giftCard) }
	@inlinable public static var googleReview: 	AnyCountableUnit { .known(.googleReview) }
	@inlinable public static var hour: 			AnyCountableUnit { .known(.hour) }
	@inlinable public static var item: 			AnyCountableUnit { .known(.item) }
	@inlinable public static var map: 			AnyCountableUnit { .known(.map) }
	@inlinable public static var masterclass: 	AnyCountableUnit { .known(.masterclass) }
	@inlinable public static var membership: 	AnyCountableUnit { .known(.membership) }
	@inlinable public static var minute: 		AnyCountableUnit { .known(.minute) }
	@inlinable public static var month: 		AnyCountableUnit { .known(.month) }
	@inlinable public static var night: 		AnyCountableUnit { .known(.night) }
	@inlinable public static var person: 		AnyCountableUnit { .known(.person) }
	@inlinable public static var piece: 		AnyCountableUnit { .known(.piece) }
	@inlinable public static var pizza: 		AnyCountableUnit { .known(.pizza) }
	@inlinable public static var request: 		AnyCountableUnit { .known(.request) }
	@inlinable public static var screenshot: 	AnyCountableUnit { .known(.screenshot) }
	@inlinable public static var session: 		AnyCountableUnit { .known(.session) }
	@inlinable public static var spot: 			AnyCountableUnit { .known(.spot) }
	@inlinable public static var ticket: 		AnyCountableUnit { .known(.ticket) }
	@inlinable public static var trip: 			AnyCountableUnit { .known(.trip) }
	@inlinable public static var year: 			AnyCountableUnit { .known(.year) }
	
	@inlinable public var rawValue: String {
		switch self {
		case   .known(let known): return known.rawValue
		case .unknown(let value): return value.lowercased()
		}
	}
	
	@inlinable public var rawValuePlural: String { rawValue.pluralize() }
}
