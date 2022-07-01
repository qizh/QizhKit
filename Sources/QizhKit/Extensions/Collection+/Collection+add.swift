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
