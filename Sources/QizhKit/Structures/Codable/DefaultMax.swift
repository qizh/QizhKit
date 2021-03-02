//
//  DefaultMax.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 10.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultMax<Wrapped>: Codable
	where
	Wrapped: FixedWidthInteger,
	Wrapped: Codable
{
	public var wrappedValue: Wrapped
	
	@inlinable public static var defaultValue: Wrapped { .max }
	@inlinable public static var `default`: Self { .init() }
	
	public init(wrappedValue: Wrapped = Self.defaultValue) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? Self.defaultValue
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension DefaultMax: ExpressibleByIntegerLiteral where Wrapped: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Wrapped.IntegerLiteralType) {
		self.wrappedValue = Wrapped(integerLiteral: value)
	}
}

extension DefaultMax: Equatable where Wrapped: Equatable { }
extension DefaultMax: Hashable where Wrapped: Hashable { }

public extension KeyedDecodingContainer {
	func decode<Wrapped>(_: DefaultMax<Wrapped>.Type, forKey key: Key) -> DefaultMax<Wrapped> {
		(try? decodeIfPresent(DefaultMax<Wrapped>.self, forKey: key))
			?? DefaultMax<Wrapped>()
	}
}

// MARK: Default One Day

@propertyWrapper
public struct DefaultOneDay: Codable, Hashable {
	public var wrappedValue: TimeInterval
	
	@inlinable public static var defaultValue: TimeInterval { 1.daysInterval }
	@inlinable public static var `default`: Self { .init() }
	
	public init(wrappedValue: TimeInterval = Self.defaultValue) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(TimeInterval.self)) ?? Self.defaultValue
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

public extension KeyedDecodingContainer {
	func decode(_: DefaultOneDay.Type, forKey key: Key) -> DefaultOneDay {
		(try? decodeIfPresent(DefaultOneDay.self, forKey: key))
			?? DefaultOneDay()
	}
}
