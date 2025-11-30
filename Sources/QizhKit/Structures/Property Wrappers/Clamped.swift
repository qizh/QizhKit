//
//  Clamped.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.01.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// A property wrapper that clamps a comparable value to a provided closed range.
///
/// Use `Clamped` when you want to guarantee that a value never falls below
/// a minimum or rises above a maximum. Any assignment outside the specified
/// range is coerced to the nearest bound.
///
/// - Requires:
///   ### Generic Parameter:
///   - `Value`: A type that conforms to `Comparable`.
/// - Note:
///   ### Behavior
///   - Reading `wrappedValue` returns the current, already-clamped value.
///   - Setting `wrappedValue` applies the following to ensure it remains
///     within the provided `range`:
///     ```swift
///     min(max(newValue, range.lowerBound), range.upperBound)
///     ```
///   ### Typical use cases
///   - Enforcing valid limits for pagination (e.g., page size `1...100`).
///   - Constraining UI-related values (e.g., line width, corner radius).
///   - Keeping domain values within safe operating bounds (e.g., temperature thresholds).
///   ### Thread Safety
///   This wrapper does not synchronize access.
///   If used from multiple threads, coordinate access externally.
/// - Complexity:
///   Clamping is `O(1)` and performed on every set.
/// - SeeAlso:
///   - ``ZeroOneClamped`` for clamping to the normalized range `0...1`.
/// - Experiment:
///   ```swift
///   struct Paginator {
///       @Clamped(range: 1...100) var pageSize: Int = 10
///       /// `pageSize` is always between `1` and `100`
///   }
///
///   func getMessages(@Clamped(range: 1...100) limit: UInt = 10) -> [Message] {
///       /// `limit` will always be clamped to `1...100`
///       []
///   }
///   ```
@propertyWrapper
public struct Clamped<Value: Comparable> {
	private var value: Value
	private let range: ClosedRange<Value>
	
	/// The clamped value exposed by the property wrapper.
	///
	/// ### Get
	///   Returns the current value after being constrained to the allowed range.
	///   - For ``Clamped``, the value is guaranteed to lie within the provided `ClosedRange`.
	///   - For ``ZeroOneClamped``, the value is guaranteed to lie within `0...1`.
	/// ### Set
	///   Assigning a new value will clamp it to the valid bounds:
	///   - ``Clamped``
	///     ```swift
	///     min(max(newValue, range.lowerBound), range.upperBound)
	///     ```
	///   - ``ZeroOneClamped``
	///     ```swift
	///     min(max(newValue, 0), 1)
	///     ```
	/// - Complexity: `O(1)`
	/// - Invariant: Use this property as you would the original variable.
	///   The wrapper ensures the invariant that the value never exceeds the specified limits.
	public var wrappedValue: Value {
		get { value }
		set { value = min(max(newValue, range.lowerBound), range.upperBound) }
	}
	
	/// Creates a clamped property wrapper with an initial value and a closed range.
	///
	/// The provided `wrappedValue` is immediately clamped into `range`,
	/// ensuring the stored value always lies within the specified bounds.
	/// Subsequent assignments are also clamped.
	/// - Parameters:
	///   - wrappedValue: The initial value to store.
	///     - If it falls below `range.lowerBound` or above `range.upperBound`,
	///       it is coerced to the nearest bound.
	///   - range: The closed range that defines the valid bounds for the value.
	/// - Invariant: The stored value will always satisfy `range.contains(value)`.
	/// - Complexity: `O(1)`
	/// - Experiment:
	///   ```swift
	///   struct Paginator {
	///   	@Clamped(range: 1...100) var pageSize: Int = 250
	///   	/// `pageSize == 100` after initialization
	///   }
	///   ```
	///
	///   ``` swift
	///   func getMessages(
	///   	@Clamped(range: 1...100) limit: UInt = 10
	///   ) -> [Message] {
	///   	/// `limit` will always be in the range of `1...100`
	///   	/// even if other value is provided
	///   }
	///   ```
	public init(wrappedValue: Value, range: ClosedRange<Value>) {
		self.range = range
		self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
	}
}

extension Clamped: Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.wrappedValue < rhs.wrappedValue
	}
}
extension Clamped: Sendable where Value: Sendable { }
extension Clamped: Equatable where Value: Equatable { }
extension Clamped: Hashable where Value: Hashable { }


