//
//  String+camelSnakeConvert.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation
import RegexBuilder

fileprivate actor Regexes {
	fileprivate static let beforeLargeCharacterRef = Reference(Substring.self)
	fileprivate static let largeCharacterRef = Reference(Character.self)

	fileprivate static let captureLargeCharactersAfterSmall: Regex = Regex {
		Capture(as: beforeLargeCharacterRef) {
			CharacterClass(
				("a"..."z"),
				("0"..."9")
			)
		}
		TryCapture(as: largeCharacterRef) {
			("A"..."Z")
		} transform: { substring in
			substring.first
		}
	}
	
	fileprivate static let words: Regex = Regex {
		ChoiceOf {
			Regex {
				Optionally { #/\p{Lu}/# }
				OneOrMore { #/\p{Ll}/# }
			}
			Regex {
				OneOrMore { #/\p{Lu}/# }
				NegativeLookahead { #/\p{Ll}/# }
			}
			OneOrMore { #/\p{L}/# }
		}
	}
}

extension String {
	/// Converts a `camelCase` string to `snake_case`.
	@available(*, deprecated, renamed: "toSnakeCase", message: "It detects words in any string, not just in camelCase")
	public var asCamelCaseToSnakeCase: String {
		self.replacing(Regexes.captureLargeCharactersAfterSmall) { match in
			let firstPart = match[Regexes.beforeLargeCharacterRef]
			let secondPart = match[Regexes.largeCharacterRef]
			return "\(firstPart)_\(secondPart)"
		}
		.lowercased()
	}
	
	/// Converts a `snake_case` string to `camelCase`.
	@available(*, deprecated, renamed: "toCamelCase", message: "It detects words in any string, not just in snake_case")
	public var asSnakeCaseToCamelCase: String {
		self.split(separator: .underscore)
			.enumerated()
			.map { index, part in
				if index.isZero {
					part.lowercased()
				} else {
					part.capitalized
				}
			}
			.joined()
	}
	
	/// `toCamelCase`
	public var toCamelCase: String {
		self.matches(of: Regexes.words)
			.enumerated()
			.map { index, part in
				if index == 0 {
					part.localizedLowercase
				} else {
					part.localizedCapitalized
				}
			}
			.joined()
	}
	
	/// `ToPascalCase`
	public var toPascalCase: String {
		self.matches(of: Regexes.words)
			.map(\.localizedCapitalized)
			.joined()
	}
	
	/// Matches words in any language and any case, lowercases them,
	/// and joines with provided separator
	/// - Parameter separator: String to join the words with
	/// - Returns: Lowercased words joined with the separator
	public func toLocalizedLowercasedWords(joinedBy separator: String) -> String {
		self.matches(of: Regexes.words)
			.map(\.localizedLowercase)
			.joined(separator: separator)
	}
	
	/// `to_snake_case`
	@inlinable public var toSnakeCase: String {
		self.toLocalizedLowercasedWords(joinedBy: .underscore)
	}
	
	/// `to-kebab-case`
	@inlinable public var toKebabCase: String {
		self.toLocalizedLowercasedWords(joinedBy: .minus)
	}
	
	/// `to.dot.case`
	@inlinable public var toDotCase: String {
		self.toLocalizedLowercasedWords(joinedBy: .minus)
	}
}
