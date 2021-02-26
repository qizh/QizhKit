//
//  AirtableModel.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol BackendModel:
	Decodable, /// `Encodable` is already in `PrettyStringConvertable`
	Hashable,
	Identifiable,
	PrettyStringConvertable,
	ExpressibleByStringLiteral where StringLiteralType == String
{
	var id: ID { get }
}

public protocol RailsModel: BackendModel, EmptyProvidable {
	associatedtype CodingKeys: CodingKey & CaseIterable
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

public struct RailsStrictResponses <Item: Codable>: Codable {
	public let status: Int
	public let message: String
	public var data: [Item]
}

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

@dynamicMemberLookup
public protocol AirtableModel: BackendModel, EmptyProvidable {
	associatedtype Fields: AirtableModelFields
	var fields: Fields { get }
	var createdTime: Date { get }
	
	subscript<T>(dynamicMember key: KeyPath<Fields, T>) -> T { get }
}

public extension BackendModel {
	var id: UInt8 { 0 }
	
	init(stringLiteral value: String) {
		self = try! JSONDecoder.airtable.decode(Self.self, from: Data(value.utf8))
	}
	
	var debugDescription: String {
		caseName(of: Self.self, .name) + "(\(id))"
	}
}

extension Array: ExpressibleByStringLiteral,
				 ExpressibleByUnicodeScalarLiteral,
				 ExpressibleByExtendedGraphemeClusterLiteral
				 where Element: BackendModel
{
	public init(stringLiteral value: String) {
		self = try! JSONDecoder.airtable.decode(Self.self, from: Data(value.utf8))
	}
	
	@inlinable public init(unicodeScalarLiteral value: String) { self.init(stringLiteral: value) }
	@inlinable public init(extendedGraphemeClusterLiteral value: String) { self.init(stringLiteral: value) }
}

public extension AirtableModel {
	var createdTime: Date { .reference0 }
	
	subscript<T>(dynamicMember key: KeyPath<Fields, T>) -> T {
		fields[keyPath: key]
	}
}

// MARK: Get key

public extension RailsModel {
	func value <T> (
		for key: String
	) -> T?
		where T: Codable,
			  T: LosslessStringConvertible
	{
		guard CodingKeys.allCases.contains(where: \.stringValue, equals: key),
			  let data = try? JSONEncoder().encode(self)
		else { return .none }
		return try? KeyDecoder.decode(T.self, from: data, by: key)
	}
}

public struct KeyDecoder {
	private static let userInfoKey = CodingUserInfoKey(rawValue: "key")!
	
	private struct SingleKeyWrapper <Wrapped: Codable & LosslessStringConvertible>: Decodable {
		@AutoTypeCodable var wrappedValue: Wrapped
		
		init(from decoder: Decoder) throws {
			let keyName = decoder.userInfo[KeyDecoder.userInfoKey] as! String
			let key = JSONCodingKeys(stringValue: keyName)
			let values = try decoder.container(keyedBy: JSONCodingKeys.self)
			_wrappedValue = try values.decode(AutoTypeCodable<Wrapped>.self, forKey: key)
		}
	}
	
	public static func decode <T: Codable & LosslessStringConvertible> (
		_ type: T.Type,
		from data: Data,
		by key: String
	) throws -> T {
		let decoder = JSONDecoder()
		decoder.userInfo[KeyDecoder.userInfoKey] = key
		let model = try decoder.decode(SingleKeyWrapper<T>.self, from: data).wrappedValue
		return model
	}
}
