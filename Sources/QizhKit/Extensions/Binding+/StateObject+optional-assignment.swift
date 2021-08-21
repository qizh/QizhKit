//
//  StateObject+optional-assignment.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
public extension StateObject {
	/// Creates a new `StateObject` initialized with a `wrappedValue` set
	/// if the right side value is defined
	@discardableResult @inlinable
	static func =? (lhs: inout StateObject, rhs: ObjectType?) -> StateObject {
		switch rhs {
		case .none: return lhs
		case .some(let value):
			lhs = .init(wrappedValue: value)
			return lhs
		}
	}
}

public extension State {
	/// Creates a new `State` initialized with a `initialValue` set
	/// if the right side value is defined
	@discardableResult @inlinable
	static func =? (lhs: inout State, rhs: Value?) -> State {
		switch rhs {
		case .none: return lhs
		case .some(let value):
			lhs = .init(initialValue: value)
			return lhs
		}
	}
}

public extension Published {
	/// Creates a new `Published` initialized with a `initialValue` set
	/// if the right side value is defined
	@discardableResult @inlinable
	static func =? (lhs: inout Published<Value>, rhs: Value?) -> Published<Value> {
		switch rhs {
		case .none: return lhs
		case .some(let value):
			lhs = .init(initialValue: value)
			return lhs
		}
	}
}

// MARK: Common Initializers

extension State {
	public static func none<T>() -> Self where Value == T? {
		.init(initialValue: .none)
	}
}
extension Published {
	public static func none<T>() -> Self where Value == T? {
		.init(initialValue: .none)
	}
}
