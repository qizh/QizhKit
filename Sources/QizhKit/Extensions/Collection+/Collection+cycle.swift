//
//  Collection+cycle.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection {
	subscript (cycle index: Index) -> Element {
		self[self.index(startIndex, offsetBy: distance(from: startIndex, to: index) % count)]
	}
}

public extension Collection where Index == Int {
	subscript (cycle index: Index) -> Element {
		self[index % count]
	}
}
