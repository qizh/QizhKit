//
//  String+usefull.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 09.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension StringProtocol {
	func count <S: StringProtocol> (of substring: S) -> Int {
		var scope = fullRange
		var count: Int = .zero
		while let found = range(of: substring, range: scope) {
			count.increase()
			scope = found.upperBound ..< endIndex
		}
		return count
	}
	
	@inlinable var fullRange: Range<Index> {
		startIndex ..< endIndex
	}
}

public extension Character {
	@inlinable var s: String {
		String(self)
	}
}

extension String {
	/// Creates a regular string from a `StaticString`.
	@inlinable public init(_ staticString: StaticString) {
		self = staticString.withUTF8Buffer {
			String(decoding: $0, as: UTF8.self)
		}
	}
}

extension StaticString {
	/// A plain `String` representation of this static string.
	@inlinable public var asString: String {
		String(self)
	}
}
