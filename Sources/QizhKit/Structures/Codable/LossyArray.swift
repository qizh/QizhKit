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
public struct LossyArray <Item: Codable>: Codable {
	public var wrappedValue: [Item]
	
	public init(wrappedValue: [Item]) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		
		var elements: [Item] = .empty
		while !container.isAtEnd {
			do {
				let value = try container.decode(Item.self)
				elements.append(value)
			} catch {
				_ = try? container.decode(Blancodable.self)
			}
		}
		
		self.wrappedValue = elements
	}
	
	public func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
	
	private struct Blancodable: Codable { }
}

extension LossyArray: Equatable where Item: Equatable { }
extension LossyArray: Hashable where Item: Hashable { }
