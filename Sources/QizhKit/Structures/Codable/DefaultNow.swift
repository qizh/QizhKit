//
//  DefaultNow.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultNow: Codable, Hashable {
	public var wrappedValue: Date
	
	public init(wrappedValue: Date = .now) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = try container.decode(Date.self)
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension DefaultNow: WithDefault {
	public static var `default`: DefaultNow { .init() }
}

public extension KeyedDecodingContainer {
	func decode(_: DefaultNow.Type, forKey key: Key) -> DefaultNow {
		(try? decodeIfPresent(DefaultNow.self, forKey: key))
			?? DefaultNow()
	}
}
