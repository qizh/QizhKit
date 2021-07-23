//
//  String+nbsp.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	@inlinable var withNonBreakingSpaces: String {
		replacing(.whitespaces, with: .nbsp)
	}
	
	@inlinable var withDotsForSpaces: String {
		replacing(.whitespaces, with: .dot)
	}
	
	@inlinable var withDashesForSpaces: String {
		replacing(.whitespaces, with: .minus)
	}
	
	@available(*, deprecated, renamed: "withUnderscoreForSpaces")
	@inlinable var withUnderlineForSpaces: String {
		replacing(.whitespaces, with: .underline)
	}
	
	@inlinable var withUnderscoreForSpaces: String {
		replacing(.whitespaces, with: .underscore)
	}
}
