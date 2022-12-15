//
//  DefaultTrue.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.12.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultTrue: Codable, Hashable {
	public var wrappedValue: Bool
	
	public init(wrappedValue: Bool = Self.defaultValue) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Bool.self)) ?? Self.defaultValue
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
	
	public static let defaultValue: Bool = true
}

extension DefaultTrue: WithDefault {
	@inlinable
	public static var `default`: DefaultTrue {
		.init()
	}
}

extension DefaultTrue: ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: Bool) {
		self.wrappedValue = value
	}
}

public extension KeyedDecodingContainer {
	func decode(_: DefaultTrue.Type, forKey key: Key) -> DefaultTrue {
		(try? decodeIfPresent(DefaultTrue.self, forKey: key))
			?? .default
	}
}
