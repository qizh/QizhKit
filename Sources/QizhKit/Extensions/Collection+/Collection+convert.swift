//
//  Collection+convert.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation
import OrderedCollections

extension Collection {
	public var asEnumeratedOrderedDictionary: OrderedDictionary<Int, Element> {
		OrderedDictionary(uniqueKeysWithValues: enumerated().map({($0, $1)}))
	}
}
