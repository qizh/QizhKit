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
	
	@inlinable public static var defaultValue: Wrapped { Wrapped.random(in: .min ... .max) }
	@inlinable public static var zero: Self { .init(wrappedValue: .zero) }
	
	public init(wrappedValue: Wrapped = Self.defaultValue) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		guard let value = try? decoder.singleValueContainer().decode(Wrapped.self) else {
			wrappedValue = Self.defaultValue
			return
		}
		wrappedValue = value
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension DefaultRandom: ExpressibleByIntegerLiteral where Wrapped: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Wrapped.IntegerLiteralType) {
		self.wrappedValue = Wrapped(integerLiteral: value)
	}
}

extension DefaultRandom: Equatable where Wrapped: Equatable { }
extension DefaultRandom: Hashable where Wrapped: Hashable { }

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
