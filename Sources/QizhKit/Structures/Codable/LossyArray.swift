//
//  LossyArray.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.10.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// Decodes Arrays and filters invalid values if the Decoder is unable to decode the value.
@propertyWrapper
public struct LossyArray <Item: Codable>: Codable, EmptyProvidable {
	public var wrappedValue: [Item]
	
	public init(wrappedValue: [Item] = .empty) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		var elements: [Item] = .empty
		
		do {
			var container = try decoder.unkeyedContainer()
			while !container.isAtEnd {
				do {
					let value = try container.decode(Item.self)
					elements.append(value)
				} catch {
					print("[LossyArray] is skipping element because of decoding error: \(error)")
					_ = try? container.decode(Blancodable.self)
				}
			}
		} catch {
			print("[LossyArray] value is not an array: \(error)")
		}
		
		self.wrappedValue = elements
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
			result = try decodeIfPresent(LossyArray<Wrapped>.self, forKey: key)
		} catch {
			result = nil
			print("[LossyArray] no value for `\(key)` key")
		}
		return result.orDefault
	}
}
