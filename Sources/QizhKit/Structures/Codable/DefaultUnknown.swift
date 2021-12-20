//
//  DefaultUnknown.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.12.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultUnknown <Wrapped> where Wrapped: WithUnknown {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped = .unknown) {
		self.wrappedValue = wrappedValue
	}
}

extension DefaultUnknown: Codable where Wrapped: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? .unknown
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension DefaultUnknown: Equatable where Wrapped: Equatable { }
extension DefaultUnknown: Hashable where Wrapped: Hashable { }

extension DefaultUnknown: WithUnknown {
	@inlinable public static var unknown: DefaultUnknown<Wrapped> { .init() }
}

public extension KeyedDecodingContainer {
	func decode <Wrapped: Codable> (
		_: DefaultUnknown<Wrapped>.Type,
		forKey key: Key
	) -> DefaultUnknown<Wrapped> {
		(try? decodeIfPresent(DefaultUnknown<Wrapped>.self, forKey: key))
		?? .init()
	}
}
