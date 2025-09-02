//
//  Collection+cycle.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection { // } where Element: Sendable {
	subscript (cycle index: Index) -> Element {
		/// Old approach
		// self[self.index(startIndex, offsetBy: distance(from: startIndex, to: index) % count)]
		
		/// The modulo calculation must not result in a negative number for the offset
		/// if distance can be negative. A safer approach handles this.
		let distance = self.distance(from: startIndex, to: index)
		let total = self.count
		guard total > 0 else { fatalError("Cannot cycle on an empty collection.") }
		let offset = (distance % total + total) % total // Ensures positive offset
		return self[self.index(startIndex, offsetBy: offset)]

	}
}

public extension Collection where Index == Int {
								  // Element: Sendable {
	subscript (cycle index: Index) -> Element {
		/// Old approach
		// self[index % count]
		
		let total = self.count
		guard total > 0 else { fatalError("Cannot cycle on an empty collection.") }
		let safeIndex = (index % total + total) % total /// Ensures positive index
		return self[safeIndex]
	}
}
