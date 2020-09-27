//
//  Optional+forceUnwrap.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 25.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Optional {
	
	/// Optional unwrap with an assumption
	/// - Parameter assumption: A safety unwrapping assumption
	/// you will have in logs if it will fail.
	/// - Example:
	/// ```
	/// let a: Int? = nil
	/// let b = a.forceUnwrap(because: "I though it was definetely non-nil")
	/// ```
	/// - Returns: Unwrapped optional or fatalError
	/// - Attention: Will fail with error for nil optionals
	
	func forceUnwrap(because assumption: OptionalForcedUnwrapAssumption) -> Wrapped {
		switch self {
		case .none:
			fatalError(
				"""
				Unexpectedly found `nil` unwrapping an Optional. \
				Failed assumption: "\(assumption)"
				"""
			)
		case .some(let wrapped):
			return wrapped
		}
	}
	
	@inlinable func forceUnwrap(because assumption: String) -> Wrapped { forceUnwrap(because: OptionalForcedUnwrapAssumption(assumption)) }
	
	@inlinable func forceUnwrapBecauseTested()  -> Wrapped { forceUnwrap(because: .tested) }
	@inlinable func forceUnwrapBecauseCreated() -> Wrapped { forceUnwrap(because: .created) }
	@inlinable func forceUnwrapBecauseSet()     -> Wrapped { forceUnwrap(because: .set) }
}

public struct OptionalForcedUnwrapAssumption: ExpressibleByStringLiteral, CustomStringConvertible {
	public let value: String
	public init(_ value: String) { self.value = value }
	public init(stringLiteral value: String) { self.value = value }
	@inlinable public var description: String { value }
	
	public static let tested  = Self("Was tested with `if` statement")
	public static let created = Self("Is initialized right here with value")
	public static let set     = Self("Value was just set")
}
