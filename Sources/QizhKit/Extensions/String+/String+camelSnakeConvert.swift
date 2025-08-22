//
//  String+camelSnakeConvert.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation
import RegexBuilder

public struct RegexesForWords {
	/*
	let beforeLargeCharacterRef = Reference(Substring.self)
	let largeCharacterRef = Reference(Character.self)

	let captureLargeCharactersAfterSmall: Regex<(Substring, Substring, Character)> =
		Regex {
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
	*/
	
	public static var words: Regex<Substring> {
		Regex {
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
				OneOrMore { #/\d/# }
			}
		}
	}
}

extension String {
	/*
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
	*/
	
	/// `toCamelCase`
	public var toCamelCase: String {
		self.matches(of: RegexesForWords.words)
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
		self.matches(of: RegexesForWords.words)
			.map(\.localizedCapitalized)
			.joined()
	}
	
	/// Matches words in any language and any case, lowercases them,
	/// and joines with provided separator
	/// - Parameter separator: String to join the words with
	/// - Returns: Lowercased words joined with the separator
	public func toLocalizedLowercasedWords(joinedBy separator: String) -> String {
		self.toWordsArray()
			.joined(separator: separator)
	}
	
	/// Splits the string into an array of lowercase words
	/// detected by a Unicode-aware word regex.
	/// Handles words in any language and case,
	/// breaking on transitions between character classes.
	///
	/// - Example:
	/// 	```swift
	///     "someCamelCase123".toWordsArray() // ["some", "camel", "case", "123"]
	///     ```
	///
	/// - Returns: An array of localized lowercased words extracted from the string.
	@inlinable public func toWordsArray() -> [String] {
		self.matches(of: RegexesForWords.words)
			.map(\.localizedLowercase)
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
		self.toLocalizedLowercasedWords(joinedBy: .dot)
	}
	
	/// `To regular sentence case`
	@inlinable public var toRegularSentenceCase: String {
		toLocalizedLowercasedWords(joinedBy: .space)
			.localizedCapitalized
	}
}

