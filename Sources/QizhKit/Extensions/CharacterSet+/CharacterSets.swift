//
//  CharacterSets.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.09.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension CharacterSet {
	/// `"()"`
	public static var parenthesises: CharacterSet {
		CharacterSet(charactersIn: .leftParenthesis + .rightParenthesis)
	}
	
	/// `"[]"`
	public static var brackets: CharacterSet {
		CharacterSet(charactersIn: .leftBracket + .rightBracket)
	}
	
	/// `"{}"`
	public static var braces: CharacterSet {
		CharacterSet(charactersIn: .leftBrace + .rightBrace)
	}
	
	/// `"<>"`
	public static var chevrons: CharacterSet {
		CharacterSet(charactersIn: .leftChevron + .rightChevron)
	}
	
	/// `"[]" + "{}"`
	public static var jsonSides: CharacterSet {
		[
			CharacterSet.brackets,
			CharacterSet.braces,
		]
		.reduce(into: CharacterSet()) { result, element in
			result.formUnion(element)
		}
	}
	
	/// `"[]" + "{}" + .whitespaces + .newLines`
	public static var jsonSidesWithSpacesAndNewLines: CharacterSet {
		[
			CharacterSet.brackets,
			CharacterSet.braces,
			CharacterSet.whitespaces,
			CharacterSet.newlines,
		]
		.reduce(CharacterSet()) { result, element in
			result.union(element)
		}
	}
}
