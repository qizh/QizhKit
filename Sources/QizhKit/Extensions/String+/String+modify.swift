//
//  String+modify.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	@inlinable func replacing(_ set: CharacterSet, with replacement: String = .empty) -> String {
        components(separatedBy: set).joined(separator: replacement)
    }
	
	@inlinable func replacing(
		_ occurances: String,
		with replacement: String = .empty,
		options: CompareOptions = []
	) -> String {
		replacingOccurrences(of: occurances, with: replacement, options: options)
	}
	
	@inlinable var withSpacesTrimmed: String { trimmingCharacters(in: .whitespaces) }
	@inlinable var withLinesNSpacesTrimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
	@inlinable var digits: String { replacing(CharacterSet.decimalDigits.inverted) }
}

public extension Substring {
	func asString() -> String { String(self) }
}

public extension String {
	/// Repeat provided string provided amount of times
	static func * (source: String, times: UInt) -> String {
		var result: String = .empty
		var n: UInt = times
		while n > 0 {
			result += source
			n.decrease()
		}
		return result
	}
}

extension String {
	@inlinable
	public func offsettingLines(by spaceCount: UInt = 4) -> String {
		.space * spaceCount + replacing(.newLine, with: .newLine + .space * spaceCount)
	}
	
	@inlinable
	public func offsettingNewLines(by spaceCount: UInt = 4) -> String {
		replacing(.newLine, with: .newLine + .space * spaceCount)
	}
}

public extension String {
	@inlinable func deleting(prefix: String) -> String {
		hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
	}
	@inlinable func deleting(suffix: String) -> String {
		hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
	}
}

// MARK: URL

public extension String {
	var withHTTPSchemeIfIsURLWithNoScheme: String {
		guard let originalURL = URL(string: self) else { return self }
		if let scheme = originalURL.scheme,
		   scheme.isNotEmpty {
			/// Scheme is present
			return self
		} else {
			/// Set `http` scheme
			var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: true)
			if let host = components?.host, host.isNotEmpty {
				components?.scheme = "https"
				if let output = components?.string {
					return output
				}
			}
			return URL(string: "https://" + self)?.absoluteString ?? self
		}
	}
}

/*
public extension String {
	@inlinable func deleting(
		from substring: String,
			   include: Bool = true,
				greedy: Bool = false
	) -> Substring {
		let substringRange = range(of: substring, options: greedy ? .backwards : [])
		let deleteFromIndex = (include
			? substringRange?.lowerBound
			: substringRange?.upperBound)
			?? endIndex
		return self[startIndex ..< deleteFromIndex]
	}
	
	@inlinable func deleting(
		until substring: String,
			    include: Bool = true,
				 greedy: Bool = false
	) -> Substring {
		let substringRange = range(of: substring, options: greedy ? .backwards : [])
		let deleteFromIndex = (include
			? substringRange?.lowerBound
			: substringRange?.upperBound)
			?? endIndex
		return self[startIndex ..< deleteFromIndex]
	}
}
*/

/*
public extension String {
	@inlinable func prefix(upTo end: Element) -> Substring {
		prefix(while: { $0 != end })
	}
	func prefix(upTo end: String) -> Substring {
		self[startIndex ..< (range(of: end)?.lowerBound ?? endIndex)]
	}
	func prefix(upToLast end: String) -> Substring {
		self[startIndex ..< (range(of: end, options: .backwards)?.lowerBound ?? endIndex)]
	}

	func suffix(from start: String) -> Substring {
		self[(range(of: start)?.upperBound ?? startIndex) ..< endIndex]
	}
	func suffix(fromLast start: String) -> Substring {
		self[(range(of: start, options: .backwards)?.upperBound ?? startIndex) ..< endIndex]
	}
	func suffix(includingLast start: String) -> Substring {
		self[(range(of: start, options: .backwards)?.lowerBound ?? startIndex) ..< endIndex]
	}
}
*/
