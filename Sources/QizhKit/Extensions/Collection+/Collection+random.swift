//
//  Collection+random.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection {
	@inlinable func shuffled(seed: UInt64) -> [Element] {
		var generator = SeededRandomGenerator(seed: seed)
		return self.shuffled(using: &generator)
	}
	@inlinable func randomElement(seed: UInt64) -> Element? {
		var generator = SeededRandomGenerator(seed: seed)
		return self.randomElement(using: &generator)
	}
}
