//
//  Collection+debug.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.03.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Dictionary {
	public var multilineDescription: String {
		isEmpty
		? 	.leftBrace + .rightBrace
		: 	map { key, value in
				"\(key): \(value),"
			}
			.joined(separator: .newLine)
			.offsettingLines()
			.wrapped(in: .newLine)
			.wrapped(in: .leftBrace, and: .rightBrace)
	}
}

extension Array {
	public var multilineDescription: String {
		isEmpty
		? 	.leftBracket + .rightBracket
		: 	map { element in
				"\(element),"
			}
			.joined(separator: .newLine)
			.offsettingLines()
			.wrapped(in: .newLine)
			.wrapped(in: .leftBracket, and: .rightBracket)
	}
}
