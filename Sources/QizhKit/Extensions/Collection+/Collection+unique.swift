//
//  Collection+unique.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 25.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection where Element: Hashable {
	var firstUniqueElements: [Element] {
		var seen: Set<Element> = []
		return filter({ seen.insert($0).inserted })
	}
	
	@inlinable func removingHashableDuplicates() -> [Element] {
		firstUniqueElements
	}
}

public extension Collection {
	func removingHashableDuplicates<Value>(by transform: (Element) -> Value) -> [Element] where Value: Hashable {
		var seen = Set<Value>()
		return filter({ seen.insert(transform($0)).inserted })
	}
}

public extension Collection where Element: Equatable {
	@inlinable var firstUniqueElements: [Element] {
		reduce(into: []) { uniqueElements, element in
			if !uniqueElements.contains(element) {
				uniqueElements.append(element)
			}
		}
	}
	
	@inlinable func removingEquatableDuplicates() -> [Element] {
		firstUniqueElements
	}
}
