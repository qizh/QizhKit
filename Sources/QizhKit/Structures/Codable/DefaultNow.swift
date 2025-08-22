//
//  DefaultNow.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultNow: Codable, Hashable, Sendable {
	public var wrappedValue: Date
	private let isDefault: Bool
	
	public init(wrappedValue: Date) {
		self.wrappedValue = wrappedValue
		self.isDefault = false
	}
	
	public init() {
		self.wrappedValue = .now
		self.isDefault = true
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self.wrappedValue = try container.decode(Date.self)
		self.isDefault = false
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
		
		/*
		if isDefault {
			try container.encodeNil()
		} else {
			try container.encode(wrappedValue)
		}
		*/
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
