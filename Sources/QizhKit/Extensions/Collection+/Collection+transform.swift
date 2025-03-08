//
//  Collection+transform.swift
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
	
	@inlinable func compactMap<T>(as type: T.Type) -> [T] {
		compactMap { element -> T? in
			element as? T
		}
	}
}

// MARK: Sorted
	
public extension Sequence {
	@inlinable func sorted <Value> (
		by transform: (Element) -> Value,
		using valuesAreInIncreasingOrder: (Value, Value) throws -> Bool
	) rethrows -> [Element] {
		try sorted {
			try valuesAreInIncreasingOrder(
				transform($0),
				transform($1)
			)
		}
	}
	
	@inlinable func sorted(
		by transform: (Element) -> some Comparable
	) -> [Element] {
		sorted(by: transform, using: <)
	}
	
	// MARK: ┗ Same with KeyPath
	
	/// Is here just of ignore the error
	/// introduced by adding the same public function in  `InstantSearchCore` SPM
	@_disfavoredOverload
	@inlinable func sorted <Value> (
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
	
	/// Is here just of ignore the error
	/// introduced by adding the same public function in  `InstantSearchCore` SPM
	@_disfavoredOverload
	@inlinable func sorted(
		by keyPath: KeyPath<Element, some Comparable>
	) -> [Element] {
		sorted(by: keyPath, using: <)
	}
}

// MARK: First

extension Collection {
	@inlinable public func first <Value: Equatable> (
		where transform: (Element) -> Value,
		equals value: Value
	) -> Element? {
		first(where: { transform($0) == value })
	}
	
	@inlinable public func first <Value: Equatable> (
		where transform: (Element) -> Value,
		equals value: Value?
	) -> Element? {
		first(where: { transform($0) == value })
	}
	
	@inlinable public func first <Value: Equatable, Sortable> (
		by sortTransform: (Element) -> Sortable,
		using valuesAreInIncreasingOrder: (Sortable, Sortable) throws -> Bool,
		where compareTransform: (Element) -> Value,
		equals value: Value
	) rethrows -> Element? {
		try self
			.filter({ compareTransform($0) == value })
			.min(by: sortTransform, using: valuesAreInIncreasingOrder)
	}
	
	/// Sorting by `<`
	@inlinable public func first <Value: Equatable> (
		by sortTransform: (Element) -> some Comparable,
		where compareTransform: (Element) -> Value,
		equals value: Value
	) -> Element? {
		self.filter({ compareTransform($0) == value })
			.min(by: sortTransform)
	}
	
	@inlinable
	public func contains <Value: Equatable> (
		where transform: (Element) -> Value,
		equals value: Value
	) -> Bool {
		contains(where: { transform($0) == value })
	}
	
	@inlinable
	public func contains <Medium> (
		_ transform: (Element) -> Medium,
		_ isIncluded: (Medium) -> Bool
	) -> Bool {
		contains(where: { isIncluded(transform($0)) })
	}
	
	@inlinable
	public func contains <Value: EasyComparable> (
		where transform: (Element) -> Value,
		is value: Value.Other
	) -> Bool {
		contains(where: { transform($0).is(value) })
	}
	
	@inlinable
	public func firstIndex <Medium: Equatable> (
		where transform: (Element) -> Medium,
		equals value: Medium
	) -> Self.Index? {
		firstIndex(where: { transform($0) == value })
	}
	
	// MARK: > of type
	
	@inlinable
	public func first<Value, Cast>(
		where transform: (Element) -> Value,
		is _: Cast.Type
	) -> Element? {
		first(where: { transform($0) is Cast })
	}
	
	@inlinable
	public func first<Cast>(
		as _: Cast.Type
	) -> Cast? {
		first(where: { $0 is Cast }).flatMap({ $0 as? Cast })
	}
	
	// MARK: > Easy Comparable
	
	/*
	@available(*, deprecated, message: "Switch from `CaseComparable` to `EasyComparable`")
	@inlinable public func first <Value: CaseComparable> (
		where transform: (Element) -> Value,
		is value: Value
	) -> Element? {
		first(where: { transform($0).is(value) })
	}
	*/
	
