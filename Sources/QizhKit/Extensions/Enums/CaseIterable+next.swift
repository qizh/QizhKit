//
//  CaseIterable+next.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 21.10.2024.
//

import Foundation

extension CaseIterable where Self: Equatable {
	public func next() -> Self? {
		if let currentIndex = Self.allCases.firstIndex(of: self) {
			Self.allCases[safe: Self.allCases.index(after: currentIndex)]
		} else {
			Self.allCases.first
		}
	}
	
	@inlinable public var nextCase: Self? {
		next()
	}
}
