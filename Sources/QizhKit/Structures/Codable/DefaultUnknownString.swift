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
	public var wrappedValue: String
	public var isDefault: Bool
	
	public init() {
		self.wrappedValue = Self.defaultValue
		self.isDefault = true
	}
	
	public init(wrappedValue: String) {
		self.wrappedValue = wrappedValue
		self.isDefault = false
	}
	
	public init(from decoder: Decoder) throws {
		guard let value = try? decoder.singleValueContainer().decode(String.self) else {
			self.init()
			return
		}
		self.init(wrappedValue: value)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		if isDefault {
			try container.encodeNil()
		} else {
			try container.encode(wrappedValue)
		}
	}
}

extension DefaultUnknownString: ExpressibleByStringLiteral {
	@inlinable public init(stringLiteral value: StringLiteralType) {
		self.init(wrappedValue: value)
	}
}

extension DefaultUnknownString: WithDefault {
	public static let defaultValue: String = "Unknown"
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
