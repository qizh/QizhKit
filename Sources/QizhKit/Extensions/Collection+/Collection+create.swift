//
//  Collection+create.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 09.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension RangeReplaceableCollection where Element: Sendable {
	static func just(_ element: Element) -> Self {
		Self(CollectionOfOne(element))
	}
}
