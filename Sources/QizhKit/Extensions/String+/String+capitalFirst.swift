//
//  String+capitalFirst.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 10.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	var capitalizedFirst: String {
		if count.isZero || first?.isUppercase == true { return self }
		return replacingCharacters(in: startIndex ..< index(after: startIndex), with: first!.uppercased())
	}
	
	var decapitalizedFirst: String {
		if count.isZero || first?.isLowercase == true { return self }
		return replacingCharacters(in: startIndex ..< index(after: startIndex), with: first!.lowercased())
	}
}
