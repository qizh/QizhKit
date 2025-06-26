//
//  Array+Chunked.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 22.11.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection where Element: Sendable {
	@inlinable func chunked(into size: Int) -> [[Element]] {
		stride(from: 0, to: count, by: size)
			.map { self[indexes(from: $0, count: size)].asArray() }
	}
	
	/*
	@inlinable func chunked(into size: Int) -> [[Element]] {
		stride(from: 0, to: count, by: size).map(slice(count: size))
	}

	@inlinable func slice(count size: Int) -> ((_ offset: Int) -> [Element]) {
		{ offset -> [Element] in
			self[self.indexes(from: offset, count: size)].asArray()
		}
	}
	*/
	
	@inlinable func indexes(from offset: Int, count size: Int) -> Range<Self.Index> {
		let lowerBound = index(startIndex, offsetBy: offset)
		let upperBound = index(lowerBound, offsetBy: size, limitedBy: endIndex) ?? endIndex
		return lowerBound ..< upperBound
		
		/*
		Range<Self.Index>(
			uncheckedBounds: (
				lower: index(startIndex, offsetBy: offset),
				upper: index(startIndex, offsetBy: Swift.min(offset + size, count))
			)
		)
		*/
	}
}

public extension Collection
	where Index == Int,
		  Element: Sendable
{
	@inlinable func chunked(into size: Int) -> [[Element]] {
		stride(from: 0, to: count, by: size)
			.map { offset in
				self[offset ..< Swift.min(offset + size, count)].asArray()
			}
	}
}
