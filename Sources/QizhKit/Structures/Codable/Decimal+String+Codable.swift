//
//  Decimal+String+Codable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.08.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct AsString <Wrapped: LosslessStringConvertible>: Codable, LosslessStringConvertible {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
	}
	
	public init?(_ description: String) {
		if let value = Wrapped(description) {
			self.init(wrappedValue: value)
		} else {
			return nil
		}
	}
	
	@inlinable
	public var description: String { wrappedValue.description }
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let stringValue = try container.decode(String.self)
		if let value = Wrapped(stringValue) {
			self.wrappedValue = value
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Can't create \(Wrapped.self) from `\(stringValue)` string")
		}
	}
	
	@inlinable
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.description.encode(to: encoder)
	}
}

extension AsString: Equatable where Wrapped: Equatable { }
extension AsString: Hashable where Wrapped: Hashable { }

extension KeyedDecodingContainer {
	public func decode<T>(_: AsString<T>.Type, forKey key: Key) throws -> AsString<T> {
		if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
			if let value = AsString<T>(stringValue) {
				return value
			} else {
				throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "Can't initialize \(T.self) with string `\(stringValue)`"))
			}
		} else {
			throw DecodingError.valueNotFound(String.self, .init(codingPath: codingPath, debugDescription: "String value not found for key \(key)"))
		}
	}
	
	public func decode<T>(_: AsString<T>.Type, forKey key: Key) throws -> AsString<T>
		where T: TypedOptionalConvertible, T.Wrapped: Codable
	{
		if let stringValue = try? decodeIfPresent(String.self, forKey: key),
		   let value = AsString<T>(stringValue) {
			return value
		} else {
			return .init(wrappedValue: .none)
		}
	}
}

extension Decimal: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension Decimal: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension Decimal: @retroactive ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = Decimal(string: value) ?? Decimal.zero
	}
}
