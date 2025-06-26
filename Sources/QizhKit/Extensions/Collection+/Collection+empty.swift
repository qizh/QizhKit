//
//  Collection+empty.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 14.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: One element

public extension Collection where Element: Sendable {
	@inlinable var hasMoreThanOne: Bool { count > .one }
	@inlinable var     isNotAlone: Bool { count > .one }
	@inlinable var        isAlone: Bool { count .isOne }
	@inlinable var          alone: Self? {     isAlone ? self : .none }
	@inlinable var       nonAlone: Self? {  isNotAlone ? self : .none }
	@inlinable var    moreThanOne: Self? {  isNotAlone ? self : .none }
	
	var justOne: Element? { isAlone ? first : .none }
	var    only: Element? { isAlone ? first : .none }
}

// MARK: Two elements

extension Collection where Element: Sendable {
	@inlinable public var        isPair: Bool { count == .two }
	@inlinable public var     isNotPair: Bool { count != .two }
	@inlinable public var    isOverPair: Bool { count >  .two }
	@inlinable public var isPairAtLeast: Bool { count >= .two }
	
	@inlinable public var        pair: Self? {        isPair ? self : .none }
	@inlinable public var     nonPair: Self? {     isNotPair ? self : .none }
	@inlinable public var pairAtLeast: Self? { isPairAtLeast ? self : .none }
	@inlinable public var    overPair: Self? {    isOverPair ? self : .none }
	
	public var elementsPair: (Element, Element)? {
		if let first, let second {
			(first, second)
		} else {
			.none
		}
		
		/// Gemini suggested approach
		/*
		/// A collection with count == 2 is guaranteed to have a first element
		/// and a second element at the index after start.
		if count == 2, let first = self.first {
			let secondIndex = index(after: startIndex)
			return (first, self[secondIndex])
		} else {
			return .none
		}
		*/
	}
}
