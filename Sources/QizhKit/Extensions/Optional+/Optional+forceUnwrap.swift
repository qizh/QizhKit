//
//  Optional+forceUnwrap.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 25.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Optional {
	/// Force-unwraps the optional, terminating the program with a detailed message
	/// if the value is `nil`.
	///
	/// Use this method when you have a strong, justified reason to believe the optional
	/// contains a value, and you want any failure to be immediately visible with a clear
	/// explanation. The provided `assumption` documents why the force unwrap is considered
	/// safe and is included in the failure message to aid debugging.
	/// - Parameter assumption: A self-documenting reason explaining why unwrapping is safe,
	///   expressed as an `OptionalForcedUnwrapAssumption`. This text is surfaced in the
	///   fatal error if the optional is unexpectedly `nil`.
	/// - Returns: The `wrapped` value if the optional contains a value.
	/// - Precondition: The optional must not be `nil` at the point of call. If it is `nil`,
	///   the program will terminate via `fatalError`, including the supplied assumption
	///   text.
	/// - Important: Prefer safer unwrapping strategies (e.g., `if let`, `guard let`,
	///   or providing defaults) whenever possible. Reserve this method for cases
	///   where a `nil` value indicates a programmer error or an invariant violation.
	/// - Experiment:
	///   ```swift
	///   let userID: String? = fetchUserID()
	///   let id = userID.forceUnwrap(because: .tested) // previously checked to be non-nil
	///   ```
	/// - SeeAlso:
	///   - ``OptionalForcedUnwrapAssumption``
	///   - ``Optional/forceUnwrap(because:)-(String)``
	///   - ``Optional/forceUnwrapBecauseTested()``
	///   - ``Optional/forceUnwrapBecauseCreated()``
	///   - ``Optional/forceUnwrapBecauseSet()``
	///   - ``Optional/forceUnwrapManagedObjectField()```
	public func forceUnwrap(because assumption: OptionalForcedUnwrapAssumption) -> Wrapped {
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
	
	@inlinable public func forceUnwrap(because assumption: String) -> Wrapped {
		forceUnwrap(because: OptionalForcedUnwrapAssumption(assumption))
	}
	@inlinable public func forceUnwrapBecauseTested()  -> Wrapped { forceUnwrap(because: .tested) }
	@inlinable public func forceUnwrapBecauseCreated() -> Wrapped { forceUnwrap(because: .created) }
	@inlinable public func forceUnwrapBecauseSet()     -> Wrapped { forceUnwrap(because: .set) }
	/// Force-unwraps an optional that is expected to be a fetched property on an
	/// NSManagedObject, crashing with a clear message if it is unexpectedly nil.
	///
	/// Use this when accessing Core Data fetched properties that should be present
	/// after a fetch. If the value is nil, the program terminates with a detailed
	/// explanation indicating that the managed object’s fetched property was
	/// expected to be available.
	///
	/// - Returns: The non-optional wrapped value.
	/// - Precondition: The optional represents a Core Data fetched property that
	///   should have been loaded and must not be nil at this point.
	/// - Important: Prefer safe unwrapping (`if let`, `guard let`) where the value
	///   can legitimately be absent. Reserve this for cases where nil indicates a
	///   programming error or data model inconsistency.
	/// - SeeAlso: ``OptionalForcedUnwrapAssumption/managedObjectFetchedProperty``
	@inlinable public func forceUnwrapManagedObjectField() -> Wrapped {
		forceUnwrap(because: .managedObjectFetchedProperty)
	}
}

/// A lightweight, sendable wrapper that captures the reason (assumption) behind
/// force-unwrapping an `Optional`.
///
/// Use this type to make intentional force-unwrapping explicit and self-documenting.
/// By providing a clear `assumption`, failures become easier to diagnose if a value
/// unexpectedly turns out to be `nil` at runtime.
/// - Precondition:
///   When a force unwrap is justified, choose the most fitting built-in assumption
///   or supply a clear, actionable custom message.
/// - Postcondition:
///   You typically pass an instance of this type to `Optional/forceUnwrap(because:)`.
///   If the optional is `nil`, the assumption’s text is included in the fatal error
///   message, helping you trace and explain the rationale behind the force unwrap.
/// - Experiment:
///   ```swift
///   let value: String? = fetchImportantString()
///   let unwrapped = value.forceUnwrap(because: .tested)
///   ```
///   You can construct custom assumptions using string literals:
///   ```swift
///   let customReason: OptionalForcedUnwrapAssumption = "Guaranteed by earlier validation step"
///   let unwrapped = value.forceUnwrap(because: customReason)
///   ```
///   Though it's better to use string literals directly in `Optional/forceUnwrap(because:)` call:
///   ```swift
///   let a: Int? = nil
///   let b = a.forceUnwrap(because: "I thought it can never become nil")
///   ```
/// - SeeAlso:
///   ## Built-in assumptions
///   | Assumption | Description |
///   |------------|-------------|
///   |``OptionalForcedUnwrapAssumption/tested``| The value was previously checked (e.g., via an `if let` or `guard`).|
///   |``OptionalForcedUnwrapAssumption/created``| The value is initialized in the same context and is expected to be non-`nil`.|
///   |``OptionalForcedUnwrapAssumption/set``| The value was just assigned and is expected to be present.|
///   |``OptionalForcedUnwrapAssumption/managedObjectFetchedProperty``| The value should be available on an `NSManagedObject` as a fetched property.|
///   ## Relationships
///   | Conforms To | Description |
///   |-------------|-------------|
///   |``Swift/ExpressibleByStringLiteral``| Create assumptions directly from string literals.|
///   |``Swift/CustomStringConvertible``| The underlying message is used as the description.|
///   |`Sendable`| Safe to use across concurrency domains.|
/// - Important: Prefer using this type over bare `!` force unwraps to make intent explicit.
public struct OptionalForcedUnwrapAssumption: ExpressibleByStringLiteral,
											  CustomStringConvertible,
											  Sendable {
	public let value: String
	public init(_ value: String) { self.value = value }
	public init(stringLiteral value: String) { self.value = value }
	@inlinable public var description: String { value }
	
	public static let tested  =
		OptionalForcedUnwrapAssumption("Was tested with `if` statement")
	public static let `created` =
		OptionalForcedUnwrapAssumption("Is initialized right here with value")
	public static let set =
		OptionalForcedUnwrapAssumption("Value was just set")
	public static let managedObjectFetchedProperty =
		OptionalForcedUnwrapAssumption("NSManagedObject should have this field fetched")
}
