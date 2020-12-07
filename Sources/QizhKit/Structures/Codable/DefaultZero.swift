//
//  DefaultZero.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultZero <Wrapped: Numeric & Codable>: Codable {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
	}
	
	public init(_ value: Wrapped = Self.defaultValue) {
		self.wrappedValue = value
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? Self.defaultValue
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
	
	public static var `default`: Self { .init() }
	public static var defaultValue: Wrapped { .zero }
	public static var zero: Self { .init() }
}

@propertyWrapper
public struct DefaultValueOne <Wrapped: Numeric & Codable>: Codable, WithDefault {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
	}
	
	public init(_ value: Wrapped = Self.defaultValue) {
		self.wrappedValue = value
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? Self.defaultValue
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
	
	public static var `default`: Self { .init() }
	public static var defaultValue: Wrapped { .one }
	public static var one: Self { .init() }
}

extension DefaultZero: Equatable where Wrapped: Equatable { }
extension DefaultZero: Hashable where Wrapped: Hashable { }
extension DefaultValueOne: Equatable where Wrapped: Equatable { }
extension DefaultValueOne: Hashable where Wrapped: Hashable { }

public extension KeyedDecodingContainer {
	func decode<T>(_: DefaultZero<T>.Type, forKey key: Key) -> DefaultZero<T> {
		(try? decodeIfPresent(DefaultZero<T>.self, forKey: key)) ?? DefaultZero<T>()
	}
	
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
