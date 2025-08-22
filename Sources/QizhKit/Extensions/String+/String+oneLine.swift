//
//  String+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 09.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension StringProtocol {
	@inlinable public var asLines: [String] {
		components(separatedBy: .newlines)
	}
	
	@inlinable public var inOneLine: String {
		joinedIntoOneLine()
	}
	
	@inlinable public func joinedIntoOneLine(separator: String = .space) -> String {
		asLines.joined(separator: separator)
	}
}
