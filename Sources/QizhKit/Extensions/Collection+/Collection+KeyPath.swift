//
//  Collection+KeyPath.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 21.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: compactMap > self

public extension Collection {
	@inlinable func compactMap<Wrapped>() -> [Wrapped] where Element == Wrapped? {
		compactMap { item -> Wrapped? in item }
	}
}

// MARK: Sorted
	
public extension Collection {
	@inlinable func sorted<Value>(
		by keyPath: KeyPath<Element, Value>,
		using valuesAreInIncreasingOrder: (Value, Value) throws -> Bool
	) rethrows -> [Element] {
		try sorted {
			try valuesAreInIncreasingOrder(
				$0[keyPath: keyPath],
				$1[keyPath: keyPath]
			)
		}
	}
	
	@inlinable func sorted<Value: Comparable>(
		by keyPath: KeyPath<Element, Value>
	) -> [Element] {
		sorted(by: keyPath, using: <)
	}
}

// MARK: First

public extension Collection {
	@inlinable func first <Value: Equatable> (
		where keyPath: KeyPath<Element, Value>,
		equals value: Value
	) -> Element? {
		first(where: { $0[keyPath: keyPath] == value })
	}
	
	@inlinable func first <Value: Equatable> (
		where keyPath: KeyPath<Element, Value>,
		equals value: Value?
	) -> Element? {
		first(where: { $0[keyPath: keyPath] == value })
	}
	
	@inlinable func contains <Value: Equatable> (
		where keyPath: KeyPath<Element, Value>,
		equals value: Value
	) -> Bool {
		contains(where: { $0[keyPath: keyPath] == value })
	}
	
	@inlinable func contains <Medium> (
		_ transform: (Element) -> Medium,
		_ isIncluded: (Medium) -> Bool
	) -> Bool {
		contains(where: { isIncluded(transform($0)) })
	}
	
	@inlinable func firstIndex <Value: Equatable> (
		where keyPath: KeyPath<Element, Value>,
		equals value: Value
	) -> Self.Index? {
		firstIndex(where: { $0[keyPath: keyPath] == value })
	}
	
	// MARK: > of type
	
	@inlinable func first<Value, Cast>(
		where keyPath: KeyPath<Element, Value>,
		is _: Cast.Type
	) -> Element? {
		first(where: { $0[keyPath: keyPath] is Cast })
	}
	
	@inlinable func first<Cast>(
		as _: Cast.Type
	) -> Cast? {
		first(where: { $0 is Cast }).flatMap({ $0 as? Cast })
	}
	
	// MARK: > CC
	
	@inlinable func first<Value: CaseComparable>(
		where keyPath: KeyPath<Element, Value>,
		is value: Value
	) -> Element? {
		first(where: { $0[keyPath: keyPath].is(value) })
	}
	
	@inlinable func first<Value: EasyComparable>(
		where keyPath: KeyPath<Element, Value>,
		is value: Value.Other
	) -> Element? {
		first(where: { $0[keyPath: keyPath].is(value) })
	}
}

public extension Collection where Element: EasyComparable {
	@inlinable
	func first(_ other: Element.Other) -> Element? {
		first(where: { $0.is(other) })
	}
}

// MARK: > ID

public extension Collection where Element: Identifiable {
	@inlinable func first(
		id: Element.ID
	) -> Element? {
		first(where: { $0.id == id })
	}
	
	@inlinable func firstIndex(
		id: Element.ID
	) -> Self.Index? {
		firstIndex(where: { $0.id == id })
	}
	
	@inlinable func contains(id: Element.ID) -> Bool {
		contains(where: { $0.id == id })
	}
}

// MARK: Contains

public extension Collection where Element: Equatable {
	@inlinable func contains(no element: Element) -> Bool {
		not(contains(element))
	}
}

public extension Collection where Element: CaseComparable {
	@inlinable func contains(_ value: Element) -> Bool {
		contains(where: value.is)
	}
}

public extension Collection where Element: EasyComparable {
	@inlinable
	func contains(_ value: Element.Other) -> Bool {
		contains { element in
			element.is(value)
		}
	}
}

@inlinable public func not <T> (_ test: @escaping (T) -> Bool) -> (T) -> Bool {
	{ !test($0) }
}

// MARK: Filter

public extension Collection {
	@inlinable func filter<Value: Equatable>(
		_ keyPath: KeyPath<Element, Value>,
		equals value: Value
	) -> [Element] {
		filter({ $0[keyPath: keyPath] == value })
	}
	
	@inlinable func filter<Value: Equatable>(
		_ keyPath: KeyPath<Element, Value>,
		notEquals value: Value
	) -> [Element] {
		filter({ $0[keyPath: keyPath] != value })
	}
	
	@inlinable func filter <Medium> (
		_ transform: (Element) -> Medium,
		_ isIncluded: (Medium) -> Bool
	) -> [Self.Element] {
		filter({ isIncluded(transform($0)) })
	}
	
	/// Keep only elements having their part found in another array
	/// - Parameters:
	///   - other: An array to check if contains a part
	///   - transformed: A transfrom of an element to receive its part
	/// - Returns: filtered array
	@inlinable func keeping <Medium: Equatable> (
		only other: [Medium],
		_ transformed: (Element) -> Medium
	) -> [Self.Element] {
		filter({ element in other.contains(transformed(element)) })
	}
	
