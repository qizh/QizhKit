//
//  ArraySlice+asArray.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 04.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Slice {
	/// Converts this `Slice` into a standalone `Array`.
	///
	/// Use this to materialize a slice into a concrete `Array` when you need
	/// random-access semantics with zero-based indexing, to pass the elements
	/// to APIs that specifically require an `Array`, or to explicitly detach
	/// the elements from their base collection.
	/// - Invariant: The resulting array preserves the order and values of the
	///   elements in the slice. Indices are normalized to start at zero and
	///   the result is fully detached from the base collection.
	/// - Returns: A new `Array` containing the elements of the slice, in the same order.
	/// - Important: This always allocates new storage and copies elements. Mutating
	///   the returned array does not affect the original slice or its base collection,
	///   and vice versa.
	/// - Complexity: `O(n)`, where n is the number of elements in the slice.
	@inlinable public func asArray() -> [Base.Element] { Array(self) }
}

extension Sequence {
	/// Converts the receiver into a standalone `Array`.
	///
	/// Use this to materialize a sequence, collection, or slice into a concrete `Array`,
	/// for example when you need random access semantics, zero-based indexing, or to pass
	/// the values to APIs that specifically require an `Array`.
	/// - Invariant: The resulting array preserves the order of elements and contains
	///   the same elements as the receiver. For slices, this also normalizes indices
	///   to start at zero and detaches the result from the base collection.
	/// - Returns: A new `Array` containing the elements of the receiver, in the same order.
	/// - Important: This always allocates new storage and copies elements. Mutating the
	///   returned array does not affect the original sequence or collection, and vice versa.
	/// - Complexity: `O(n)`, where n is the number of elements in the receiver.
	@inlinable public func asArray() -> [Element] { Array(self) }
}

extension RangeReplaceableCollection where Self == Self.SubSequence,
										   Self: Sendable {
	/// Converts this range-replaceable, self-slicing collection into another
	/// `RangeReplaceableCollection` of the same element type.
	///
	/// Use this to materialize a slice-like collection (for example, `ArraySlice`)
	/// or any collection whose `SubSequence == Self` into a concrete destination
	/// collection type (e.g. `Array`, `ContiguousArray`, `Deque`), while preserving
	/// element order and values. This is especially useful when you need to:
	/// - Detach elements from their base collection
	/// - Satisfy APIs that require a specific collection type
	/// - Normalize indices (e.g. moving from slice indexing to zero-based indexing
	///   in the destination)
	/// - Invariant: The resulting collection contains exactly the same elements
	///   in the same order as the receiver. The result is fully detached from any base
	///   collection the receiver may reference (e.g. for slices).
	/// - Precondition:
	///   ## Generic Parameter `C`
	///   The destination collection type. Must conform to `RangeReplaceableCollection`
	///   and have the same `Element` as `Self`.
	/// - Returns: A new collection of type `C` containing the elements of `self`.
	/// - Important: This operation allocates new storage and copies elements.
	///   Mutating the returned collection will not affect the original collection
	///   (or its base), and vice versa.
	/// - Complexity: `O(n)`, where n is the number of elements in `self`.
	/// ## Example
	/// ```swift
	/// let slice: ArraySlice<Int> = [10, 20, 30][1...] // [20, 30]
	/// let array: [Int] = slice.asCollection()         // [20, 30]
	/// let contiguous: ContiguousArray<Int> =
	/// 	slice.asCollection()                        // [20, 30]
	/// ```
	@inlinable public func asCollection<C>() -> C where C: RangeReplaceableCollection,
														C.Element == Element {
		C(self)
	}
}

extension Sequence where Element: Hashable {
	/// Converts the sequence into a `Set` of its elements, removing any duplicates.
	/// 
	/// ## Use this when you need to
	/// - Eliminate duplicate elements from a sequence
	/// - Perform fast membership tests (`contains`) or set operations
	///   (`union`, `intersection`)
	/// - Materialize a `Sequence` into a hash-based collection
	/// - Invariant:
	///   - The resulting set contains each distinct element from the sequence at most once.
	///   - Element order is not preserved; `Set` is an unordered collection.
	///   - Requires `Element` to conform to `Hashable`.
	/// - Returns: A new `Set` containing the unique elements of the sequence.
	/// - Important:
	///   - This always allocates new storage and copies elements.
	///   - If `self` is already a `Set`, this creates a (copy-on-write) copy.
	///   - The entire sequence is iterated; for single-pass or infinite sequences, this will
	///     consume the sequence (and never complete for infinite ones).
	/// - Complexity: Average-case `O(n)`, where `n` is the number of elements in the
	///   sequence; worst-case can be higher if many elements collide in their hash values.
	/// ## Example
	/// ```swift
	/// let numbers = [1, 2, 2, 3, 3, 3]
	/// let unique = numbers.asSet()
	/// // Set([1, 2, 3])
	///
	/// let characters = "mississippi".asSet()
	/// // Set(["m", "i", "s", "p"])
	///
	/// #expect(unique.contains(2))
	/// ```
	@inlinable public func asSet() -> Set<Element> { Set(self) }
}
