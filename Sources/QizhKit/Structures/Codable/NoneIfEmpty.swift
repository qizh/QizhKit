//
//  NonEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct NoneIfEmpty <Wrapped> where Wrapped: EmptyTestable {
	public var wrappedValue: Wrapped?
	
	public init(wrappedValue: Wrapped? = .none) where Wrapped == String {
		self.wrappedValue = wrappedValue?.withLinesNSpacesTrimmed.nonEmpty
	}
	
	public init(wrappedValue: Wrapped? = .none) {
		self.wrappedValue = wrappedValue?.nonEmpty
	}
	
	public static var none: Self { .init() }
}

extension NoneIfEmpty: Codable where Wrapped: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(Wrapped.self)
		self.init(wrappedValue: value)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		if let wrappedValue {
			try container.encode(wrappedValue)
		} else {
			try container.encodeNil()
		}
		// try wrappedValue?.encode(to: encoder)
	}
}

extension NoneIfEmpty: Equatable where Wrapped: Equatable { }
extension NoneIfEmpty: Hashable where Wrapped: Hashable { }
extension NoneIfEmpty: Sendable where Wrapped: Sendable { }

extension NoneIfEmpty: WithAnyDefault where Wrapped: WithDefault { }
extension NoneIfEmpty: WithDefault where Wrapped: WithDefault {
	@inlinable public static var `default`: NoneIfEmpty<Wrapped> {
		.init(wrappedValue: Wrapped.default)
	}
}

extension NoneIfEmpty: WithAnyUnknown where Wrapped: WithUnknown { }
extension NoneIfEmpty: WithUnknown where Wrapped: WithUnknown {
	@inlinable public static var unknown: NoneIfEmpty<Wrapped> {
		.init(wrappedValue: Wrapped.unknown)
	}
}

public extension KeyedDecodingContainer {
	func decode <Wrapped: Codable> (
		_: NoneIfEmpty<Wrapped>.Type,
		forKey key: Key
	) -> NoneIfEmpty<Wrapped> {
		(try? decodeIfPresent(NoneIfEmpty<Wrapped>.self, forKey: key))
		?? NoneIfEmpty<Wrapped>()
	}
}
