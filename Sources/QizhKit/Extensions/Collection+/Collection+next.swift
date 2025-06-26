//
//  Collection+next.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection where Element: Equatable,
								  Element: Sendable {
	
	func next(after element: Element) -> Element? {
		if let currentIndex = firstIndex(of: element),
		   let nextIndex = index(currentIndex, offsetBy: .one, limitedBy: index(before: endIndex)) {
			self[nextIndex]
		} else {
			.none
		}
	}
	
	func previous(before element: Element) -> Element? {
		if let currentIndex = firstIndex(of: element),
		   currentIndex != startIndex
		{
			let prevIndex = index(currentIndex, offsetBy: .minusOne)
			return self[prevIndex]
		}
		return .none
	}
}
