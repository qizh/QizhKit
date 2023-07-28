//
//  LossyArray.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.10.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import os.log

fileprivate let logger = Logger(
	subsystem: "\(Bundle.mainIdentifier).property_wrappers",
	category: "Lossy Array"
)

/// Decodes Arrays and filters invalid values if the Decoder is unable to decode the value.
@propertyWrapper
public struct LossyArray <Item: Codable>: Codable, EmptyProvidable, ExpressibleByArrayLiteral {
	public var wrappedValue: [Item]
	
	public init(wrappedValue: [Item] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	public init(arrayLiteral elements: Item...) {
		self.wrappedValue = elements
	}
	
	public init(from decoder: Decoder) throws {
		var elements: [Item] = .empty
		
		do {
			var container = try decoder.unkeyedContainer()
			while !container.isAtEnd {
				do {
					let value = try container.decode(Item.self)
					elements.append(value)
					// logger.debug("[LossyArray] decoded \(Item.self) element")
				} catch {
					logger.warning("Skipping \(Item.self) element while decoding because of error: \(error)")
					_ = try? container.decode(Blancodable.self)
				}
			}
		} catch {
			logger.error("Non-array skipped: \(error)")
		}
		
		self.wrappedValue = elements
	}
	
	@inlinable
	public static func some(_ elements: Item...) -> Self {
		.init(wrappedValue: elements)
	}
	
	@inlinable
	public static func some(_ elements: [Item]) -> Self {
		.init(wrappedValue: elements)
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
	
	@inlinable public static var empty: Self { .init() }
	
	private struct Blancodable: Codable { }
}

extension LossyArray: WithDefault {
	@inlinable public static var `default`: Self { .init() }
}

extension LossyArray: Equatable where Item: Equatable { }
extension LossyArray: Hashable where Item: Hashable { }

public extension KeyedDecodingContainer {
	func decode <Wrapped: Codable> (
		_: LossyArray<Wrapped>.Type,
		forKey key: Key
	) -> LossyArray<Wrapped> {
		let result: LossyArray<Wrapped>?
		do {
			// print("[LossyArray] try to decode \(Wrapped.self) optionally")
			result = try decodeIfPresent(LossyArray<Wrapped>.self, forKey: key)
		} catch {
			logger.warning("No value for `\(key)` key")
			result = nil
		}
		/*
		if let count = result?.wrappedValue.count {
			print("[LossyArray] decoded \(count) \(Wrapped.self) elements")
		} else {
			print("[LossyArray] failed to decode any \(Wrapped.self), fallback to default")
		}
		*/
		return result.orDefault
	}
}
