//
//  Collection+random.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Collection {
	public func shuffled(seed: UInt64) -> [Element] {
		var generator = SeededRandomGenerator(seed: seed)
		return self.shuffled(using: &generator)
	}
	
	public func randomElement(seed: UInt64) -> Element? {
		var generator = SeededRandomGenerator(seed: seed)
		return self.randomElement(using: &generator)
	}
}

/*
#if canImport(Algorithms)
import Algorithms

extension Collection {
	public func randomSample(count: Int, seed: UInt64) -> [Element] {
		var generator = SeededRandomGenerator(seed: seed)
		return self.randomSample(count: count, using: &generator)
	}
}
#endif
*/