/// A property wrapper that clamps numeric values to the closed range `0...1`.
///
/// Use `ZeroOneClamped` when you want to ensure a numeric value always stays
/// within the normalized unit interval. Assignments below `0` are coerced to `0`,
/// and assignments above `1` are coerced to `1`.
///
/// - Requires:
///   - The wrapped type `Value` must conform to `Comparable` and `Numeric`.
///   - The type must support integer literals `0` and `1`.
/// - Note:
///   ### Behavior
///     - Reading `wrappedValue` returns the current clamped value.
///     - Setting `wrappedValue` applies
///       ```swift
///       min(max(newValue, 0), 1)
///       ```
///   ### Typical use cases
///     - UI properties such as opacity, progress, or volume that must remain between 0 and 1.
///     - Normalized parameters in animations or signal processing.
///     - Any domain where values are expressed as a fraction or percentage of a whole.
///   ### Thread safety
///     - This wrapper does not provide synchronization. If accessed from multiple
///       threads simultaneously, coordinate access externally.
/// - Complexity:
///   Clamping is `O(1)` and performed on every set.
/// - SeeAlso:
///   ``Clamped`` for clamping to an arbitrary `ClosedRange`.
/// - Experiment:
///   ```swift
///   @ZeroOneClamped var progress: Double = 1.5
///   /// progress == 1.0
///
///   @ZeroOneClamped var opacity: Float = -0.2
///   /// opacity == 0.0
///
///   struct Meter {
///       @ZeroOneClamped var level: Double = 0.75
///   }
///   ```
@propertyWrapper
public struct ZeroOneClamped<Value: Comparable & Numeric> {
	private var value: Value
	
	/// The clamped value exposed by the property wrapper.
	///
	/// ### Get
	///   Returns the current value after being constrained to the allowed range.
	///   - For ``Clamped``, the value is guaranteed to lie within the provided `ClosedRange`.
	///   - For ``ZeroOneClamped``, the value is guaranteed to lie within `0...1`.
	/// ### Set
	///   Assigning a new value will clamp it to the valid bounds:
	///   - ``Clamped``
	///     ```swift
	///     min(max(newValue, range.lowerBound), range.upperBound)
	///     ```
	///   - ``ZeroOneClamped``
	///     ```swift
	///     min(max(newValue, 0), 1)
	///     ```
	/// - Invariant:
	///   Use this property as you would the original variable. The wrapper ensures
	///   the invariant that the value never exceeds the specified limits.
	public var wrappedValue: Value {
		get { value }
		set { value = min(max(newValue, 0), 1) }
	}
	
	/// Creates a new `ZeroOneClamped` wrapper, clamping the provided value
	/// into the closed range `0...1`.
	///
	/// - Invariant:
	///   - Any value less than `0` is coerced to `0`.
	///   - Any value greater than `1` is coerced to `1`.
	/// - Parameter wrappedValue: The initial value to clamp into the range `0...1`.
	/// - Requires: `Value` conforms to both `Comparable` and `Numeric`,
	///   and supports integer literals `0` and `1`.
	/// - Complexity: `O(1)`
	/// - Experiment:
	///   ```swift
	///   @ZeroOneClamped var progress: Double = 1.5
	///   /// progress == 1.0
	///
	///   @ZeroOneClamped var opacity: Float = -0.2
	///   /// opacity == 0.0
	///   ```
	/// - SeeAlso: ``Clamped`` for clamping to an arbitrary `ClosedRange`.
	public init(wrappedValue: Value) {
		self.value = min(max(wrappedValue, 0), 1)
	}
}

extension ZeroOneClamped: Comparable {
	public static func < (lhs: ZeroOneClamped<Value>, rhs: ZeroOneClamped<Value>) -> Bool {
		lhs.wrappedValue < rhs.wrappedValue
	}
}

extension ZeroOneClamped: ExpressibleByFloatLiteral where Value == Double {
	public init(floatLiteral value: Value) {
		self.init(wrappedValue: value)
	}
}

extension ZeroOneClamped: ExpressibleByIntegerLiteral where Value == Int {
	public init(integerLiteral value: Value) {
		self.init(wrappedValue: value)
	}
}

extension ZeroOneClamped: Sendable where Value: Sendable { }
extension ZeroOneClamped: Equatable where Value: Equatable { }
extension ZeroOneClamped: Hashable where Value: Hashable { }