	@inlinable public func first <Value: EasyComparable> (
		where transform: (Element) -> Value,
		is value: Value.Other
	) -> Element? {
		first(where: { transform($0).is(value) })
	}
	
	@inlinable public func first <Value: EasyComparable> (
		where transform: (Element) -> Value,
		in values: [Value.Other]
	) -> Element? {
		first(where: { transform($0).in(values) })
	}
	
	@inlinable public func first <Value: EasyComparable, Sortable> (
		by sortTransform: (Element) -> Sortable,
		using valuesAreInIncreasingOrder: (Sortable, Sortable) throws -> Bool,
		where compareTransform: (Element) -> Value,
		is value: Value.Other
	) rethrows -> Element? {
		try self
			.filter({ compareTransform($0).is(value) })
			.min(by: sortTransform, using: valuesAreInIncreasingOrder)
			/*
			.sorted(by: sortBy, using: valuesAreInIncreasingOrder)
			.first(where: { transform($0).is(value) })
			*/
	}
	
	@inlinable public func first <Value: EasyComparable> (
		by sortTransform: (Element) -> some Comparable,
		where compareTransform: (Element) -> Value,
		is value: Value.Other
	) -> Element? {
		self.filter({ compareTransform($0).is(value) })
			.min(by: sortTransform)
			/*
			.sorted(by: sortBy, using: <)
			.first(where: { transform($0).is(value) })
			*/
	}
}

public extension Collection where Element: EasyComparable {
	@inlinable
	func first(_ other: Element.Other) -> Element? {
		first(where: { $0.is(other) })
	}
}

// MARK: Last

extension BidirectionalCollection {
	@inlinable public func last <Value: Equatable> (
		where transform: (Element) -> Value,
		equals value: Value
	) -> Element? {
		last(where: { transform($0) == value })
	}
	
	@inlinable public func last <Value: Equatable> (
		where transform: (Element) -> Value,
		equals value: Value?
	) -> Element? {
		last(where: { transform($0) == value })
	}
	
	@inlinable public func last <Value: Equatable, Sortable> (
		by sortTransform: (Element) -> Sortable,
		using valuesAreInIncreasingOrder: (Sortable, Sortable) throws -> Bool,
		where compareTransform: (Element) -> Value,
		equals value: Value
	) rethrows -> Element? {
		try self
			.filter({ compareTransform($0) == value })
			.min(by: sortTransform, using: valuesAreInIncreasingOrder)
	}
	
	/// Sorting by `<`
	@inlinable public func last <Value: Equatable> (
		by sortTransform: (Element) -> some Comparable,
		where compareTransform: (Element) -> Value,
		equals value: Value
	) -> Element? {
		self.filter({ compareTransform($0) == value })
			.min(by: sortTransform)
	}
	
	// MARK: > Easy Comparable
	
	@inlinable public func last <Value: EasyComparable> (
		where transform: (Element) -> Value,
		is value: Value.Other
	) -> Element? {
		last(where: { transform($0).is(value) })
	}
	
	@inlinable public func last <Value: EasyComparable> (
		where transform: (Element) -> Value,
		in values: [Value.Other]
	) -> Element? {
		last(where: { transform($0).in(values) })
	}
	
	@inlinable public func last <Value: EasyComparable, Sortable> (
		by sortTransform: (Element) -> Sortable,
		using valuesAreInIncreasingOrder: (Sortable, Sortable) throws -> Bool,
		where compareTransform: (Element) -> Value,
		is value: Value.Other
	) rethrows -> Element? {
		try self
			.filter({ compareTransform($0).is(value) })
			.max(by: sortTransform, using: valuesAreInIncreasingOrder)
	}
	
