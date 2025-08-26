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

@CaseName @IsCase
public enum Activation: Hashable, Sendable {
	case on
	case off
}

extension Activation {
	public init(_ isActive: Bool) {
		if isActive {
			self = .on
		} else {
			self = .off
		}
	}
}

extension Activation {
	@inlinable public static func == (lhs: Activation, rhs: Bool) -> Bool {
		lhs.asBool == rhs
	}
	
	public static func != (lhs: Activation, rhs: Bool) -> Bool {
		lhs.asBool != rhs
	}

	@inlinable prefix public static func ! (a: Activation) -> Activation {
		a.toggled
	}
	
	public static func && (
		lhs: Activation,
		rhs: @autoclosure () throws -> Activation
	) rethrows -> Activation {
		try Activation(lhs.asBool && rhs().asBool)
	}
	
	public static func || (
		lhs: Activation,
		rhs: @autoclosure () throws -> Activation
	) rethrows -> Activation {
		try Activation(lhs.asBool || rhs().asBool)
	}
}

extension Activation {
	@inlinable public var toggled: Self {
		switch self {
		case .on: .off
		case .off: .on
		}
	}
	
	@inlinable public mutating func toggle() {
		self = self.toggled
	}
	
	@inlinable public var asBool: Bool {
		rawValue
	}
	
	@inlinable public var asInt: Int {
		switch self {
		case .on: 1
		case .off: 0
		}
	}
	
	@inlinable public var asUInt: Int {
		switch self {
		case .on: 1
		case .off: 0
		}
	}
	
	@inlinable public var asDouble: Double {
		switch self {
		case .on: 1.0
		case .off: 0.0
		}
	}
	
	@inlinable public var asCGFloat: CGFloat {
		asDouble
	}
}

extension Activation: Codable {
	@inlinable public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(Bool.self)
		self.init(value)
	}
	
	@inlinable public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(asBool)
	}
}

extension Activation: CustomStringConvertible {
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
	
	@inlinable public var description: String {
		caseName
	}
}

extension Activation: LosslessStringConvertible {
	public init?(_ description: String) {
		switch description.localizedLowercase {
		case "true", "1", "yes", "t", "enabled", "on": 		self = .on
		case "false", "0", "no", "f", "disabled", "off": 	self = .off
		default: 											return nil
		}
	}
}

extension Activation: RawRepresentable {
	@inlinable public init(rawValue: Bool) {
		self.init(rawValue)
	}
	
	@inlinable public var rawValue: Bool {
		switch self {
		case .on: true
		case .off: false
		}
	}
}

extension Activation: ExpressibleByBooleanLiteral {
	@inlinable public init(booleanLiteral value: Bool) {
		self.init(value)
	}
}

extension Binding where Value == Activation {
	public func toggle() {
		wrappedValue = wrappedValue.toggled
	}
}

extension DefaultStringInterpolation {
	@inlinable public mutating func appendInterpolation(
		_ value: Activation,
		format: OSLogBoolFormat? = nil
	) {
		appendInterpolation(value.description(format: format))
	}
}
