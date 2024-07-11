//
//  DefaultTrue.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.12.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultTrue: Codable, Hashable, Sendable {
	public var wrappedValue: Bool
	private let isDefault: Bool
	
	public init() {
		self.wrappedValue = Self.defaultValue
		self.isDefault = true
	}
	
	public init(wrappedValue: Bool) {
		self.wrappedValue = wrappedValue
		self.isDefault = false
	}
	
	public init(from decoder: Decoder) throws {
		do {
			let container = try decoder.singleValueContainer()
			let wrappedValue = try container.decode(Bool.self)
			self.init(wrappedValue: wrappedValue)
		} catch {
			self.init()
		}
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

extension DefaultTrue: WithDefault {
	public static let defaultValue: Bool = true
	@inlinable public static var `default`: DefaultTrue {
		.init()
	}
}

extension DefaultTrue: ExpressibleByBooleanLiteral {
	@inlinable public init(booleanLiteral value: Bool) {
		self.init(wrappedValue: value)
	}
}

public extension KeyedDecodingContainer {
	func decode(_: DefaultTrue.Type, forKey key: Key) -> DefaultTrue {
		(try? decodeIfPresent(DefaultTrue.self, forKey: key))
			?? .default
	}
}
