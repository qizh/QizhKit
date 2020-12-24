//
//  DefaultUnknownString.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultUnknownString: Codable, Hashable {
	public static let defaultValue: String = "Unknown"
	
	public var wrappedValue: String
	
	public init(wrappedValue: String = Self.defaultValue) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		guard let value = try? decoder.singleValueContainer().decode(String.self) else {
			wrappedValue = Self.defaultValue
			return
		}
		wrappedValue = value
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension DefaultUnknownString: ExpressibleByStringLiteral {
	public init(stringLiteral value: StringLiteralType) {
		self.wrappedValue = value
	}
}

extension DefaultUnknownString: WithDefault {
	public static let `default`: DefaultUnknownString = .init()
}

extension DefaultUnknownString: EmptyProvidable {
	public static let empty: DefaultUnknownString = .init(wrappedValue: .empty)
}

/*
public extension KeyedDecodingContainer {
	func decode(_: DefaultUnknownString.Type, forKey key: Key) -> DefaultUnknownString {
		print("+++ Decoding Unknown String Wrapper")
		return (try? decodeIfPresent(DefaultUnknownString.self, forKey: key)).orDefault
	}
}
*/
