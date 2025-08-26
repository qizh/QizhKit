//
//  Activation.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import QizhMacroKit
public import enum os.OSLogBoolFormat

// MARK: Activation Enum

/// Represents a binary activation state,
/// typically used to indicate `on` or `off` conditions.
@CaseName @IsCase
public enum Activation: Hashable, Sendable {
	case on
	case off
}

// MARK: Activation Convenience Initializer

extension Activation {
	/// Initializes an `Activation` instance from a `Bool`.
	/// - Parameter isActive: A Boolean value
	/// 	where `true` maps to `.on`
	/// 	and `false` maps to `.off`.
	public init(_ isActive: Bool) {
		if isActive {
			self = .on
		} else {
			self = .off
		}
	}
}

// MARK: Activation Boolean and Logical Operators

extension Activation {
	/// Compares an `Activation` instance with a `Bool` for equality.
	/// - Parameters:
	///   - lhs: The `Activation` instance.
	///   - rhs: The `Bool` value.
	/// - Returns: `true` if `lhs`'s boolean representation equals `rhs`;
	/// 			otherwise, `false`.
	@inlinable public static func == (lhs: Activation, rhs: Bool) -> Bool {
		lhs.asBool == rhs
	}
	
	/// Compares an `Activation` instance with a `Bool` for inequality.
	/// - Parameters:
	///   - lhs: The `Activation` instance.
	///   - rhs: The `Bool` value.
	/// - Returns: `true` if `lhs`'s boolean representation does not equal `rhs`;
	/// 			otherwise, `false`.
	public static func != (lhs: Activation, rhs: Bool) -> Bool {
		lhs.asBool != rhs
	}

	/// Returns the toggled value of the given `Activation`.
	/// - Parameter a: The `Activation` instance.
	/// - Returns: The opposite activation state.
	@inlinable prefix public static func ! (a: Activation) -> Activation {
		a.toggled
	}
	
	/// Logical AND operation between two `Activation` values.
	/// - Parameters:
	///   - lhs: The left-hand side `Activation`.
	///   - rhs: The right-hand side `Activation` (autoclosure).
	/// - Returns: An `Activation` representing the logical AND of the two values.
	public static func && (
		lhs: Activation,
		rhs: @autoclosure () throws -> Activation
	) rethrows -> Activation {
		try Activation(lhs.asBool && rhs().asBool)
	}
	
	/// Logical OR operation between two `Activation` values.
	/// - Parameters:
	///   - lhs: The left-hand side `Activation`.
	///   - rhs: The right-hand side `Activation` (autoclosure).
	/// - Returns: An `Activation` representing the logical OR of the two values.
	public static func || (
		lhs: Activation,
		rhs: @autoclosure () throws -> Activation
	) rethrows -> Activation {
		try Activation(lhs.asBool || rhs().asBool)
	}
}

// MARK: Activation Convenience Properties & Methods

extension Activation {
	/// Returns the toggled activation state.
	@inlinable public var toggled: Self {
		switch self {
		case .on: .off
		case .off: .on
		}
	}
	
	/// Toggles the current activation state in place.
	@inlinable public mutating func toggle() {
		self = self.toggled
	}
	
	/// Returns the `Boolean` representation of the activation state.
	@inlinable public var asBool: Bool {
		rawValue
	}
	
	/// Returns the `Int` representation of the activation state
	/// (`1` for `.on`, `0` for `.off`).
	@inlinable public var asInt: Int {
		switch self {
		case .on: 1
		case .off: 0
		}
	}
	
	/// Returns the `UInt` representation of the activation state
	/// (`1` for `.on`, `0` for `.off`).
	@inlinable public var asUInt: Int {
		switch self {
		case .on: 1
		case .off: 0
		}
	}
	
	/// Returns the `Double` representation of the activation state
	/// (`1.0` for `.on`, `0.0` for `.off`).
	@inlinable public var asDouble: Double {
		switch self {
		case .on: 1.0
		case .off: 0.0
		}
	}
	
	/// Returns the `CGFloat` representation of the activation state.
	@inlinable public var asCGFloat: CGFloat {
		asDouble
	}
}

// MARK: Codable Conformance

