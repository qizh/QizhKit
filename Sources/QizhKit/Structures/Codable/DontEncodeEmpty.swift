//
//  DontEncodeEmpty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.02.2025.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DontEncodeEmpty<Wrapped>: Encodable where Wrapped: EmptyTestable,
														Wrapped: Encodable {
	public var wrappedValue: Wrapped
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
	}
	
	public func encode(to encoder: any Encoder) throws {
		if wrappedValue.isNotEmpty {
			var container = encoder.singleValueContainer()
			try container.encode(wrappedValue)
		}
	}
}

extension DontEncodeEmpty: Decodable where Wrapped: Decodable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(Wrapped.self)
		self.init(wrappedValue: value)
	}
}

extension DontEncodeEmpty: Equatable where Wrapped: Equatable { }
extension DontEncodeEmpty: Hashable where Wrapped: Hashable { }
extension DontEncodeEmpty: Sendable where Wrapped: Sendable { }

extension DontEncodeEmpty: WithAnyDefault where Wrapped: WithDefault { }
extension DontEncodeEmpty: WithDefault where Wrapped: WithDefault {
	@inlinable public static var `default`: DontEncodeEmpty<Wrapped> {
		.init(wrappedValue: Wrapped.default)
	}
}

extension DontEncodeEmpty: WithAnyUnknown where Wrapped: WithUnknown { }
extension DontEncodeEmpty: WithUnknown where Wrapped: WithUnknown {
	@inlinable public static var unknown: DontEncodeEmpty<Wrapped> {
		.init(wrappedValue: Wrapped.unknown)
	}
}
