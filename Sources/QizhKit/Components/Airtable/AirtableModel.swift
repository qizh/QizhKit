//
//  AirtableModel.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import os.log

// MARK: 1. Backend Model

#if DEBUG
public protocol InitializableWithJsonString: Decodable, ExpressibleByStringLiteral { }

public extension InitializableWithJsonString {
	@inlinable init(stringLiteral value: String) {
		(try? self.init(decoding: value, with: .airtable))!
	}
}

fileprivate struct TestInitializableWithJsonString: InitializableWithJsonString {
	let id: UInt
	let name: String
	
	enum CodingKeys: String, CodingKey {
		case id, name
	}
	
	static let demo: Self = "{ id: 5, name: Serhii }"
}
#else
public protocol InitializableWithJsonString: Decodable { }
#endif

fileprivate let backendModelCodingLogger = Logger(subsystem: "Coding", category: "String Literal Decoding")

extension InitializableWithJsonString {
	public init(decoding value: String, with decoder: JSONDecoder = .init()) throws {
		do {
			self = try decoder.decode(Self.self, from: Data(value.utf8))
		} catch {
			let message = """
				Failed to decode string when initializing \(Self.self)
				┗ \(error)
				"""
			backendModelCodingLogger.error("\(message)")
			print(message)
			throw error
		}
	}
}

// MARK: 1. Backend Model

/// Implements the most common model actions like
/// - Initialize with String
/// - Debug output as pretty printed JSON
/// - Default Fetcher callbacks
///
public protocol BackendModel:
	Decodable, /// `Encodable` is already in `PrettyStringConvertable`
	Hashable,
	Identifiable,
	PrettyStringConvertable,
	InitializableWithJsonString
{
	var id: ID { get }
}

// MARK: 2. Keyed Backend Model

/// In addition to `BackendModel`
/// will provide an option to get the model value by string key
public protocol KeyedBackendModel: BackendModel {
	associatedtype CodingKeys: CodingKey & CaseIterable
}

// MARK: 3. Keyed Emptyable Model

/// In addition to `KeyedBackendModel`
/// requires a model to provide an empty variant of it
public protocol KeyedEmptyableBackendModel: KeyedBackendModel, EmptyProvidable {
	
}

public extension KeyedBackendModel {
	/// Will convert model back to JSON
	/// to decode one property out of it for the key provided
	/// - Warning: **Heavy** but universal. Better create your own custom
	/// method where you get the CodingKey and switch through your keys.
	func value <T> (
		for key: String
	) -> T?
		where T: Codable,
			  T: LosslessStringConvertible
	{
		guard CodingKeys.allCases.contains(where: \.stringValue, equals: key),
			  let data = try? JSONEncoder().encode(self)
		else { return .none }
		return try? KeyDecoder.decodeConverting(to: T.self, from: data, by: key)
	}
}

// MARK: 4. Rails Model

/// In addition to `KeyedEmptyableBackendModel`
/// provides some default Fetcher callbacks and default responses
public protocol RailsModel: KeyedEmptyableBackendModel {
	
}

/// In case the model is a wrapper or a submit model
/// and there's no id in it
extension RailsModel {
	public var id: UInt8 { 0 }
}

public struct RailsResponse <Item: Codable>: Codable {
	public let status: Int
	public let message: String
	public let data: Item
}

public struct RailsLossyResponses <Item: Codable>: Codable {
	public let status: Int
	public let message: String
	@LossyArray public var data: [Item]
}

/// Used in ``Fetcher``
public struct RailsStrictResponses <Item: Codable>: Codable {
	public let status: Int
	public let message: String
	public var data: [Item]
}

// MARK: Airtable

/// Used in ``Fetcher``
public struct AirtableRecords<Item: Codable>: Codable {
	public let records: [Item]
	
	public init(_ records: Item ...) {
		self.records = records
	}
	
	public init(_ records: [Item]) {
		self.records = records
	}
}

public protocol AirtableModelFields:
	Decodable, /// `Encodable` is already in `PrettyStringConvertable`
	Hashable,
	PrettyStringConvertable
{
	associatedtype CodingKeys: CodingKey & CaseIterable
}

/// Used in ``Fetcher``
@dynamicMemberLookup
public protocol AirtableModel: BackendModel, EmptyProvidable {
	associatedtype Fields: AirtableModelFields
	var fields: Fields { get }
	var createdTime: Date { get }
	
	subscript<T>(dynamicMember key: KeyPath<Fields, T>) -> T { get }
}

#if DEBUG
extension Array: /* @retroactive */ ExpressibleByStringLiteral,
				 /* @retroactive */ ExpressibleByUnicodeScalarLiteral,
				 /* @retroactive */ ExpressibleByExtendedGraphemeClusterLiteral,
				 InitializableWithJsonString where Element: Decodable {
	
	public init(stringLiteral value: String) {
		(try? self.init(decoding: value, with: .airtable))!
	}
	
	public init(unicodeScalarLiteral value: String) { self.init(stringLiteral: value) }
	public init(extendedGraphemeClusterLiteral value: String) { self.init(stringLiteral: value) }
}
#endif

public extension AirtableModel {
	var createdTime: Date { .reference0 }
	
	subscript<T>(dynamicMember key: KeyPath<Fields, T>) -> T {
		fields[keyPath: key]
	}
}

/// In case the model is a wrapper or a submit model
/// and there's no id in it
extension AirtableModel {
	public var id: UInt8 { 0 }
}

// MARK: Key Decoder
/// for KeyedBackendModel

public struct KeyDecoder {
	private static let userInfoKey = CodingUserInfoKey(rawValue: "key")!
	
	// MARK: Direct
	
	private struct SingleKeyWrapper <Wrapped: Decodable>: Decodable {
		var wrappedValue: Wrapped
		
		init(from decoder: Decoder) throws {
			let keyName = decoder.userInfo[KeyDecoder.userInfoKey] as! String
			let key = JSONCodingKeys(stringValue: keyName)
			let values = try decoder.container(keyedBy: JSONCodingKeys.self)
			wrappedValue = try values.decode(Wrapped.self, forKey: key)
		}
	}
	
	public static func decode <T: Decodable> (
		_ type: T.Type,
		from data: Data,
		by key: String,
		using decoder: JSONDecoder = .init()
	) throws -> T {
		decoder.userInfo[KeyDecoder.userInfoKey] = key
		let model = try decoder.decode(SingleKeyWrapper<T>.self, from: data).wrappedValue
		return model
	}
	
	// MARK: Convertable
	
	private struct SingleKeyConvertableWrapper <Wrapped: Codable & LosslessStringConvertible>: Decodable {
		@AutoTypeCodable var wrappedValue: Wrapped
		
		init(from decoder: Decoder) throws {
			let keyName = decoder.userInfo[KeyDecoder.userInfoKey] as! String
			let key = JSONCodingKeys(stringValue: keyName)
			let values = try decoder.container(keyedBy: JSONCodingKeys.self)
			_wrappedValue = try values.decode(AutoTypeCodable<Wrapped>.self, forKey: key)
		}
	}
	
	public static func decodeConverting <T: Codable & LosslessStringConvertible> (
		to type: T.Type,
		from data: Data,
		by key: String,
		using decoder: JSONDecoder = .init()
	) throws -> T {
		decoder.userInfo[KeyDecoder.userInfoKey] = key
		let model = try decoder.decode(SingleKeyConvertableWrapper<T>.self, from: data).wrappedValue
		return model
	}
}
