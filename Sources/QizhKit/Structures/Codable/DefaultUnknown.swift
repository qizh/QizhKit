//
//  DefaultUnknown.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.12.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "A model implementing both WithUnknown and Codable protocols will fallback to unknown already. There's no need for a special wrapper")
@propertyWrapper
public struct DefaultUnknown <Wrapped> where Wrapped: WithUnknown {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped = .unknown) {
		self.wrappedValue = wrappedValue
	}
}

@available(*, deprecated)
extension DefaultUnknown: Codable where Wrapped: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = (try? container.decode(Wrapped.self)) ?? .unknown
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

@available(*, deprecated)
extension DefaultUnknown: Equatable where Wrapped: Equatable { }
@available(*, deprecated)
extension DefaultUnknown: Hashable where Wrapped: Hashable { }

@available(*, deprecated)
extension DefaultUnknown: WithUnknown {
	@inlinable public static var unknown: DefaultUnknown<Wrapped> { .init() }
}

@available(*, deprecated)
public extension KeyedDecodingContainer {
	func decode <Wrapped: Codable> (
		_: DefaultUnknown<Wrapped>.Type,
		forKey key: Key
	) -> DefaultUnknown<Wrapped> {
		(try? decodeIfPresent(DefaultUnknown<Wrapped>.self, forKey: key))
		?? .init()
	}
}
