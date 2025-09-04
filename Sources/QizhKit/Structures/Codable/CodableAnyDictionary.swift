//
//  CodableAnyDictionary.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// A property wrapper that stores a heterogeneous, JSON-compatible dictionary
/// keyed by `String` with values constrained to `any Sendable`,
/// and provides Codable conformance using custom Any/Sendable helpers.
/// - Notes:
///   - Decoding relies on JSONCodingKeys and extensions that decode
///     `Dictionary<String, any Sendable>` from JSON.
///   - Encoding uses a keyed container with JSONCodingKeys and encodes
///     each value via `AnyEncodable`.
@propertyWrapper
public struct CodableAnyDictionary: ExpressibleByDictionaryLiteral, EmptyProvidable, Sendable {
	/// The underlying heterogeneous dictionary.
	public var wrappedValue: [String: any Sendable]
	
	/// Creates an empty or pre-filled heterogeneous dictionary.
	/// - Parameter wrappedValue: Initial dictionary value. Defaults to `.empty`.
	public init(wrappedValue: [String: any Sendable] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	/// Initializes from a dictionary literal with `String` keys and `any Sendable` values.
	public init(dictionaryLiteral elements: (String, any Sendable)...) {
		self.wrappedValue = .init(uniqueKeysWithValues: elements)
	}
	
	/// Convenience initializer to construct a wrapper from a dictionary.
	/// - Parameter value: Dictionary to wrap.
	@inlinable
	public static func some(_ value: [String: any Sendable]) -> Self {
		.init(wrappedValue: value)
	}
	
	/// An empty instance.
	public static let empty: Self = .init()
}

// MARK: Codable

extension CodableAnyDictionary: Codable {
	/// Decodes a heterogeneous dictionary from a keyed container using JSONCodingKeys.
	/// - Parameter decoder: The decoder to read data from.
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: JSONCodingKeys.self)
		self.wrappedValue = try container.decode([String: any Sendable].self)
		/*
		let dictionary = try container.decode([String: Any].self)
		var finalDictionary: [String: AnyHashable] = .empty
		for (key, value) in dictionary {
			if let hashableValue = value as? (any Hashable) {
				finalDictionary[key] = AnyHashable(hashableValue)
			}
		}
		self.wrappedValue = finalDictionary
		*/
	}
	
	/// Encodes the heterogeneous dictionary as a keyed container using JSONCodingKeys.
	/// Empty dictionaries are not encoded (no-op).
	/// - Parameter encoder: The encoder to write data to.
	public func encode(to encoder: Encoder) throws {
		guard wrappedValue.isNotEmpty else { return }
		var container = encoder.container(keyedBy: JSONCodingKeys.self)
		try container.encode(wrappedValue)
	}
}

/// Convenience decoding for `CodableAnyDictionary` that returns `.empty` if the key is
/// missing or decoding fails.
/// - Parameter key: The decoding key.
/// - Returns: Decoded value or `.empty`.
public extension KeyedDecodingContainer {
	func decode(_: CodableAnyDictionary.Type, forKey key: Key) -> CodableAnyDictionary {
		(try? decodeIfPresent(CodableAnyDictionary.self, forKey: key))
			?? .empty
	}
}

// MARK: Encodable -> Dictionary

public extension Encodable {
	/// Encodes `self` to JSON and decodes it back as a heterogeneous dictionary
	/// (`[String: any Sendable]`) using the custom Any/Sendable helpers.
	/// - Parameters:
	///   - encoder: JSONEncoder to use. Defaults to a new instance.
	///   - decoder: JSONDecoder to use. Defaults to a new instance.
	/// - Returns: A heterogeneous dictionary representation or `.empty` on failure.
	func asDictionary(
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) -> [String: any Sendable] {
		do {
			let data = try encoder.encode(self)
			let dictionary = try decoder.decode(CodableAnyDictionary.self, from: data)
			return dictionary.wrappedValue
		} catch {
			return .empty
		}
	}
}

// MARK: - CodableAnyArray

/// A property wrapper that stores a heterogeneous, JSON-compatible array
/// with elements constrained to `any Sendable`,
/// and provides Codable conformance using custom Any/Sendable helpers.
/// - Notes:
///   - Decoding relies on extensions that decode `Array<any Sendable>` from JSON.
///   - Encoding uses an unkeyed container and encodes each element via `AnyEncodable`.
@propertyWrapper
public struct CodableAnyArray: ExpressibleByArrayLiteral, EmptyProvidable, Sendable {
	/// The underlying heterogeneous array.
	public var wrappedValue: [any Sendable]
	
	/// Creates an empty or pre-filled heterogeneous array.
	/// - Parameter wrappedValue: Initial array value. Defaults to `.empty`.
	public init(wrappedValue: [any Sendable] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	/// Initializes from an array literal of `any Sendable` elements.
	public init(arrayLiteral elements: any Sendable...) {
		self.wrappedValue = elements
	}
	
	/// Convenience initializer to construct a wrapper from an array.
	/// - Parameter value: Array to wrap.
	@inlinable
	public static func some(_ value: [any Sendable]) -> Self {
		.init(wrappedValue: value)
	}
	
	/// An empty instance.
	public static let empty: Self = .init()
}

// MARK: Codable

extension CodableAnyArray: Codable {
	/// Decodes a heterogeneous array from an unkeyed container.
	/// - Parameter decoder: The decoder to read data from.
	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		self.wrappedValue = try container.decode([any Sendable].self)
	}
	
	/// Encodes the heterogeneous array as an unkeyed container.
	/// Empty arrays are not encoded (no-op).
	/// - Parameter encoder: The encoder to write data to.
	public func encode(to encoder: Encoder) throws {
		guard wrappedValue.isNotEmpty else { return }
		var container = encoder.unkeyedContainer()
		try container.encode(wrappedValue)
	}
}

/// Convenience decoding for `CodableAnyArray` that returns `.empty` if the key is missing
/// or decoding fails.
/// - Parameter key: The decoding key.
/// - Returns: Decoded value or `.empty`.
public extension KeyedDecodingContainer {
	func decode(_: CodableAnyArray.Type, forKey key: Key) -> CodableAnyArray {
		(try? decodeIfPresent(CodableAnyArray.self, forKey: key))
			?? .empty
	}
}

// MARK: Encodable -> Array

public extension Encodable {
	/// Encodes `self` to JSON and decodes it back as a heterogeneous array
	/// (`[any Sendable]`) using the custom Any/Sendable helpers.
	/// - Parameters:
	///   - encoder: JSONEncoder to use. Defaults to a new instance.
	///   - decoder: JSONDecoder to use. Defaults to a new instance.
	/// - Returns: A heterogeneous array representation or `.empty` on failure.
	func asAnyArray(
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) -> [any Sendable] {
		do {
			let data = try encoder.encode(self)
			let array = try decoder.decode(CodableAnyArray.self, from: data)
			return array.wrappedValue
		} catch {
			return .empty
		}
	}
}
