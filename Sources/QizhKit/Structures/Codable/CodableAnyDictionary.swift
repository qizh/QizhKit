//
//  CodableAnyDictionary.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct CodableAnyDictionary: ExpressibleByDictionaryLiteral, EmptyProvidable {
	public var wrappedValue: [String: Any]
	
	public init(wrappedValue: [String: Any] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	public init(dictionaryLiteral elements: (String, Any)...) {
		self.wrappedValue = .init(uniqueKeysWithValues: elements)
	}
	
	@inlinable
	public static func some(_ value: [String: Any]) -> Self {
		.init(wrappedValue: value)
	}
	
	public static let empty: Self = .init()
}

// MARK: Codable

extension CodableAnyDictionary: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: JSONCodingKeys.self)
		wrappedValue = try container.decode([String: Any].self)
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
	func asDictionary() -> [String: Any] {
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(self)
			let decoder = JSONDecoder()
			let dictionary = try decoder.decode(CodableAnyDictionary.self, from: data)
			return dictionary.wrappedValue
		} catch {
			return .empty
		}
	}
}
