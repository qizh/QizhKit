//
//  String+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 09.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	@inlinable var inOneLine: String { joinedIntoOneLine() }
	@inlinable func joinedIntoOneLine(separator: String = .space) -> String {
		components(separatedBy: .newlines).joined(separator: separator)
	}
}
