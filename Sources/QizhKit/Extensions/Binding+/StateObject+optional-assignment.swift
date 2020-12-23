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
