//
//  Array+Chunked.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 22.11.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection where Element: Sendable {
	/// Splits a collection into consecutive chunks (subarrays) of a given maximum size.
	///
	/// The method walks the collection from the start to the end, producing slices of up to `size` elements,
	/// preserving the original order. The final chunk may contain fewer than `size` elements if the total
	/// number of elements is not evenly divisible by `size`.
	///
	/// - Parameter size: The maximum number of elements per chunk. Must be greater than zero.
	/// - Returns: An array of arrays, where each inner array is a chunk of the original collection.
	/// - Complexity: O(n), where n is the number of elements in the collection. Each element is visited exactly once.
	/// - Note: For empty collections, this returns an empty array. If `size` is less than or equal to zero,
	///   the behavior is undefined and may trap at runtime.
	/// - Example:
	///   ```swift
	///   let numbers = [1, 2, 3, 4, 5]
	///   let chunks = numbers.chunked(into: 2)
	///   // chunks == [[1, 2], [3, 4], [5]]
	///   ```
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
