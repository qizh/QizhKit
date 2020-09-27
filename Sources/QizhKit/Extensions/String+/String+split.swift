//
//  String+split.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	func split(by length: Int) -> [String] {
		stride(from: 0, to: count, by: length)
			.map { offset in
				let start = index(startIndex, offsetBy: offset)
				let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
				return String(self[start ..< end])
			}
	}
}

public extension Array where Element == Character {
	@inlinable func asString() -> String {
		String(self)
	}
}
