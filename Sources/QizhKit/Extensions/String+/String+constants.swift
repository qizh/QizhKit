//
//  String+constants.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Character {
	static let newLineChar: Character      			= "\n"
	static let spaceChar: Character        			= " "
	/** / */ static let slashChar: Character        = "/"
	/** \ */ static let backslashChar: Character    = "\\"
	static let tabChar: Character          			= "\t"
	static let nbspChar: Character         			= "\u{00a0}"
	static let quotChar: Character         			= "\""
	static let apostropheChar: Character   			= "'"
	
	static let plusChar: Character         			= "+"
	static let minusChar: Character        			= "-"
	static let multiplyChar: Character     			= "✕"
	static let xMarkChar: Character        			= "✕"
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

public extension String {
	static let newLine      		= String(Character.newLineChar)
	static let space        		= String(Character.spaceChar)
	/** / */ static let slash     	= String(Character.slashChar)
	/** \ */ static let backslash 	= String(Character.backslashChar)
	static let tab          		= String(Character.tabChar)
	static let nbsp         		= String(Character.nbspChar)
	static let quot         		= String(Character.quotChar)
	static let apostrophe   		= String(Character.apostropheChar)
	
	static let plus         		= String(Character.plusChar)
	static let minus        		= String(Character.minusChar)
	static let multiply     		= String(Character.multiplyChar)
	static let xMark        		= String(Character.xMarkChar)
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
	
	/** ( */ static let leftParenthesis  	= String(Character.leftParenthesisChar)
	/** ) */ static let rightParenthesis 	= String(Character.rightParenthesisChar)
	/** [ */ static let leftBracket 		= String(Character.leftBracketChar)
	/** ] */ static let rightBracket 		= String(Character.rightBracketChar)
	/** { */ static let leftBrace 			= String(Character.leftBraceChar)
	/** } */ static let rightBrace 			= String(Character.rightBraceChar)
	/** < */ static let leftChevron 		= String(Character.leftChevronChar)
	/** > */ static let rightChevron 		= String(Character.rightChevronChar)

	static let leftSkobka       		= leftParenthesis
	static let rightSkobka      		= rightParenthesis
	static let leftKvadratnayaSkobka 	= leftBracket
	static let rightKvadratnayaSkobka 	= rightBracket
	static let leftFigurnayaSkobka 		= leftBrace
	static let rightFigurnayaSkobka 	= rightBrace
	
	/** ⚡️ */ static let bolt = String(Character.boltChar)
	
	static let comaspace    = .coma + .space
	static let colonspace   = .colon + .space
}

public extension String {
	static let nonBreakingSpace = String.nbsp
}
