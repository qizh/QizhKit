//
//  String+email.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.09.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	static func emailPlaceholder(_ parts: String ...) -> String {
		parts
			.map(\.withSpacesTrimmed)
			.map(\.localizedLowercase)
			.map(\.withDotsForSpaces)
			.filter(\.isNotEmpty)
			.joined(separator: .dot)
			.nonEmpty.or("user")
		+ "@example.com"
	}
}
