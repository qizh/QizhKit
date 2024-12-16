//
//  String+constants.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Character

public extension Character {
	static let newLineChar: Character      			= "\n"
	static let spaceChar: Character        			= " "
	/** / */ static let slashChar: Character        = "/"
	/** \ */ static let backslashChar: Character    = "\\"
	static let tabChar: Character          			= "\t"
	static let nbspChar: Character         			= "\u{00a0}"
	static let quotChar: Character         			= "\""
	/** | */ static let lineChar: Character 		= "|"
	static let apostropheChar: Character   			= "'"
	
	static let plusChar: Character         			= "+"
	static let minusChar: Character        			= "-"
	static let multiplyChar: Character     			= "✕"
	static let xMarkChar: Character        			= "✕"
	static let checkMarkChar: Character        		= "✔︎"
	static let divideChar: Character       			= "÷"
	static let plusminusChar: Character    			= "±"
	static let degreesChar: Character      			= "°"
	static let underlineChar: Character    			= "_"
	static let underscoreChar: Character   			= "_"
	static let percentChar: Character      			= "%"
	static let questionMarkChar: Character 			= "?"
	static let atChar: Character 		   			= "@"
	static let hashChar: Character 		   			= "#"
	static let asteriskChar: Character 		   		= "*"
	
	static let dollarChar: Character       			= "$"
	static let euroChar: Character         			= "€"
	
	static let dotChar: Character          			= "."
	static let comaChar: Character         			= ","
	static let tridotChar: Character       			= "…"
	static let colonChar: Character        			= ":"
	
	/** → */ static let arrowRightChar: Character 			= "→"
	/** ← */ static let arrowLeftChar: Character 			= "←"
	/** ↓ */ static let arrowUpChar: Character 				= "↓"
	/** ↑ */ static let arrowDownChar: Character 			= "↑"
	
	/** « */ static let leftDoubleQuoteChar: Character 		= "«"
	/** » */ static let rightDoubleQuoteChar: Character 	= "»"
	/** « */ static let openingDoubleQuoteChar: Character 	= "«"
	/** » */ static let closingDoubleQuoteChar: Character 	= "»"
	
	/** ┃ */ static let treeLineChar: Character 			= "┃"
	/** ┣ */ static let treeLineBranchChar: Character 		= "┣"
	/** ┗ */ static let treeLineEndChar: Character 			= "┗"
	
	/** ( */ static let leftParenthesisChar: Character  	= "("
	/** ) */ static let rightParenthesisChar: Character 	= ")"
	/** [ */ static let leftBracketChar: Character  		= "["
	/** ] */ static let rightBracketChar: Character 		= "]"
	/** { */ static let leftBraceChar: Character  			= "{"
	/** } */ static let rightBraceChar: Character 			= "}"
	/** < */ static let leftChevronChar: Character  		= "<"
	/** > */ static let rightChevronChar: Character 		= ">"
	
	/** ⚡️ */ static let boltChar: Character = "⚡️"
}

// MARK: String

public extension String {
	static let newLine      		= String(Character.newLineChar)
	static let space        		= String(Character.spaceChar)
	/** / */ static let slash     	= String(Character.slashChar)
	/** \ */ static let backslash 	= String(Character.backslashChar)
	static let tab          		= String(Character.tabChar)
	static let nbsp         		= String(Character.nbspChar)
	static let nonBreakingSpace 	= String.nbsp
	static let quot         		= String(Character.quotChar)
	/** | */ static let line 		= String(Character.lineChar)
	static let apostrophe   		= String(Character.apostropheChar)
	
	static let plus         		= String(Character.plusChar)
	static let minus        		= String(Character.minusChar)
	static let multiply     		= String(Character.multiplyChar)
	static let xMark        		= String(Character.xMarkChar)
	static let checkMark        	= String(Character.checkMarkChar)
	static let divide       		= String(Character.divideChar)
	static let plusminus    		= String(Character.plusminusChar)
	static let degrees      		= String(Character.degreesChar)
	static let underline    		= String(Character.underlineChar)
	static let underscore   		= String(Character.underlineChar)
	static let percent      		= String(Character.percentChar)
	static let questionMark 		= String(Character.questionMarkChar)
	static let at 					= String(Character.atChar)
	static let hash 				= String(Character.hashChar)
	static let asterisk 			= String(Character.asteriskChar)
	
	static let dollar       		= String(Character.dollarChar)
	static let euro         		= String(Character.euroChar)
	
	static let dot          		= String(Character.dotChar)
	static let coma         		= String(Character.comaChar)
	static let tridot       		= String(Character.tridotChar)
	/** : */ static let colon 		= String(Character.colonChar)
	
	/** → */ static let arrowRight 			= String(Character.arrowRightChar)
	/** ← */ static let arrowLeft 			= String(Character.arrowLeftChar)
	/** ↓ */ static let arrowUp 			= String(Character.arrowUpChar)
	/** ↑ */ static let arrowDown 			= String(Character.arrowDownChar)
	
	/** « */ static let leftDoubleQuote 	= String(Character.leftDoubleQuoteChar)
	/** » */ static let rightDoubleQuote 	= String(Character.rightDoubleQuoteChar)
	/** « */ static let openingDoubleQuote 	= String(Character.openingDoubleQuoteChar)
	/** » */ static let closingDoubleQuote 		= String(Character.closingDoubleQuoteChar)
	
