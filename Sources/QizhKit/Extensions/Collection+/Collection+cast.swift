//
//  ArraySlice+asArray.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 04.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension ArraySlice {
	@inlinable public func asArray() -> [Element] { Array(self) }
}

extension Slice {
	@inlinable public func asArray() -> [Base.Element] { Array(self) }
}

extension Collection {
	@inlinable public func asArray() -> [Element] { Array(self) }
}

extension RangeReplaceableCollection
	where Self == Self.SubSequence,
		  Self: Sendable
{
	@inlinable public func asCollection <C> () -> C
		where C: RangeReplaceableCollection,
			  C.Element == Element,
			  C: Sendable
	{
		C(self)
	}
}

extension Sequence where Element: Hashable, Self: Sendable {
	@inlinable public func asSet() -> Set<Element> { Set(self) }
}
