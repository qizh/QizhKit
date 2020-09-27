//
//  UnitsAmount.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct UnitsAmount: Hashable, CustomStringConvertible, WithDefaultValue {
	public let unit: AnyCountableUnit
	public let amount: UInt
	
	public init(
		unit: AnyCountableUnit = .known(.item),
		amount: UInt = 1
	) {
		self.unit = unit
		self.amount = amount
//		self.amount = max(1, amount)
	}
	
	@inlinable public init(
		_ amount: UInt,
		_ unit: PriceUnit
	) {
		self.init(unit: .known(unit), amount: amount)
	}

	@inlinable public var description: String {
		unit.string(for: amount, .current)
	}
	
	@inlinable public func description(_ locale: Locale) -> String {
		unit.string(for: amount, locale)
	}
	
	@inlinable public func format(spell: Bool = false, _ locale: Locale) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = spell ? .spellOut : .decimal
		formatter.formattingContext = .dynamic
		formatter.locale = locale
		return formatter.string(from: NSNumber(value: Int(amount)))
			?? "\(amount)"
	}
	
	@inlinable public static var oneItem: UnitsAmount { .init(unit: .known(.item)) }
	@inlinable public static var onePerson: UnitsAmount { .init(unit: .known(.person)) }
	@inlinable public static var defaultValue: UnitsAmount { oneItem }
}

public extension PriceUnit {
	@inlinable func amount(of value: UInt) -> UnitsAmount { UnitsAmount(value, self) }
}

public extension AnyCountableUnit {
	@inlinable func amount(of value: UInt) -> UnitsAmount { UnitsAmount(unit: self, amount: value) }
}
