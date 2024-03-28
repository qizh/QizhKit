//
//  Collection+add.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection {
	
	// MARK: prepend
	
	public mutating func prepend(_ element: Element?) {
		guard let element = element else { return }
		insert(element, at: startIndex)
	}
	
	public mutating func prepend(elements: Element...) {
		insert(contentsOf: elements, at: startIndex)
	}
	
	public mutating func prepend(contentsOf elements: [Element]) {
		insert(contentsOf: elements, at: startIndex)
	}
	
	// MARK: prepending
	
	public func prepending(_ element: Element?) -> Self {
		switch element {
		case .none:
			return self
		case .some(let element):
			var copy = self
			copy.insert(element, at: startIndex)
			return copy
		}
	}
	
	@inlinable
	public func prepending(_ elements: Element...) -> Self {
		elements + self
	}
	
	@inlinable
	public func prepending(contentsOf elements: [Element]) -> Self {
		elements + self
	}
	
	// MARK: appending
	
	public func appending(_ element: Element?) -> Self {
		switch element {
		case .none:
			return self
		case .some(let element):
			var copy = self
			copy.append(element)
			return copy
		}
	}
	
	@inlinable
	public func appending(_ elements: Element...) -> Self {
		self + elements
	}
	
	@inlinable
	public func appending(contentsOf elements: [Element]) -> Self {
		self + elements
	}
	
	// MARK: other
	
	@inlinable
	public var reversed: Self {
		Self(reversed())
	}
	
	// MARK: collection + element
	
	public static func + (lhs: Self, rhs: Element) -> Self {
		var lhsCopy = lhs
		lhsCopy.append(rhs)
		return lhsCopy
	}
	
	public static func + (lhs: Self, rhs: Element?) -> Self {
		switch rhs {
		case .none:
			return lhs
		case .some(let wrapped):
			var lhsCopy = lhs
			lhsCopy.append(wrapped)
			return lhsCopy
		}
	}
}

// MARK: Removing First / Last

extension RangeReplaceableCollection {
	/// Calling `removeFirst(_:)` on `self` copy and returns it
	public func removingFirst(_ k: Int) -> Self {
		var copy = self
		copy.removeFirst(k)
		return copy
	}
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {
	/// Calling `removeLast(_:)` on `self` copy and returns it
	public func removingLast(_ k: Int) -> Self {
		var copy = self
		copy.removeLast(k)
		return copy
	}
}

// MARK: cut

public extension RangeReplaceableCollection where Self: EmptyTestable {
	mutating func cutFirst() -> Element? {
		guard isNotEmpty else { return .none }
		return remove(at: startIndex)
	}
	
	mutating func cutLast() -> Element? {
		guard isNotEmpty else { return .none }
		return remove(at: index(endIndex, offsetBy: .minusOne))
	}
}

// MARK: Option Set

extension OptionSet where Self == Self.Element {
	public func inserting(_ newMembers: Self.Element...) -> Self {
		var copy = self
		for newMember in newMembers {
			copy.insert(newMember)
		}
		return copy
	}
	
	public func removing(_ members: Self.Element...) -> Self {
		var copy = self
		for member in members {
			copy.remove(member)
		}
		return copy
	}
}

// MARK: Dictionary + add / rem

extension Dictionary {
	/// Alias for ``updatingValue(_:forKey:)``
	@inlinable public func addingValue(_ value: Value, forKey key: Key) -> Self {
		updatingValue(value, forKey: key)
	}
	
	/// Create a copy with value updated (or added) for key
	public func updatingValue(_ value: Value, forKey key: Key) -> Self {
		var copy = self
		copy.updateValue(value, forKey: key)
		return copy
	}
	
	/// Create a copy with value removed for key
	public func removingValue(forKey key: Key) -> Self {
		var copy = self
		copy.removeValue(forKey: key)
		return copy
	}
}
