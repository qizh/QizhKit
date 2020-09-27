//
//  CodableAnyDictionary.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper public struct CodableAnyDictionary: Codable {
	public var wrappedValue: [String: Any]
	
	public init(wrappedValue: [String: Any]) {
		self.wrappedValue = wrappedValue
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: JSONCodingKeys.self)
		wrappedValue = try container.decode([String: Any].self)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: JSONCodingKeys.self)
		try container.encode(wrappedValue)
	}
}
