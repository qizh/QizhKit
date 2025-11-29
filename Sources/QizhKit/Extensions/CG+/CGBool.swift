//
//  CGBool.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.11.2025.
//

import Foundation

/// A lightweight, `Sendable` and `Hashable` wrapper that represents
/// a Core Graphics–style boolean as a `Double`.
///
/// - Understanding `CGBool`:
///
///   `CGBool` bridges the gap between traditional boolean semantics and continuous values
///   used in graphics, animation, and shader-like computations. It stores a `Double` where:
///   - `1.0` represents `true`
///   - `0.0` represents `false`
///   - Any other value can be treated as a soft/weighted truthiness
///     for blending and interpolation.
///
/// - Key features:
///   - Expressible by boolean and float literals for ergonomic initialization.
///   - Provides a `toggledValue` computed property that mirrors boolean negation
///     (`1.0 - value`).
///   - Custom equality with `Bool` that treats any non-zero `value` as `true`.
///
/// - Typical use cases:
///   - Layer opacity or visibility masks where a boolean concept needs to participate
///     in interpolation.
///   - Transition progress gates (e.g., `0.0` to `1.0`)
///     that also map cleanly to boolean logic.
///   - Graphics or animation pipelines where scalar math is preferred
///     but boolean semantics are needed.
///
/// - Behavior:
///   - When initialized with a `Bool`, the underlying `value` becomes:
///     - `1.0` for `true`.
///     - `0.0` for `false`.
///   - When initialized with a `Double`, the value is used as-is.
///     - Any non-zero value is considered `true` for equality checks against `Bool`.
///   - `toggledValue` computes `1.0 - value`,
///     which corresponds to logical negation for `{0.0, 1.0}` inputs,
///     and provides a continuous inversion for intermediate values.
///   - Equality with `Bool` uses the rule `(value != 0.0) == rhs`.
///
/// - Example:
///   ```swift
///   let a: CGBool = true          /// value == 1.0
///   let b: CGBool = 0.25          /// value == 0.25 (truthy)
///   let c = CGBool.value(false)   /// value == 0.0
///
///   /// Toggle-like behavior
///   let inverted = b.toggledValue  /// 0.75
///
///   /// Boolean comparison
///   if (b == true) {
///       /// Any non-zero value is treated as true
///   }
///   ```
/// - Warning: When using non-binary values (not `0.0` or `1.0`), ensure downstream logic
///   accounts for continuous semantics rather than strict boolean behavior.
/// - SeeAlso: `ExpressibleByBooleanLiteral`, `ExpressibleByFloatLiteral`
public struct CGBool: Hashable, Sendable {
	public let value: Double
	
	public init(_ value: Double) {
		self.value = value
	}
	
	/// `1 - value`
	@inlinable public var toggledValue: Double {
		1.0 - value
	}
	
	@inlinable public static func value(_ value: Bool) -> Self {
		.init(booleanLiteral: value)
	}
	
	@inlinable public static func value(_ value: Double) -> Self {
		.init(floatLiteral: value)
	}
	
	public static func == (lhs: Self, rhs: Bool) -> Bool {
		(lhs.value != .zero) == rhs
	}
}

extension CGBool: ExpressibleByFloatLiteral {
	@inlinable public init(floatLiteral value: Double) {
		self.init(value)
	}
}

extension CGBool: ExpressibleByBooleanLiteral {
	@inlinable public init(booleanLiteral value: Bool) {
		self.init(value ? .one : .zero)
	}
}
