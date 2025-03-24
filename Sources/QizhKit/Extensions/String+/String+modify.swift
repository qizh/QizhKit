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
	
	@inlinable public var withSpacesTrimmed: String {
		trimmingCharacters(in: .whitespaces)
	}
	
	@inlinable public var withLinesTrimmed: String {
		trimmingCharacters(in: .newlines)
	}
	
	public var withEmptyLinesTrimmed: String {
		let currentLines = self.asLines
		var newLines: [String] = .empty
		
		for line in currentLines {
			if line.withSpacesTrimmed.isNotEmpty {
				newLines.append(line)
			}
		}
		
		return newLines.asLines
	}
	
	@inlinable public var withLinesNSpacesTrimmed: String {
		trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	@inlinable public var digits: String {
		replacing(CharacterSet.decimalDigits.inverted)
	}
}

extension StringProtocol {
	/// Returns a new string made by removing all trailing characters contained in the given character set.
	public func trimmingTrailingCharacters(in set: CharacterSet) -> String {
		var endIndex = self.endIndex
		while endIndex > self.startIndex {
			let beforeIndex = self.index(before: endIndex)
			let character = self[beforeIndex]
			if character.unicodeScalars.allSatisfy({ set.contains($0) }) {
				endIndex = beforeIndex
			} else {
				break
			}
		}
		return String(self[..<endIndex])
	}
	
	/// A computed property that trims only the trailing spaces.
	@inlinable public var withTrailingSpacesTrimmed: String {
		trimmingTrailingCharacters(in: CharacterSet.whitespaces)
	}
	
