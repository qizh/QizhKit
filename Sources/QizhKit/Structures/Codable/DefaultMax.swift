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
	
	@inlinable public static var `default`: Wrapped { .max }
	
	public init(wrappedValue: Wrapped = Self.default) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? Self.default
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
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
