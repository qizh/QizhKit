//
//  Array+RawRepresentable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 21.09.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Array: @retroactive RawRepresentable 
	where Element: RawRepresentable,
		  Element.RawValue == String
{
	public init?(rawValue: String) {
		self = rawValue
			.deleting(prefix: .leftBracket)
			.deleting(suffix: .rightBracket)
			.split(separator: .comaChar)
			.map(\.withSpacesTrimmed)
			.compactMap(Element.init(rawValue:))
	}
	
	@inlinable
	public var rawValue: String {
		self.map(\.rawValue)
			.joined(separator: .coma)
	}
}

/*
extension Array: RawRepresentable where Element: Codable {
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8),
			  let result = try? JSONDecoder().decode([Element].self, from: data)
		else {
			return nil
		}
		self = result
	}
	
	public var rawValue: String {
		guard let data = try? JSONEncoder().encode(self),
			  let result = String(data: data, encoding: .utf8)
		else {
			return "[]"
		}
		return result
	}
}
*/
