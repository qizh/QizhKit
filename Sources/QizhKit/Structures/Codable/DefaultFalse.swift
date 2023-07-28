//
//  DefaultFalse.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultFalse: Codable, Hashable {
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
	
	public static let defaultValue: Bool = false
}

extension DefaultFalse: WithDefault {
	@inlinable
	public static var `default`: DefaultFalse {
		.init()
	}
}

extension DefaultFalse: ExpressibleByBooleanLiteral {
	@inlinable public init(booleanLiteral value: Bool) {
		self.init(wrappedValue: value)
	}
}

public extension KeyedDecodingContainer {
    func decode(_: DefaultFalse.Type, forKey key: Key) -> DefaultFalse {
        (try? decodeIfPresent(DefaultFalse.self, forKey: key))
			?? .default
    }
}
