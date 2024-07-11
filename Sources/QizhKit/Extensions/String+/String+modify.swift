//
//  String+modify.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension StringProtocol {
	@inlinable public func replacing(
		_ set: CharacterSet,
		with replacement: String = .empty
	) -> String {
        components(separatedBy: set).joined(separator: replacement)
    }
	
	@inlinable public func replacing(
		_ occurances: String,
		with replacement: String = .empty,
		options: String.CompareOptions = []
	) -> String {
		replacingOccurrences(of: occurances, with: replacement, options: options)
	}
	
	@inlinable public var withSpacesTrimmed: String { trimmingCharacters(in: .whitespaces) }
	@inlinable public var withLinesNSpacesTrimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
	@inlinable public var digits: String { replacing(CharacterSet.decimalDigits.inverted) }
}

extension Substring {
	@inlinable public func asString() -> String { String(self) }
	@inlinable public var string: String { String(self) }
}

extension String {
	/// Repeat provided string provided amount of times
	public static func * (source: String, times: UInt) -> String {
		.init(repeating: source, count: Int(times))
		/*
		var result: String = .empty
		var n: UInt = times
		while n > 0 {
			result += source
			n.decrease()
		}
		return result
		*/
	}
}

// MARK: Offset

public enum StringOffset: Sendable {
	case spaces(_ amount: UInt, prefix: String = .empty, suffix: String = .empty)
	case tabs(_ amount: UInt, prefix: String = .empty, suffix: String = .empty)
	
	public static let space: Self = .spaces(1)
	public static let tab: Self = .tabs(1)
	public static let tabArrow: Self = .tabs(1, suffix: "> ")
	public static let empty: Self = .spaces(0)
	
	public static let tree: Self = .tree(tabs: 1)
	public static func tree(tabs: UInt) -> Self {
		.tabs(tabs, suffix: "┣ ")
	}
	
	public var value: String {
		switch self {
		case let .spaces(amount, prefix, suffix): return prefix + .space * amount + suffix
		case let .tabs(amount, prefix, suffix): return prefix + .tab * amount + suffix
		}
	}
}

extension String {
	@inlinable
	public func offsetting(by offset: StringOffset, first: Bool) -> String {
			(first ? offset.value : .empty)
		+ 	self.replacing(.newLine, with: .newLine + offset.value)
	}
}

extension String {
	
	/// Spaces
	
	@inlinable
	public func offsettingLines(by spaceCount: UInt = 4) -> String {
		.space * spaceCount + replacing(.newLine, with: .newLine + .space * spaceCount)
	}
	
	@inlinable
	public func offsettingNewLines(by spaceCount: UInt = 4) -> String {
		replacing(.newLine, with: .newLine + .space * spaceCount)
	}
	
	/// Tabs
	
	@inlinable
	public func tabOffsettingLines(by tabCount: UInt = 1) -> String {
		.tab * tabCount + replacing(.newLine, with: .newLine + .tab * tabCount)
	}
	
	@inlinable
	public func tabOffsettingNewLines(by tabsCount: UInt = 1) -> String {
		replacing(.newLine, with: .newLine + .tab * tabsCount)
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

// MARK: Wrap

extension String {
	/// - Parameters:
	///   - prefix: String to prepend.
	///   - suffix: String to append. If not provided, reversed prefix is used instead.
	/// - Returns: prefix + self + suffix or reversed prefix
	@inlinable public func wrapped(
		in prefix: String,
		and suffix: String? = .none
	) -> String {
		prefix + self + (suffix ?? String(prefix.reversed()))
	}
}

