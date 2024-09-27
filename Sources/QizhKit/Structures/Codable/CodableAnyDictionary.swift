//
//  CodableAnyDictionary.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct CodableAnyDictionary: ExpressibleByDictionaryLiteral, EmptyProvidable, Sendable {
	public var wrappedValue: [String: any Sendable]
	
	public init(wrappedValue: [String: any Sendable] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	public init(dictionaryLiteral elements: (String, any Sendable)...) {
		self.wrappedValue = .init(uniqueKeysWithValues: elements)
	}
	
	@inlinable
	public static func some(_ value: [String: any Sendable]) -> Self {
		.init(wrappedValue: value)
	}
	
	public static let empty: Self = .init()
}

// MARK: Codable

extension CodableAnyDictionary: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: JSONCodingKeys.self)
		self.wrappedValue = try container.decode([String: Any].self)
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
	
	public func encode(to encoder: Encoder) throws {
		guard wrappedValue.isNotEmpty else { return }
		var container = encoder.container(keyedBy: JSONCodingKeys.self)
		try container.encode(wrappedValue)
	}
}

public extension KeyedDecodingContainer {
	func decode(_: CodableAnyDictionary.Type, forKey key: Key) -> CodableAnyDictionary {
		(try? decodeIfPresent(CodableAnyDictionary.self, forKey: key))
			?? .empty
	}
}

// MARK: Encodable -> Dictionary

public extension Encodable {
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