extension Activation: Codable {
	/// Initializes an `Activation` instance from a decoder
	/// by decoding a single `Bool` value.
	/// - Parameter decoder: The decoder to read data from.
	/// - Throws: An error if reading from the decoder or decoding fails.
	@inlinable public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(Bool.self)
		self.init(value)
	}
	
	/// Encodes the `Activation` instance as a single `Bool` value.
	/// - Parameter encoder: The encoder to write data to.
	/// - Throws: An error if encoding fails.
	@inlinable public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(asBool)
	}
}

// MARK: CustomStringConvertible

extension Activation: CustomStringConvertible {
	/// Returns a string representation of the activation state based on the given format.
	/// - Parameter format: The optional `OSLogBoolFormat` specifying the output format. Supported formats:
	///   - `.truth`: Returns `"true"` for `.on`, `"false"` for `.off`
	///   - `.answer`: Returns `"yes"` for `.on`, `"no"` for `.off`
	///   - `nil` or any other: Returns the case name (`"on"` or `"off"`)
	/// - Returns: A string representing the activation state according to the specified format.
	///
	/// | format/value | `.on`    | `.off`   |
	/// |--------------|----------|----------|
	/// | `.truth`     | `"true"` | `"false"`|
	/// | `.answer`    | `"yes"`  | `"no"`   |
	/// | `nil`/other  | `"on"`   | `"off"`  |
	public func description(format: OSLogBoolFormat?) -> String {
		switch format {
		case .some(.truth):
			switch self {
			case .on: "true"
			case .off: "false"
			}
		case .some(.answer):
			switch self {
			case .on: "yes"
			case .off: "no"
			}
		case .some(_), .none: caseName
		}
	}
	
	/// Returns the default string representation (the case name) of the activation state.
	/// - For `.on`, returns `"on"`.
	/// - For `.off`, returns `"off"`.
	@inlinable public var description: String {
		caseName
	}
}

// MARK: LosslessStringConvertible

extension Activation: LosslessStringConvertible {
	/// Initializes an `Activation` from a string representation.
	///
	/// **Accepted string values:**
	///
	/// - Produces `.on` (case-insensitive):
	///   - `"true", "1", "yes", "t", "enabled", "on"`
	/// - Produces `.off` (case-insensitive):
	///   - `"false", "0", "no", "f", "disabled", "off"`
	///
	/// Any other value will result in `nil`.
	/// - Parameter description: The string representation of the activation state.
	/// - Returns: An optional `Activation` if the string matches a known state;
	/// 			otherwise, `nil`.
	public init?(_ description: String) {
		switch description.localizedLowercase {
		case "true", "1", "yes", "t", "enabled", "on": 		self = .on
		case "false", "0", "no", "f", "disabled", "off": 	self = .off
		default: 											return nil
		}
	}
}

// MARK: RawRepresentable

extension Activation: RawRepresentable {
	/// Initializes an `Activation` from a raw `Bool` value.
	/// - Parameter rawValue: The raw boolean value.
	@inlinable public init(rawValue: Bool) {
		self.init(rawValue)
	}
	
	/// The raw boolean value representing the activation state.
	@inlinable public var rawValue: Bool {
		switch self {
		case .on: true
		case .off: false
		}
	}
}

// MARK: ExpressibleByBooleanLiteral

extension Activation: ExpressibleByBooleanLiteral {
	/// Initializes an `Activation` instance from a boolean literal.
	/// - Parameter value: The boolean literal value.
	@inlinable public init(booleanLiteral value: Bool) {
		self.init(value)
	}
}

// MARK: Activation Binding Extension

extension Binding where Value == Activation {
	/// Toggles the wrapped `Activation` value.
	public func toggle() {
		wrappedValue = wrappedValue.toggled
	}
}

// MARK: String Interpolation

extension DefaultStringInterpolation {
	/// Appends a string representation of an `Activation` instance to the interpolation.
	/// - Parameters:
	///   - value: The `Activation` value to append.
	///   - format: An optional `OSLogBoolFormat` to format the output.
	@inlinable public mutating func appendInterpolation(
		_ value: Activation,
		format: OSLogBoolFormat? = nil
	) {
		appendInterpolation(value.description(format: format))
	}
}