	/** ┃ */ static let treeLine 			= String(Character.treeLineChar)
	/** ┣ */ static let treeLineBranch 		= String(Character.treeLineBranchChar)
	/** ┗ */ static let treeLineEnd 		= String(Character.treeLineEndChar)
	
	/** ( */ static let leftParenthesis  	= String(Character.leftParenthesisChar)
	/** ) */ static let rightParenthesis 	= String(Character.rightParenthesisChar)
	/** [ */ static let leftBracket 		= String(Character.leftBracketChar)
	/** ] */ static let rightBracket 		= String(Character.rightBracketChar)
	/** { */ static let leftBrace 			= String(Character.leftBraceChar)
	/** } */ static let rightBrace 			= String(Character.rightBraceChar)
	/** < */ static let leftChevron 		= String(Character.leftChevronChar)
	/** > */ static let rightChevron 		= String(Character.rightChevronChar)
	
	/** ( */ static let leftSkobka       		= leftParenthesis
	/** ) */ static let rightSkobka      		= rightParenthesis
	/** [ */ static let leftKvadratnayaSkobka 	= leftBracket
	/** ] */ static let rightKvadratnayaSkobka 	= rightBracket
	/** { */ static let leftFigurnayaSkobka 	= leftBrace
	/** } */ static let rightFigurnayaSkobka 	= rightBrace
	/** < */ static let leftUgolnayaSkobka 		= leftChevron
	/** > */ static let rightUgolnayaSkobka 	= rightChevron
	
	/** ⚡️ */ static let bolt = String(Character.boltChar)
	
	/** «`. `» */ static let dotspace    			= .coma + .space
	/** «`, `» */ static let comaspace    		= .coma + .space
	/** «`: `» */ static let colonspace   		= .colon + .space
	/** «` → `» */ static let spaceArrowSpace 	= .space + .arrowRight + .space
}

// MARK: Surround by

extension String {
	/// `«...»`
	@inlinable public var inDoubleQuotes: String {
		.openingDoubleQuote + self + .closingDoubleQuote
	}
	
	/// `(...)`
	@inlinable public var inParenthesis: String {
		.leftParenthesis + self + .rightParenthesis
	}
	
	/// `[...]`
	@inlinable public var inBrackets: String {
		.leftBracket + self + .rightBracket
	}
	
	/// `<...>`
	@inlinable public var inChevrons: String {
		.leftChevron + self + .rightChevron
	}
	
	/// `┣ ...`
	@inlinable public var prefixedAsTreeBranch: String {
		"┣ \(self)"
	}
	
	/// `┗ ...`
	@inlinable public var prefixedAsLastTreeBranch: String {
		"┗ \(self)"
	}
	
	/// `┣ name: ...`
	@inlinable public func asTreeBranch(named name: String) -> String {
		"┣ \(name): \(self)"
	}
	
	/// `┗ name: ...`
	@inlinable public func asTreeLastBranch(named name: String) -> String {
		"┗ \(name): \(self)"
	}
}

// MARK: Collection as Tree string

extension Collection<String> {
	/// Will output tree like the following:
	/// ```
	/// ┣ value1
	/// ┣ value2
	/// ┗ value3
	/// ```
	public var asTreeBranches: String {
		if isEmpty { return .empty }
		if let justOne { return justOne.prefixedAsLastTreeBranch }
		
		var output: String = .empty
		for (index, string) in self.enumerated() {
			if index == count - 1 {
				output += string.prefixedAsLastTreeBranch
			} else {
				output += string.prefixedAsTreeBranch + .newLine
			}
		}
		return output
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ value1
	/// ┣ value2
	/// ┗ value3
	/// ```
	/// or `name: <empty>` in case of empty collection
	public func asTreeBranches(named name: String) -> String {
		if isEmpty {
			name + .colonspace + "empty".inChevrons
		} else {
			name + .newLine + asTreeBranches
		}
	}
	
	/// `value 1 → value 2 → value 3`
	public var asArrowedPath: String {
		if isEmpty {
			.empty
		} else if let justOne {
			justOne
		} else {
			joined(separator: .spaceArrowSpace)
		}
	}
}

// MARK: Dictionary as Tree string

extension Dictionary<String, String> {
	/// Will output tree like the following:
	/// ```
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	public var asTreeBranches: String {
		if isEmpty { return .empty }
		if let justOne { return justOne.value.asTreeLastBranch(named: justOne.key) }
		
		var outputs: [String] = .empty
		for (index, (key, value)) in self.enumerated() {
			if index == count - 1 {
				outputs.append(value.asTreeLastBranch(named: key))
			} else {
				outputs.append(value.asTreeBranch(named: key))
			}
		}
		return outputs.joined(separator: .newLine)
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	public func asTreeBranches(named name: String) -> String {
		if isEmpty {
			name + .colonspace + "empty".inChevrons
		} else {
			name + .newLine + asTreeBranches
		}
	}
}

extension Dictionary<String, CustomStringConvertible> {
	/// Will output tree like the following:
	/// ```
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	public var asTreeBranches: String {
		Dictionary<String, String>(
			uniqueKeysWithValues: map({($0.key, $0.value.description)})
		)
		.asTreeBranches
	}
	
	/// Will output tree like the following:
	/// ```
	/// name
	/// ┣ key1: value1
	/// ┣ key2: value2
	/// ┗ key3: value3
	/// ```
	/// or `name: <empty>` in case of empty Dictionary
	public func asTreeBranches(named name: String) -> String {
		Dictionary<String, String>(
			uniqueKeysWithValues: map({($0.key, $0.value.description)})
		)
		.asTreeBranches(named: name)
	}
}
