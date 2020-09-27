//
//  Collection+add.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension RangeReplaceableCollection {
	mutating func prepend(_ element: Element?) {
		guard let element = element else { return }
		insert(element, at: startIndex)
	}
	
	mutating func prepend(elements: Element...) {
		insert(contentsOf: elements, at: startIndex)
	}
	
	func prepending(_ element: Element?) -> Self {
		guard let element = element else { return self }
		var copy = self
		copy.insert(element, at: startIndex)
		return copy
	}
	
	@inlinable func prepending(_ elements: Element...) -> Self {
		elements + self
	}
	
	func appending(_ element: Element?) -> Self {
		guard let element = element else { return self }
		var copy = self
		copy.append(element)
		return copy
	}
	
	@inlinable func appending(_ elements: Element...) -> Self {
		self + elements
	}
	
	mutating func cutFirst() -> Element? {
		guard isNotEmpty else { return .none }
		return remove(at: startIndex)
	}
	
	mutating func cutLast() -> Element? {
		guard isNotEmpty else { return .none }
		return remove(at: index(endIndex, offsetBy: .minusOne))
	}
	
	@inlinable var reversed: Self {
		Self(reversed())
	}
}
