//
//  DefaultFalse.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 31.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultFalse: Codable, Hashable {
    public var wrappedValue: Bool
    
    public init(wrappedValue: Bool = false) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(Bool.self)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension DefaultFalse: ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: Bool) {
		self.wrappedValue = value
	}
}

public extension KeyedDecodingContainer {
    func decode(_: DefaultFalse.Type, forKey key: Key) -> DefaultFalse {
        (try? decodeIfPresent(DefaultFalse.self, forKey: key))
			?? DefaultFalse(wrappedValue: false)
    }
}
