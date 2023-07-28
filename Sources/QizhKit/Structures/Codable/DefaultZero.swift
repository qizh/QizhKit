//
//  DefaultZero.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: 0

@propertyWrapper
public struct DefaultZero <Wrapped: Numeric & Codable>: Codable {
	public var wrappedValue: Wrapped
	private let isDefault: Bool
	
	public init() {
		self.wrappedValue = .zero
		self.isDefault = true
	}
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
		self.isDefault = false
	}
	
	@inlinable public init(_ value: Wrapped) {
		self.init(wrappedValue: value)
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let wrappedValue = (try? container.decode(Wrapped.self)) {
			self.init(wrappedValue: wrappedValue)
		} else {
			self.init()
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		if isDefault {
			try container.encodeNil()
		} else {
			try container.encode(wrappedValue)
		}
	}
	
	@inlinable public static var `default`: Self { .init() }
	@inlinable public static var defaultValue: Wrapped { .zero }
	@inlinable public static var zero: Self { .init() }
}

extension DefaultZero: Equatable { }
extension DefaultZero: Hashable where Wrapped: Hashable { }

extension DefaultZero: ExpressibleByIntegerLiteral {
	@inlinable public init(integerLiteral value: Wrapped.IntegerLiteralType) {
		self.init(wrappedValue: Wrapped(integerLiteral: value))
	}
}

public extension KeyedDecodingContainer {
	func decode<T>(_: DefaultZero<T>.Type, forKey key: Key) -> DefaultZero<T> {
		(try? decodeIfPresent(DefaultZero<T>.self, forKey: key)) ?? DefaultZero<T>()
	}
}

// MARK: 1

@propertyWrapper
public struct DefaultValueOne <Wrapped: Numeric & Codable>: Codable, WithDefault {
	public var wrappedValue: Wrapped
	private let isDefault: Bool
	
	public init() {
		self.wrappedValue = Self.defaultValue
		self.isDefault = true
	}
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
		self.isDefault = false
	}
	
	@inlinable public init(_ value: Wrapped) {
		self.init(wrappedValue: value)
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let wrappedValue = (try? container.decode(Wrapped.self)) {
			self.init(wrappedValue: wrappedValue)
		} else {
			self.init()
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		if isDefault {
			try container.encodeNil()
		} else {
			try container.encode(wrappedValue)
		}
	}
	
	@inlinable public static var `default`: Self { .init() }
	@inlinable public static var defaultValue: Wrapped { .one }
	@inlinable public static var one: Self { .init() }
}

extension DefaultValueOne: Equatable { }
extension DefaultValueOne: Hashable where Wrapped: Hashable { }

extension DefaultValueOne: ExpressibleByIntegerLiteral {
	@inlinable public init(integerLiteral value: Wrapped.IntegerLiteralType) {
		self.init(wrappedValue: Wrapped(integerLiteral: value))
	}
}

public extension KeyedDecodingContainer {
	func decode<T>(_: DefaultValueOne<T>.Type, forKey key: Key) -> DefaultValueOne<T> {
		(try? decodeIfPresent(DefaultValueOne<T>.self, forKey: key)) ?? DefaultValueOne<T>()
	}
}

/*
extension Formatter {
	static let decimal: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.decimalSeparator = "."
		formatter.maximumFractionDigits = 2
		return formatter
	}()
}
*/
