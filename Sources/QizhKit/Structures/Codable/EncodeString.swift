//
//  EncodeString.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 19.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

@frozen
@propertyWrapper
public struct EncodeString <Value: Encodable>: Encodable {
	public var wrappedValue: Value
	
	public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
	
	@inlinable
	public static func some(_ value: Value) -> Self {
		.init(wrappedValue: value)
	}
	
	public func encode(to encoder: Encoder) throws {
		let jsonEncoder = JSONEncoder()
		jsonEncoder.dateEncodingStrategy = .formatted(.airtable)
		// jsonEncoder.userInfo[AnyEncodable.skipNilValues] = true
		
		var container = encoder.singleValueContainer()
		if let data = try? jsonEncoder.encode(wrappedValue),
		   let string = String(data: data, encoding: .utf8)
		{
			// print("::encodeString > raw > \(string)")
			
			if string == "null" {
				// print(.tab + "> encoding nil")
				try container.encodeNil()
			} else {
				let output = string
					.deleting(prefix: .quot)
					.deleting(suffix: .quot)
				
				// print(.tab + "> encoding > \(output)")
				try container.encode(output)
			}
		} else {
			try container.encodeNil()
		}
	}
}
