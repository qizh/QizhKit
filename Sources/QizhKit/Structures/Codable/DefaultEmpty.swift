//
//  DefaultEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultEmpty<Wrapped> where Wrapped: EmptyProvidable, Wrapped: Equatable {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped = .empty) {
		self.wrappedValue = wrappedValue
	}
}

extension DefaultEmpty: Codable where Wrapped: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? .empty
	}
	
	public func encode(to encoder: Encoder) throws {
		if wrappedValue == .empty {
			var container = encoder.singleValueContainer()
			try container.encodeNil()
		} else {
			try wrappedValue.encode(to: encoder)
		}
	}
}

extension DefaultEmpty: Equatable where Wrapped: Equatable { }
extension DefaultEmpty: Hashable where Wrapped: Hashable { }

extension DefaultEmpty: WithDefault {
	@inlinable public static var `default`: DefaultEmpty<Wrapped> { .init() }
}

extension DefaultEmpty: EmptyProvidable {
	@inlinable public static var empty: DefaultEmpty<Wrapped> { .init() }
}

public extension KeyedDecodingContainer {
	func decode <Wrapped: Codable> (_: DefaultEmpty<Wrapped>.Type, forKey key: Key) -> DefaultEmpty<Wrapped> {
		(try? decodeIfPresent(DefaultEmpty<Wrapped>.self, forKey: key))
			?? DefaultEmpty<Wrapped>()
	}
}
