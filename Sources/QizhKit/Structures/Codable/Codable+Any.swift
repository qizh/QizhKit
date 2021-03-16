//
//  Codable+Any.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct JSONCodingKeys: CodingKey, ExpressibleByStringLiteral {
	public var stringValue: String
	
	public init(stringValue: String) {
		self.stringValue = stringValue
	}
	
	public var intValue: Int?
	
	public init(intValue: Int) {
		self.init(stringValue: "\(intValue)")
		self.intValue = intValue
	}
	
	@inlinable
	public static func some(_ value: String) -> Self {
		.init(stringValue: value)
	}
	
	@inlinable
	public static func some(_ value: Int) -> Self {
		.init(intValue: value)
	}
	
	@inlinable
	public static func some(_ value: CodingKey) -> Self {
		.init(stringValue: value.stringValue)
	}
	
	@inlinable
	public init(stringLiteral value: StringLiteralType) {
		self.init(stringValue: value)
	}
}

public extension KeyedDecodingContainer {
	func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
		let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
		return try container.decode(type)
	}
	
	func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
		var container = try self.nestedUnkeyedContainer(forKey: key)
		return try container.decode(type)
	}
	
	func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
		var dictionary = Dictionary<String, Any>()
		
		for key in allKeys {
			if let boolValue = try? decode(Bool.self, forKey: key) {
				dictionary[key.stringValue] = boolValue
			} else if let stringValue = try? decode(String.self, forKey: key) {
				dictionary[key.stringValue] = stringValue
			} else if let intValue = try? decode(Int.self, forKey: key) {
				dictionary[key.stringValue] = intValue
			} else if let doubleValue = try? decode(Double.self, forKey: key) {
				dictionary[key.stringValue] = doubleValue
			} else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
				dictionary[key.stringValue] = nestedDictionary
			} else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
				dictionary[key.stringValue] = nestedArray
			}
		}
		return dictionary
	}
}

public extension UnkeyedDecodingContainer {
	mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
		var array: [Any] = []
		while isAtEnd == false {
			if let value = try? decode(Bool.self) {
				array.append(value)
			} else if let value = try? decode(Double.self) {
				array.append(value)
			} else if let value = try? decode(String.self) {
				array.append(value)
			} else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
				array.append(nestedDictionary)
			} else if let nestedArray = try? decode(Array<Any>.self) {
				array.append(nestedArray)
			}
		}
		return array
	}
	
	mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
		let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
		return try nestedContainer.decode(type)
	}
}


public extension KeyedEncodingContainerProtocol where Key == JSONCodingKeys {
	mutating func encode(_ value: Dictionary<String, Any>) throws {
		try value.forEach { (key, value) in
			let key = JSONCodingKeys(stringValue: key)
			switch value {
			case let value as Bool:
				try encode(value, forKey: key)
			case let value as Int:
				try encode(value, forKey: key)
			case let value as UInt:
				try encode(value, forKey: key)
			case let value as String:
				try encode(value, forKey: key)
			case let value as Double:
				try encode(value, forKey: key)
			case let value as CGFloat:
				try encode(value, forKey: key)
			case let value as Decimal:
				try encode(value, forKey: key)
			case let value as Date:
				try encode(value, forKey: key)
			case let value as Dictionary<String, Any>:
				try encode(value, forKey: key)
			case let value as Array<Any>:
				try encode(value, forKey: key)
			case Optional<Any>.none:
				try encodeNil(forKey: key)
			default:
				throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + [key], debugDescription: "Invalid JSON value"))
			}
		}
	}
	
	@inlinable
	mutating func encode <Value, OtherKey> (
		_ value: Value,
		forKey key: OtherKey
	) throws where Value: Encodable, OtherKey: CodingKey {
		try encode(value, forKey: .some(key))
	}
	
	@inlinable
	mutating func encode <Value> (
		_ value: Value,
		forKey key: String
	) throws where Value: Encodable {
		try encode(value, forKey: .some(key))
	}
}

public extension KeyedEncodingContainerProtocol {
	mutating func encode(_ value: Dictionary<String, Any>?, forKey key: Key) throws {
		if let value = value {
			var container = self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
			try container.encode(value)
		}
	}
	
	mutating func encode(_ value: Array<Any>?, forKey key: Key) throws {
		if let value = value {
			var container = self.nestedUnkeyedContainer(forKey: key)
			try container.encode(value)
		}
	}
}

public extension UnkeyedEncodingContainer {
	mutating func encode(_ value: Array<Any>) throws {
		try value.enumerated().forEach { (index, value) in
			switch value {
			case let value as Bool:
				try encode(value)
			case let value as Int:
				try encode(value)
			case let value as UInt:
				try encode(value)
			case let value as String:
				try encode(value)
			case let value as Double:
				try encode(value)
			case let value as CGFloat:
				try encode(value)
			case let value as Decimal:
				try encode(value)
			case let value as Date:
				try encode(value)
			case let value as Dictionary<String, Any>:
				try encode(value)
			case let value as Array<Any>:
				try encode(value)
			case Optional<Any>.none:
				try encodeNil()
			default:
				//let keys = JSONCodingKeys(intValue: index).map({ [ $0 ] }) ?? []
				let keys: [JSONCodingKeys] = .just(.some(index))
				throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: codingPath + keys, debugDescription: "Invalid JSON value"))
			}
		}
	}
	
	mutating func encode(_ value: Dictionary<String, Any>) throws {
		var nestedContainer = self.nestedContainer(keyedBy: JSONCodingKeys.self)
		try nestedContainer.encode(value)
	}
}
