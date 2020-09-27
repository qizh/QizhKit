//
//  Optional+assignment.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 10.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

infix operator ??= : AssignmentPrecedence

public extension Optional {
	/// Assigns the optional value on the right to the variable on the left only in case the variable is not defined
	@discardableResult @inlinable
	static func ??= (lhs: inout Optional<Wrapped>, rhs: @autoclosure () -> Optional<Wrapped>) -> Optional<Wrapped> {
		lhs = lhs ?? rhs()
		return lhs
	}
	
	/// Assigns the value on the right to the variable on the left only in case the variable is not defined
	@discardableResult @inlinable
	static func ??= (lhs: inout Optional<Wrapped>, rhs: @autoclosure () -> Wrapped) -> Wrapped {
		switch lhs {
		case .none:
			let r = rhs()
			lhs = r
			return r
		case .some(let l):
			return l
		}
		
		/*
		if let l = lhs {
			return l
		}
		let r = rhs()
		lhs = r
		return r
		*/
	}
}
