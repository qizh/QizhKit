//
//  AnyHashableAndSendable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 11.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Hashable & Sendable

public protocol HashableAndSendableAdoptable: Hashable, Sendable {
	func hash(into hasher: inout Hasher)
	func isEqual(to other: any HashableAndSendableAdoptable) -> Bool
}

@propertyWrapper
public struct AnyHashableAndSendable: Hashable, Sendable {
	public let wrappedValue: any HashableAndSendableAdoptable
	
	public init<HS>(wrappedValue: HS) where HS: Hashable, HS: Sendable {
		self.wrappedValue = HashableAndSendable(wrappedValue)
	}
	
	public init<HS>(_ base: HS) where HS: Hashable, HS: Sendable {
		self.wrappedValue = HashableAndSendable(base)
	}

	public func hash(into hasher: inout Hasher) {
		wrappedValue.hash(into: &hasher)
	}

	public static func == (
		lhs: AnyHashableAndSendable,
		rhs: AnyHashableAndSendable
	) -> Bool {
		lhs.wrappedValue.isEqual(to: rhs.wrappedValue)
	}
	
	public struct HashableAndSendable<Value: Hashable & Sendable>: HashableAndSendableAdoptable {
		public let value: Value

		public init(_ value: Value) {
			self.value = value
		}

		public func hash(into hasher: inout Hasher) {
			value.hash(into: &hasher)
		}

		public func isEqual(to other: any HashableAndSendableAdoptable) -> Bool {
			if let otherBox = other as? HashableAndSendable<Value> {
				self.value == otherBox.value
			} else {
				false
			}
		}
	}
}

// MARK: Sendable & Encodable

public protocol SendableEncodableAdoptable: Sendable, Encodable {
	func encode(to encoder: any Encoder) throws
}

@propertyWrapper
public struct AnySendableEncodable: Sendable, Encodable {
	public let wrappedValue: any SendableEncodableAdoptable
	
	public init<HSE>(wrappedValue: HSE) where HSE: Sendable, HSE: Encodable {
		self.wrappedValue = SendableEncodable(wrappedValue)
	}
	
	public init<HSE>(_ base: HSE) where HSE: Sendable, HSE: Encodable {
		self.wrappedValue = SendableEncodable(base)
	}
	
	public func encode(to encoder: any Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
	
	public struct SendableEncodable<Value>: SendableEncodableAdoptable
		where Value: Sendable,
			  Value: Encodable
	{
		public let value: Value

		public init(_ value: Value) {
			self.value = value
		}
		
		public func encode(to encoder: any Encoder) throws {
			try value.encode(to: encoder)
		}
	}
}

// MARK: Hashable & Sendable & Encodable

public protocol HashableSendableEncodableAdoptable: Hashable, Sendable, Encodable {
	func hash(into hasher: inout Hasher)
	func isEqual(to other: any HashableSendableEncodableAdoptable) -> Bool
	func encode(to encoder: any Encoder) throws
}

@propertyWrapper
public struct AnyHashableSendableEncodable: Hashable, Sendable, Encodable {
	public let wrappedValue: any HashableSendableEncodableAdoptable
	
	public init<HSE>(wrappedValue: HSE) where HSE: Hashable, HSE: Sendable, HSE: Encodable {
		self.wrappedValue = HashableSendableEncodable(wrappedValue)
	}
	
	public init<HSE>(_ base: HSE) where HSE: Hashable, HSE: Sendable, HSE: Encodable {
		self.wrappedValue = HashableSendableEncodable(base)
	}

	public func hash(into hasher: inout Hasher) {
		wrappedValue.hash(into: &hasher)
	}

	public static func == (
		lhs: AnyHashableSendableEncodable,
		rhs: AnyHashableSendableEncodable
	) -> Bool {
		lhs.wrappedValue.isEqual(to: rhs.wrappedValue)
	}
	
	public func encode(to encoder: any Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
	
	public struct HashableSendableEncodable<Value>: HashableSendableEncodableAdoptable
		where Value: Hashable,
			  Value: Sendable,
			  Value: Encodable
	{
		public let value: Value

		public init(_ value: Value) {
			self.value = value
		}

		public func hash(into hasher: inout Hasher) {
			value.hash(into: &hasher)
		}

		public func isEqual(to other: any HashableSendableEncodableAdoptable) -> Bool {
			if let otherBox = other as? HashableSendableEncodable<Value> {
				self.value == otherBox.value
			} else {
				false
			}
		}
		
		public func encode(to encoder: any Encoder) throws {
			try value.encode(to: encoder)
		}
	}
}

// MARK: Other tests

extension [AnyHashable: Any] {
	public func asEncodedJsonString(encoder providedEncoder: JSONEncoder? = .none) -> String {
		guard let encodableDictionary = self as? (any Encodable) else {
			return "Cannot convert to Encodable"
		}
		
		let encoder: JSONEncoder = providedEncoder ?? .prettyPrinted
		
		do {
			let jsonData = try encoder.encode(encodableDictionary)
			if let jsonString = String(data: jsonData, encoding: .utf8) {
				return jsonString
			} else {
				let jsonString = String(decoding: jsonData, as: UTF8.self)
				return jsonString
			}
		} catch {
			return error.localizedDescription
		}
	}
}
