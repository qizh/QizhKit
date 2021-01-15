//
//  CodeAsArray.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// A coding property wraper to use in `Codable` structs.
///	- Tag: CodeAsArray
///
/// # Encodes
/// Array containing single value.
///
/// # Decodes
/// Array of values to a single value.
///
/// - Attention:
/// Throws `DecodingError.valueNotFound` when there's no `default`
/// when decoding an empty or undefined input.
///
/// # Default
/// [Falls back](x-source-tag://KeyedDecodingContainer-CodeAsArray-Item-WithDefault)
/// to `Item.default` for empty or undefined input
/// when `Item` adopts [WithDefault](x-source-tag://WithDefault)
///
/// # Avoid Compiler Bug
/// Initialize optional types with `nil` to silence confused swift compiler error.
/// ~~~
/// @CodeAsArray var label: String? = nil
/// ~~~
///
/// - Author: [Serhii Shevchenko](mailto:zh.send@gmail.com)

@propertyWrapper public struct CodeAsArray<Item: Codable>: Codable {
	public var wrappedValue: Item
	
	public init(wrappedValue: Item) {
		self.wrappedValue = wrappedValue
	}
	
	public init <Wrapped> (wrappedValue: Item = .none) where Item == Wrapped? {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
		let array = try container.decode([Item].self)
		if array.isEmpty {
			let context = DecodingError.Context(
				codingPath: decoder.codingPath,
				debugDescription: "Found empty array where one \(Item.self) element is required"
			)
			throw DecodingError.valueNotFound(Item.self, context)
		}
		wrappedValue = array.first!
	}
	
	public init <Wrapped> (from decoder: Decoder) throws where Item == Wrapped? {
		let container = try decoder.singleValueContainer()
		let array = try container.decode([Wrapped].self)
		wrappedValue = array.first
	}
	
	public func encode(to encoder: Encoder) throws {
		try [wrappedValue].encode(to: encoder)
	}
}

extension CodeAsArray: CustomStringConvertible {
	@inlinable public var description: String { "\(wrappedValue)" }
}

public extension KeyedEncodingContainer {
	mutating func encode<Item: OptionalConvertible>(_ value: CodeAsArray<Item>, forKey key: KeyedEncodingContainer<K>.Key) throws {
		if value.wrappedValue.isSet {
			try encode([value.wrappedValue], forKey: key)
		}
	}
}

public extension KeyedDecodingContainer {
	func decode<Item>(_: CodeAsArray<Item>.Type, forKey key: Key) throws -> CodeAsArray<Item> where Item: TypedOptionalConvertible, Item.Wrapped: Codable {
		(try decodeIfPresent(CodeAsArray<Item>.self, forKey: key))
			?? CodeAsArray(wrappedValue: .none)
    }
	
	/// - Tag: KeyedDecodingContainer-CodeAsArray-Item-WithDefault
	func decode<Item>(_: CodeAsArray<Item>.Type, forKey key: Key) throws -> CodeAsArray<Item> where Item: WithDefault {
        (try decodeIfPresent(CodeAsArray<Item>.self, forKey: key))
			?? CodeAsArray(wrappedValue: Item.default)
    }
}

extension CodeAsArray: Equatable where Item: Equatable {}
extension CodeAsArray: Hashable where Item: Hashable {}

// MARK: Optional

@propertyWrapper
public struct CodeOptionalAsArray <Item: Codable>: Codable {
	public var wrappedValue: Item?
	
	public init(wrappedValue: Item? = .none) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let array = try container.decode([Item].self)
		wrappedValue = array.first
	}
	
	public func encode(to encoder: Encoder) throws {
		try [wrappedValue].encode(to: encoder)
	}
	
	public static var none: Self {
		.init()
	}
}

extension CodeOptionalAsArray: Equatable where Item: Equatable {}
extension CodeOptionalAsArray: Hashable where Item: Hashable {}

extension CodeOptionalAsArray: CustomStringConvertible {
	@inlinable public var description: String { "\(wrappedValue.orNilString)" }
}
