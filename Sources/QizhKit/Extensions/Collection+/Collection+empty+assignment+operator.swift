//
//  Collection+zeroAssignmentOperator.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 10.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Swift

infix operator ∅= : AssignmentPrecedence
infix operator ∅? : NilCoalescingPrecedence

public extension Collection {
	@inlinable static func ∅= (lhs: inout Self, rhs: Self) {
		if lhs.isEmpty {
			lhs = rhs
		}
	}
	static func ∅? (lhs: Self, rhs: Self) -> Self {
		if lhs.isEmpty {
			return rhs
		}
		return lhs
	}
	
	@inlinable static func ∅= (lhs: inout Optional<Self>, rhs: Self) {
		if lhs == nil || lhs!.isEmpty {
			lhs = rhs
		}
	}
	static func ∅? (lhs: Optional<Self>, rhs: Self) -> Self {
		if lhs == nil || lhs!.isEmpty {
			return rhs
		}
		return lhs!
	}
}

public extension Optional {
	@inlinable static func ∅= (lhs: inout Optional<Wrapped>, rhs: Optional<Wrapped>) {
		if lhs == nil, rhs != nil {
			lhs = rhs
		}
	}
	static func ∅? (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Optional<Wrapped> {
		if lhs == nil, rhs != nil {
			return rhs
		}
		return lhs
	}
	
	@inlinable static func ∅= (lhs: inout Optional<Wrapped>, rhs: Wrapped) {
		if lhs == nil {
			lhs = rhs
		}
	}
	static func ∅? (lhs: Optional<Wrapped>, rhs: Wrapped) -> Wrapped {
		if lhs == nil {
			return rhs
		}
		return lhs!
	}
}

public extension InitializableWithSequenceCollection {
	@inlinable static func ∅= (lhs: inout Self, rhs: Element) {
		if lhs.isEmpty {
			lhs = Self([rhs])
		}
	}
	static func ∅? (lhs: Self, rhs: Element) -> Self {
		if lhs.isEmpty {
			return Self([rhs])
		}
		return lhs
	}
	
	@inlinable static func ∅= (lhs: inout Self, rhs: Optional<Element>) {
		if lhs.isEmpty, rhs != nil {
			lhs = Self([rhs!])
		}
	}
	static func ∅? (lhs: Self, rhs: Optional<Element>) -> Self {
		if lhs.isEmpty, rhs != nil {
			return Self([rhs!])
		}
		return lhs
	}
}

public extension Optional where Wrapped: Collection {
	@inlinable static func ∅= (lhs: inout Optional<Wrapped>, rhs: Optional<Wrapped>) {
		if lhs == nil || lhs!.isEmpty, rhs != nil, !rhs!.isEmpty {
			lhs = rhs
		}
	}
	static func ∅? (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Optional<Wrapped> {
		if lhs == nil || lhs!.isEmpty, rhs != nil, !rhs!.isEmpty {
			return rhs
		}
		return lhs
	}
}

public extension Optional where Wrapped: InitializableWithSequenceCollection {
	@inlinable static func ∅= (lhs: inout Optional<Wrapped>, rhs: Wrapped.Element) {
		if lhs == nil || lhs!.isEmpty {
			lhs = Wrapped([rhs])
		}
	}
	static func ∅? (lhs: Optional<Wrapped>, rhs: Wrapped.Element) -> Wrapped {
		if lhs == nil || lhs!.isEmpty {
			return Wrapped([rhs])
		}
		return lhs!
	}
	
	@inlinable static func ∅= (lhs: inout Optional<Wrapped>, rhs: Optional<Wrapped.Element>) {
		if lhs == nil || lhs!.isEmpty, rhs != nil {
			lhs = Wrapped([rhs!])
		}
	}
	static func ∅? (lhs: Optional<Wrapped>, rhs: Optional<Wrapped.Element>) -> Optional<Wrapped> {
		if lhs == nil || lhs!.isEmpty, rhs != nil {
			return Wrapped([rhs!])
		}
		return lhs
	}
}