	/// A computed property that trims trailing spaces and newline characters.
	@inlinable public var withTrailingSpacesAndLinesTrimmed: String {
		trimmingTrailingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
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
	
	public static let treeLineElement = "┃ "
	public static let treeElement = "┣ "
	private static let lastTreeElement = "┗ "
	public static let subtreeElement = "┃ ┣ "
	private static let lastSubtreeElement = "┃ ┗ "
	public static let secondSubtreeElement = "┃ ┃ ┣ "
	private static let secondLastSubtreeElement = "┃ ┃ ┗ "
	public static let secondEmptySubtreeElement = "┃   ┣ "
	private static let secondEmptyLastSubtreeElement = "┃   ┗ "
	
	/// `┃ every line`
	public static let treeLine: Self = .treeLine(spaces: 0)
	
	/// `┃ {spaces}every line`
	public static func treeLine(spaces: UInt) -> Self {
		.spaces(spaces, prefix: treeLineElement)
	}
	
	
	/// `┣ every line`, `┗ last line`
	/// ```
	/// ┣ every line
	/// ┗ last line
	/// ```
	public static let tree: Self = .tree(spaces: 0)
	
	/// `┣ {spaces}every line`, `┗ {spaces}last line`
	/// ```
	/// ┣ {spaces}every line
	/// ┗ {spaces}last line
	/// ```
	public static func tree(spaces: UInt) -> Self {
		.spaces(spaces, prefix: treeElement)
	}
	
	/// `┣ {tabs}every line`, `┗ {tabs}last line`
	/// ```
	/// ┣ {tabs}every line
	/// ┗ {tabs}last line
	/// ```
	public static func tree(tabs: UInt) -> Self {
		.tabs(tabs, suffix: treeElement)
	}
	
	/// `┃ ┣ every line`, `┃ ┗ last line`
	/// ```
	/// ┃ ┣ every line
	/// ┃ ┗ last line
	/// ```
	public static let subTree: Self = .subTree(spaces: 0)
	
	/// `┃ ┃ ┣ every line`, `┃ ┃ ┗ last line`
	/// ```
	/// ┃ ┃ ┣ every line
	/// ┃ ┃ ┗ last line
	/// ```
	public static let secondSubTree: Self = .spaces(0, suffix: secondSubtreeElement)
	
	/// `┃   ┣ every line`, `┃   ┗ last line`
	/// ```
	/// ┃   ┣ every line
	/// ┃   ┗ last line
	/// ```
	public static let secondEmptySubTree: Self = .spaces(0, suffix: secondEmptySubtreeElement)
	
	/// `┃ ┣ {spaces}every line`, `┃ ┗ {spaces}last line`
	/// ```
	/// ┃ ┣ {spaces}every line
	/// ┃ ┗ {spaces}last line
	/// ```
	public static func subTree(spaces: UInt) -> Self {
		.spaces(spaces, suffix: subtreeElement)
	}
	
	@inlinable public var amount: UInt {
		switch self {
		case let .spaces(amount, _, _): amount
		case let   .tabs(amount, _, _): amount
		}
	}
	
	@inlinable public var suffix: String {
		switch self {
		case let .spaces(_, _, suffix): suffix
		case let   .tabs(_, _, suffix): suffix
		}
	}
	
	@inlinable public var prefix: String {
		switch self {
		case let .spaces(_, prefix, _): prefix
		case let   .tabs(_, prefix, _): prefix
		}
	}
	
	@inlinable public var isTreeSuffix: Bool {
		suffix == Self.treeElement
	}
	
	@inlinable public var isTreePrefix: Bool {
		prefix == Self.treeElement
	}
	
	@inlinable public var isSubtreeSuffix: Bool {
		suffix == Self.subtreeElement
	}
	
	@inlinable public var isSubtreePrefix: Bool {
		prefix == Self.subtreeElement
	}
	
	@inlinable public var offsetString: String {
		switch self {
		case .spaces: .space
		case   .tabs: .tab
		}
	}
	
	public var value: String {
		prefix + offsetString * amount + suffix
	}
	
	public var lastValue: String {
		let prefix =
			switch prefix {
			case Self.treeElement: Self.lastTreeElement
			case Self.subtreeElement: Self.lastSubtreeElement
			case Self.secondSubtreeElement: Self.secondLastSubtreeElement
			case Self.secondEmptySubtreeElement: Self.secondEmptyLastSubtreeElement
			default: prefix
			}
		
		let suffix =
			switch suffix {
			case Self.treeElement: Self.lastTreeElement
			case Self.subtreeElement: Self.lastSubtreeElement
			case Self.secondSubtreeElement: Self.secondLastSubtreeElement
			case Self.secondEmptySubtreeElement: Self.secondEmptyLastSubtreeElement
			default: suffix
			}
		
		return prefix + offsetString * amount + suffix
	}
}

extension String {
	public func offsetting(by offset: StringOffset, first: Bool) -> String {
		if isEmpty {
			if first {
				return offset.lastValue + .xMark
			} else {
				return .xMark
			}
		}
		
		let lines = components(separatedBy: .newlines)
		let lastIndex = lines.count.prev
		
		return lines
			.enumerated()
			.map { index, line in
				switch index {
				case lastIndex where lastIndex != 0 || first: 	offset.lastValue + line
				case 0 where not(first): 						line
				default: 										offset.value + line
				}
			}
			.joined(separator: .newLine)
	}
}

extension String {
	
	/// Spaces
	
	@inlinable public func offsettingLines(by spaceCount: UInt = 4) -> String {
		.space * spaceCount + replacing(.newLine, with: .newLine + .space * spaceCount)
	}
	
	@inlinable public func offsettingNewLines(by spaceCount: UInt = 4) -> String {
		replacing(.newLine, with: .newLine + .space * spaceCount)
	}
	
	/// Tabs
	
	@inlinable public func tabOffsettingLines(by tabCount: UInt = 1) -> String {
		.tab * tabCount + replacing(.newLine, with: .newLine + .tab * tabCount)
	}
	
	@inlinable public func tabOffsettingNewLines(by tabsCount: UInt = 1) -> String {
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

// MARK: As Lines

extension Collection where Element: StringProtocol {
	@inlinable public var asLines: String {
		joined(separator: .newLine)
	}
}

// MARK: URL

extension String {
	public var withHTTPSchemeIfIsURLWithNoScheme: String {
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

