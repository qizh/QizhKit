//
//  NumberOfItems.swift
//  Bespokely
//
//  Created by Serhii Shevchenko on 08.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Number of Items

public struct NumberOfItems {
	public typealias Unit = PriceUnit.AnyValue
	private(set) public var value: UInt
	private(set) public var unit: Unit
}

// MARK: > Initializers

public extension NumberOfItems {
	/*
	init(_ value: UInt, unit: PriceUnit) {
		self.init(value, unit: .known(unit))
	}
	*/
	
	init(_ value: UInt, _ unit: Unit) {
		self.value = value
		self.unit = unit
	}

	init(_ value: UInt, unit: Unit = .default) {
		self.value = value
		self.unit = unit
	}
}

// MARK: > Generators

public extension NumberOfItems {
	/*
	static func generate(for range: ClosedRange<UInt>, unit: PriceUnit) -> [NumberOfItems] {
		generate(for: range, unit: .known(unit))
	}
	*/
	
	@inlinable static func generate(
		for range: ClosedRange<UInt>,
		unit: Unit = .default
	) -> [NumberOfItems] {
		range.map { number in
			NumberOfItems(number, unit: unit)
		}
	}
	
	@inlinable static func generate(
		_ range: ClosedRange<UInt>,
		of unit: Unit = .default
	) -> [NumberOfItems] {
		range.map { number in
			NumberOfItems(number, unit: unit)
		}
	}
	
	static var onePerson: NumberOfItems = .init(.one, .person)
	static var oneItem:   NumberOfItems = .init(.one, .item)
}

extension NumberOfItems: Identifiable {
	public var id: UInt { value }
}

extension NumberOfItems: Equatable {
	public static func == (lhs: NumberOfItems, rhs: NumberOfItems) -> Bool {
		assert(lhs.unit == rhs.unit, "You're comparing `NumberOfItems` of different units: \(lhs.unit.rawValue) and \(rhs.unit.rawValue).")
		return lhs.value == rhs.value
	}
}

extension NumberOfItems: Hashable { }

extension NumberOfItems: Comparable {
	public static func < (lhs: NumberOfItems, rhs: NumberOfItems) -> Bool {
		assert(lhs.unit == rhs.unit, "You're comparing `NumberOfItems` of different units: \(lhs.unit.rawValue) and \(rhs.unit.rawValue).")
		return lhs.value < rhs.value
	}
}
