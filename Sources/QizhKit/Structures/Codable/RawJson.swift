//
//  RawJson.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.12.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct RawJson: Sendable {
	public var wrappedValue: Data
	
	public init(wrappedValue: Data = .init()) {
		self.wrappedValue = wrappedValue
	}
	
	public init(encoding dictionary: [String: Any]) throws {
		let wrappedDictionary = CodableAnyDictionary(wrappedValue: dictionary)
		try self.init(encoding: wrappedDictionary)
	}
	
	public init(encoding wrappedDictionary: CodableAnyDictionary) throws {
		let encoder = JSONEncoder()
		let data = try encoder.encode(wrappedDictionary)
		self.init(wrappedValue: data)
	}

	public func asCodableDictionary() throws -> CodableAnyDictionary {
		let decoder = JSONDecoder()
		let wrappedDictionary = try decoder.decode(CodableAnyDictionary.self, from: wrappedValue)
		return wrappedDictionary
	}
	
	/*
	public init(encoding dictionary: [String: Any]) {
		let wrapped = CodableAnyDictionary(wrappedValue: dictionary)
		let encoder = JSONEncoder()
		let data = try? encoder.encode(wrapped)
		self.init(wrappedValue: data ?? .init())
	}
	*/
}

extension RawJson: Codable {
	public init(from decoder: Decoder) throws {
		let wrappedDictionary = try CodableAnyDictionary(from: decoder)
		try self.init(encoding: wrappedDictionary)
	}
	
	/*
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: JSONCodingKeys.self)
		let dictionary = try container.decode([String: Any].self)
		try self.init(encoding: dictionary)
	}
	*/

	public func encode(to encoder: Encoder) throws {
		let wrappedDictionary = try asCodableDictionary()
		try wrappedDictionary.encode(to: encoder)
	}
	
	/*
	public func encode(to encoder: Encoder) throws {
		if wrappedValue.isEmpty { return }
		let decoder = JSONDecoder()
		let wrapped = try decoder.decode(CodableAnyDictionary.self, from: wrappedValue)
		try wrapped.encode(to: encoder)
	}
	*/
}
