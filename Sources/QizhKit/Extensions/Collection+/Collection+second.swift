//
//  Collection+second.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection {
	@inlinable var secondIndex: Index { index(after:  startIndex) }
	@inlinable var  thirdIndex: Index { index(after: secondIndex) }
	@inlinable var fourthIndex: Index { index(after:  thirdIndex) }
	@inlinable var penultimateIndex: Index { index(endIndex, offsetBy: -1) }

	@inlinable var second: Element? { self[safe: secondIndex] }
	@inlinable var  third: Element? { self[safe:  thirdIndex] }
	@inlinable var fourth: Element? { self[safe: fourthIndex] }
	@inlinable var penultimate: Element? { self[safe: penultimateIndex] }
}
