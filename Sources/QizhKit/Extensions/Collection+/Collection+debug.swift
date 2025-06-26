//
//  Collection+debug.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.03.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Dictionary where Key: Sendable,
						   Value: Sendable {
	public var multilineDescription: String {
		if self.isEmpty {
			.leftBrace + .rightBrace
		} else {
			self.map { key, value in
				"\(key): \(value),"
			}
			.joined(separator: .newLine)
			.offsettingLines()
			.wrapped(in: .newLine)
			.wrapped(in: .leftBrace, and: .rightBrace)
		}
	}
}

extension Array where Element: Sendable {
	public var multilineDescription: String {
		if self.isEmpty {
			.leftBracket + .rightBracket
		} else {
			self.map { element in
				"\(element),"
			}
			.joined(separator: .newLine)
			.offsettingLines()
			.wrapped(in: .newLine)
			.wrapped(in: .leftBracket, and: .rightBracket)
		}
	}
}
