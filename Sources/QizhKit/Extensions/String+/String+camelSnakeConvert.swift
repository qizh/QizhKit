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
}

extension String {
	/// Converts a `camelCase` string to `snake_case`.
	public var asCamelCaseToSnakeCase: String {
		self.replacing(Regexes.captureLargeCharactersAfterSmall) { match in
			let firstPart = match[Regexes.beforeLargeCharacterRef]
			let secondPart = match[Regexes.largeCharacterRef]
			return "\(firstPart)_\(secondPart)"
		}
		.lowercased()
	}
	
	/// Converts a `snake_case` string to `camelCase`.
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
}
