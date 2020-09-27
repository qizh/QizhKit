//
//  Bool+xor.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/*
precedencegroup XORPrecedence {
	higherThan: TernaryPrecedence
	lowerThan: LogicalDisjunctionPrecedence
	associativity: none
}
*/

infix operator ⊻ : ComparisonPrecedence
public extension Bool {
	static func ⊻ (l: Bool, r: Bool) -> Bool { l != r }
}
