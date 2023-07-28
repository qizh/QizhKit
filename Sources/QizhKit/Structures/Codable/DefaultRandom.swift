//
//  DefaultRandom.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultRandom<Wrapped>: Codable
	where
	Wrapped: FixedWidthInteger,
	Wrapped: Codable
{
	public var wrappedValue: Wrapped
	private let isDefault: Bool
	
	@inlinable public static var defaultValue: Wrapped { Wrapped.random(in: .min ... .max) }
	@inlinable public static var zero: Self { .init(wrappedValue: .zero) }
	
	public init() {
		self.wrappedValue = Self.defaultValue
		self.isDefault = true
	}
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
		self.isDefault = false
	}
	
	public init(from decoder: Decoder) throws {
		guard let value = try? decoder.singleValueContainer().decode(Wrapped.self) else {
			self.init()
			return
		}
		self.init(wrappedValue: value)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		if isDefault {
			try container.encodeNil()
		} else {
			try container.encode(wrappedValue)
		}
	}
}

extension DefaultRandom: ExpressibleByIntegerLiteral {
	@inlinable public init(integerLiteral value: Wrapped.IntegerLiteralType) {
		self.init(wrappedValue: Wrapped(integerLiteral: value))
	}
}

extension DefaultRandom: Equatable { }
extension DefaultRandom: Hashable { }

extension DefaultRandom: WithDefault {
	@inlinable public static var `default`: DefaultRandom<Wrapped> { .init() }
}

/*
public extension KeyedDecodingContainer {
	func decode<Wrapped>(_: DefaultRandom<Wrapped>.Type, forKey key: Key) -> DefaultRandom<Wrapped> {
		(try? decodeIfPresent(DefaultRandom<Wrapped>.self, forKey: key))
			?? DefaultMax<Wrapped>()
	}
}
*/