	/// Remove elements having their part found in another array
	/// - Parameters:
	///   - other: An array to check if contains a part
	///   - transformed: A transfrom of an element to receive its part
	/// - Returns: filtered array
	@inlinable func removing <Medium: Equatable> (
		all other: [Medium],
		_ transformed: (Element) -> Medium
	) -> [Self.Element] {
		filter({ element in other.contains(no: transformed(element)) })
	}
	
	@inlinable func filter <Medium: Equatable> (
		leave transformed: (Element) -> Medium,
		 from other: [Medium]
	) -> [Self.Element] {
		filter({ element in other.contains(transformed(element)) })
	}
	
	@inlinable func filter <Medium: Equatable> (
		where transformed: (Element) -> [Medium],
		contains other: Medium
	) -> [Self.Element] {
		filter({ element in transformed(element).contains(other) })
	}
	
	// MARK: > Not
	
	@inlinable func filterNot(_ isIncluded: KeyPath<Element, Bool>) -> [Element] {
		filter(isIncluded, equals: false)
	}
	
	@inlinable func filterNot(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
		filter(not(isIncluded))
	}
	
	// MARK: > CC
	
	@inlinable func filter<Value: CaseComparable>(
		_ keyPath: KeyPath<Element, Value>,
		is value: Value
	) -> [Element] {
		filter({ $0[keyPath: keyPath].is(value) })
	}
	
	@inlinable func filter<Value: CaseComparable>(
		_ keyPath: KeyPath<Element, Value>,
		isNot value: Value
	) -> [Element] {
		filter({ $0[keyPath: keyPath].isNot(value) })
	}
	
	// MARK: > ECC
	
	@inlinable func filter<Value: EasyComparable>(
		_ keyPath: KeyPath<Element, Value>,
		is value: Value.Other
	) -> [Element] {
		filter({ $0[keyPath: keyPath].is(value) })
	}
	
	@inlinable func filter<Value: EasyComparable>(
		_ keyPath: KeyPath<Element, Value>,
		in values: [Value.Other]
	) -> [Element] {
		filter({ $0[keyPath: keyPath].in(values) })
	}
	
	@inlinable func filter<Value: EasyComparable>(
		_ keyPath: KeyPath<Element, Value>,
		isNot value: Value.Other
	) -> [Element] {
		filter({ $0[keyPath: keyPath].is(not: value) })
	}
	
	@inlinable func filter<Value: EasyComparable>(
		_ keyPath: KeyPath<Element, Value>,
		isNot values: [Value.Other]
	) -> [Element] {
		filter({ $0[keyPath: keyPath].is(not: values) })
	}
}

// MARK: > CC

public extension Collection where Element: CaseComparable {
	@inlinable func filter(
		is value: Element
	) -> [Element] {
		filter({ $0.is(value) })
	}
	
	@inlinable func filter(
		isNot value: Element
	) -> [Element] {
		filter({ $0.isNot(value) })
	}
}

// MARK: > ECC

public extension Collection where Element: EasyComparable {
	@inlinable func filter(
		is value: Element.Other
	) -> [Element] {
		filter({ $0.is(value) })
	}
	
	@inlinable func filter(
		in values: [Element.Other]
	) -> [Element] {
		filter({ $0.in(values) })
	}
	
	@inlinable func filter(
		not value: Element.Other
	) -> [Element] {
		filter({ $0.is(not: value) })
	}
	
	@inlinable func filter(
		not values: [Element.Other]
	) -> [Element] {
		filter({ $0.is(not: values) })
	}
}

// MARK: Max

public extension Collection {
	@inlinable func max<Value>(
		by keyPath: KeyPath<Element, Value>,
		using compare: (Value, Value) throws -> Bool
	) rethrows -> Element? where Value: Comparable {
		try self.max { left, right in
			try compare(
				left[keyPath: keyPath],
				right[keyPath: keyPath]
			)
		}
	}
	
	@inlinable func max<Value>(
		by keyPath: KeyPath<Element, Value>
	) -> Element? where Value: Comparable {
		self.max(by: keyPath, using: <)
	}
}

// MARK: Min

public extension Collection {
	@inlinable func min<Value>(
		by keyPath: KeyPath<Element, Value>,
		using compare: (Value, Value) throws -> Bool
	) rethrows -> Element? where Value: Comparable {
		try self.max { left, right in
			try compare(
				left[keyPath: keyPath],
				right[keyPath: keyPath]
			)
		}
	}
	
	@inlinable func min<Value>(
		by keyPath: KeyPath<Element, Value>
	) -> Element? where Value: Comparable {
		self.min(by: keyPath, using: >)
	}
}

// MARK: Group By

public extension Collection {
	func group(
		by transform: (Element) -> Bool
	)
		-> (match: [Element], other: [Element])
	{
		var match: [Element] = .init()
		var other: [Element] = .init()
		for element in self {
			if transform(element) {
				match.append(element)
			} else {
				other.append(element)
			}
		}
		return (match: match, other: other)
	}
	
	func group <Medium: Equatable> (
		by transform: (Element) -> Medium,
		equals match: Medium
	)
		-> (match: [Element], other: [Element])
	{
		group(
			by: { item in
				transform(item) == match
			}
		)
	}
	
	func group <Medium: EasyComparable> (
		by transform: (Element) -> Medium,
		is match: Medium.Other
	)
		-> (match: [Element], other: [Element])
	{
		group(
			by: { item in
				transform(item).is(match)
			}
		)
	}
}