	@inlinable public func last <Value: EasyComparable> (
		by sortTransform: (Element) -> some Comparable,
		where compareTransform: (Element) -> Value,
		is value: Value.Other
	) -> Element? {
		self.filter({ compareTransform($0).is(value) })
			.max(by: sortTransform)
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

// MARK: Filter Bool?

extension Sequence {
	/// Same as regular `filter`, but works with `Optional<Bool>`
	@_disfavoredOverload
	@inlinable public func filter(
		_ isIncluded: (Self.Element) throws -> Bool?
	) rethrows -> [Self.Element] {
		try self.filter({ try isIncluded($0) == true })
	}
}

// MARK: Filter

public extension Collection {
	@inlinable func filter<Value: Equatable>(
		_ transform: (Element) -> Value,
		equals value: Value
	) -> [Element] {
		filter({ transform($0) == value })
	}
	
	@inlinable func filter<Value: Equatable>(
		_ transform: (Element) -> Value,
		notEquals value: Value
	) -> [Element] {
		filter({ transform($0) != value })
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
	@available(*, deprecated, renamed: "removing(where:in:)", message: "Renamed to `removing(where:in:)` for better readability")
	@inlinable func removing <Medium: Equatable> (
		all other: [Medium],
		_ transformed: (Element) -> Medium
	) -> [Self.Element] {
		filter({ element in other.contains(no: transformed(element)) })
	}
	
	/// Returns an array with elements
	/// whose transformed values are **not** in the given array.
	///
	/// This method iterates over the collection and applies the provided
	/// `transformed` closure to each element to extract a comparable value
	/// of type `Medium`. If the resulting value is found in the `other` array,
	/// the element is excluded from the returned array.
	///
	/// - Parameters:
	///   - transformed: A closure that converts each element into a comparable value.
	///   - other: An array of values;
	///   		if an element's transformed value is found in this array, it is excluded.
	/// - Returns: An array containing only the elements that pass the filter.
	/// - Note: The original collection remains unmodified.
	/// - Example:
	/// 	```swift
	/// 	let words = ["apple", "banana", "cherry"]
	/// 	// Remove words whose length is present in the forbidden lengths array.
	/// 	let filteredWords = words.removing(where: \.count, in: [6, 7])
	/// 	// filteredWords contains ["apple"] because "banana" and "cherry" has 6 letters.
	/// 	```
	@inlinable func removing <Medium: Equatable, Mediums: Sequence> (
		where transformed: (Element) -> Medium,
		in other: Mediums
	) -> [Element] where Mediums.Element == Medium {
		filter { element in
			not(other.contains(transformed(element)))
		}
	}

	@inlinable func removingAll <Medium: Equatable> (
		where transformed: (Element) -> Medium,
		equals other: Medium
	) -> [Element] {
		filter({ transformed($0) != other })
	}
	
	@inlinable func filter <Medium: Equatable, Mediums: Sequence> (
		leave transformed: (Element) -> Medium,
		from other: Mediums
	) -> [Self.Element] where Mediums.Element == Medium {
		filter({ element in other.contains(transformed(element)) })
	}
	
	@inlinable func filter <Medium: Equatable, Mediums: Sequence> (
		remove transformed: (Element) -> Medium,
		from other: Mediums
	) -> [Self.Element] where Mediums.Element == Medium {
		filter({ element in not(other.contains(transformed(element))) })
	}
	
	@inlinable func filter <Medium: Equatable> (
		where transformed: (Element) -> [Medium],
		contains other: Medium
	) -> [Self.Element] {
		filter({ element in transformed(element).contains(other) })
	}
	
	// MARK: > Not
	
	/*
	@_disfavoredOverload
	@inlinable func filterNot(_ isIncluded: KeyPath<Element, Bool>) -> [Element] {
		filter(isIncluded, equals: false)
	}
	*/
	
	@inlinable func filterNot(_ isIncluded: (Element) -> Bool) -> [Element] {
		self.filter({not(isIncluded($0))})
	}
	
	// MARK: > CC
	
	@available(*, deprecated, message: "CaseComparable is outdated, use EasyComparable or @IsCase instead")
	@inlinable func filter<Value: CaseComparable>(
		_ keyPath: KeyPath<Element, Value>,
		is value: Value
	) -> [Element] {
		filter({ $0[keyPath: keyPath].is(value) })
	}
	
	@available(*, deprecated, message: "CaseComparable is outdated, use EasyComparable or @IsCase instead")
	@inlinable func filter<Value: CaseComparable>(
		_ keyPath: KeyPath<Element, Value>,
		isNot value: Value
	) -> [Element] {
		filter({ $0[keyPath: keyPath].isNot(value) })
	}
	
	// MARK: > ECC
	
	@inlinable func filter<Value: EasyComparable>(
		_ transform: (Element) -> Value,
		is value: Value.Other
	) -> [Element] {
		filter({ transform($0).is(value) })
	}
	
	@inlinable func filter<Value: EasyComparable>(
		_ transform: (Element) -> Value,
		in values: [Value.Other]
	) -> [Element] {
		filter({ transform($0).in(values) })
	}
	
	@inlinable func filter<Value: EasyComparable>(
		_ transform: (Element) -> Value,
		isNot value: Value.Other
	) -> [Element] {
		filter({ transform($0).is(not: value) })
	}
	
	@inlinable func filter<Value: EasyComparable>(
		_ transform: (Element) -> Value,
		isNot values: [Value.Other]
	) -> [Element] {
		filter({ transform($0).is(not: values) })
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
		by transform: (Element) -> Value,
		using compare: (Value, Value) throws -> Bool
	) rethrows -> Element? {
		try self.max { left, right in
			try compare(
				transform(left),
				transform(right)
			)
		}
	}
	
	@inlinable func max(
		by transform: (Element) -> some Comparable
	) -> Element? {
		self.max(by: transform, using: <)
	}
}

// MARK: Min

public extension Collection {
	@inlinable func min<Value>(
		by transform: (Element) -> Value,
		using areInIncreasingOrder: (Value, Value) throws -> Bool
	) rethrows -> Element? {
		try self.min { left, right in
			try areInIncreasingOrder(
				transform(left),
				transform(right)
			)
		}
	}
	
	@inlinable func min(
		by transform: (Element) -> some Comparable
	) -> Element? {
		self.min(by: transform, using: <)
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

// MARK: Replace

extension Collection where Self: MutableCollection & RangeReplaceableCollection {
	/// Replace an element matching condition
	/// - Parameters:
	///   - element: Element
	///   - add: Append element if no elements matching condition found
	///   - condition: Replacing condition
	/// - Returns: Element matching condition was found
	@discardableResult
	mutating public func replaceFirst(
		with element: Element,
		add: Bool = false,
		where condition: (Element) -> Bool
	) -> Bool {
		if let index = firstIndex(where: condition) {
			self[index] = element
			return true
		} else if add {
			append(element)
		}
		return false
	}
	
	/// Replace all elements matching condition
	/// - Parameters:
	///   - element: Element
	///   - add: Append element if no elements matching condition found
	///   - condition: Replacing condition
	/// - Returns: Elements matching condition were found
	@discardableResult
	mutating public func replaceAll(
		with element: Element,
		add: Bool = false,
		where condition: (Element) -> Bool
	) -> Bool {
		var wasAdded = false
		for index in indices {
			if condition(self[index]) {
				self[index] = element
				wasAdded = true
			}
		}
		if add, not(wasAdded) {
			append(element)
		}
		return wasAdded
	}
	
	/// Creates a copy with a replaced element matching condition
	/// - Parameters:
	///   - element: Element
	///   - add: Append element if no elements matching condition found
	///   - condition: Replacing condition
	/// - Returns: A copy with a replaced element
	public func replacingFirst(
		with element: Element,
		add: Bool = false,
		where condition: (Element) -> Bool
	) -> Self {
		if let index = firstIndex(where: condition) {
			var copy = self
			copy[index] = element
			return copy
		} else if add {
			return appending(element)
		} else {
			return self
		}
	}
	
	/// Creates a copy with all element matching condition being replaced
	/// - Parameters:
	///   - element: Element
	///   - add: Append element if no elements matching condition found
	///   - condition: Replacing condition
	/// - Returns: A copy with replaced elements
	public func replacingAll(
		with element: Element,
		add: Bool = false,
		where condition: (Element) -> Bool
	) -> Self {
		var wasAdded = false
		var copy = self
		
		for index in copy.indices {
			if condition(copy[index]) {
				copy[index] = element
				wasAdded = true
			}
		}
		
		if wasAdded {
			return copy
		} else if add {
			return appending(element)
		} else {
			return self
		}
	}

}
